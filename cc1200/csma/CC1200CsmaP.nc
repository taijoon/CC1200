
module CC1200CsmaP @safe() {

  provides interface SplitControl;
  provides interface Send;
  provides interface RadioBackoff;

  uses interface Resource;
  uses interface CC1200Power;
  uses interface StdControl as SubControl;
  uses interface CC1200Transmit;
  uses interface RadioBackoff as SubBackoff;
  uses interface Random;
  uses interface Leds;
  uses interface CC1200Packet;
  uses interface CC1200PacketBody;
  uses interface State as SplitControlState;

}

implementation {

  enum {
    S_STOPPED,
    S_STARTING,
    S_STARTED,
    S_STOPPING,
    S_TRANSMITTING,
  };

  message_t* ONE_NOK m_msg;
  
  error_t sendErr = SUCCESS;
  
  /** TRUE if we are to use CCA when sending the current packet */
  norace bool ccaOn;
  
  /****************** Prototypes ****************/
  task void startDone_task();
  task void stopDone_task();
  task void sendDone_task();
  
  void shutdown();

  /***************** SplitControl Commands ****************/
  command error_t SplitControl.start() {
    if(call SplitControlState.requestState(S_STARTING) == SUCCESS) {
      call CC1200Power.startVReg();

      call SplitControlState.forceState(S_STARTED);	// edited by TJ
      return SUCCESS;
    } else if(call SplitControlState.isState(S_STARTED)) {
      return EALREADY;
      
    } else if(call SplitControlState.isState(S_STARTING)) {
      return SUCCESS;
    }
    return EBUSY;
  }

  command error_t SplitControl.stop() {
    if (call SplitControlState.isState(S_STARTED)) {
      call SplitControlState.forceState(S_STOPPING);
      shutdown();
      return SUCCESS;
      
    } else if(call SplitControlState.isState(S_STOPPED)) {
      return EALREADY;
    
    } else if(call SplitControlState.isState(S_TRANSMITTING)) {
      call SplitControlState.forceState(S_STOPPING);
      // At sendDone, the radio will shut down
      return SUCCESS;
    
    } else if(call SplitControlState.isState(S_STOPPING)) {
      return SUCCESS;
    }
    
    return EBUSY;
  }

  /***************** Send Commands ****************/
  command error_t Send.cancel( message_t* p_msg ) {
    return call CC1200Transmit.cancel();
  }

  command error_t Send.send( message_t* p_msg, uint8_t len ) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader( p_msg );
    cc1200_metadata_t* metadata = call CC1200PacketBody.getMetadata( p_msg );

    atomic {
      if (!call SplitControlState.isState(S_STARTED)) {
        return FAIL;
      }
      
      call SplitControlState.forceState(S_TRANSMITTING);
      m_msg = p_msg;
    }

     header->length = len + CC1200_SIZE;
#ifdef CC1200_HW_SECURITY
//    header->fcf &= ((1 << IEEE154_FCF_ACK_REQ)|
//                    (1 << IEEE154_FCF_SECURITY_ENABLED)|
//                    (0x3 << IEEE154_FCF_SRC_ADDR_MODE) |
//                    (0x3 << IEEE154_FCF_DEST_ADDR_MODE));
#else
    header->fcf &= ((1 << IEEE154_FCF_ACK_REQ) | 
                    (0x3 << IEEE154_FCF_SRC_ADDR_MODE) |
                    (0x3 << IEEE154_FCF_DEST_ADDR_MODE));
#endif
    header->fcf |= ( ( IEEE154_TYPE_DATA << IEEE154_FCF_FRAME_TYPE ) |
		     ( 1 << IEEE154_FCF_INTRAPAN ) ); 

    metadata->ack = FALSE;
    metadata->rssi = 0;
    metadata->lqi = 0;
    metadata->timesync = FALSE;
    metadata->timestamp = CC1200_INVALID_TIMESTAMP;

/* Edited by TJ
    ccaOn = TRUE;
    signal RadioBackoff.requestCca(m_msg);
*/
    call CC1200Transmit.send( m_msg, ccaOn );
    return SUCCESS;

  }

  command void* Send.getPayload(message_t* m, uint8_t len) {
    if (len <= call Send.maxPayloadLength()) {
      return (void* COUNT_NOK(len ))(m->data);
    }
    else {
      return NULL;
    }
  }

  command uint8_t Send.maxPayloadLength() {
    return TOSH_DATA_LENGTH;
  }

  /**************** RadioBackoff Commands ****************/
  /**
   * Must be called within a requestInitialBackoff event
   * @param backoffTime the amount of time in some unspecified units to backoff
   */
  async command void RadioBackoff.setInitialBackoff(uint16_t backoffTime) {
    call SubBackoff.setInitialBackoff(backoffTime);
  }
  
  /**
   * Must be called within a requestCongestionBackoff event
   * @param backoffTime the amount of time in some unspecified units to backoff
   */
  async command void RadioBackoff.setCongestionBackoff(uint16_t backoffTime) {
    call SubBackoff.setCongestionBackoff(backoffTime);
  }
      
  /**
   * Enable CCA for the outbound packet.  Must be called within a requestCca
   * event
   * @param ccaOn TRUE to enable CCA, which is the default.
   */
  async command void RadioBackoff.setCca(bool useCca) {
    ccaOn = useCca;
  }
  

  /**************** Events ****************/
  async event void CC1200Transmit.sendDone( message_t* p_msg, error_t err ) {
    atomic sendErr = err;
    post sendDone_task();
  }

  async event void CC1200Power.startVRegDone() {
    call Resource.request();
  }
  
  event void Resource.granted() {
    call CC1200Power.startOscillator();
  }

  async event void CC1200Power.startOscillatorDone() {
    post startDone_task();
  }
  
  /***************** SubBackoff Events ****************/
  async event void SubBackoff.requestInitialBackoff(message_t *msg) {
    call SubBackoff.setInitialBackoff ( call Random.rand16() 
        % (0x1F * CC1200_BACKOFF_PERIOD) + CC1200_MIN_BACKOFF);
        
    signal RadioBackoff.requestInitialBackoff(msg);
  }

  async event void SubBackoff.requestCongestionBackoff(message_t *msg) {
    call SubBackoff.setCongestionBackoff( call Random.rand16() 
        % (0x7 * CC1200_BACKOFF_PERIOD) + CC1200_MIN_BACKOFF);

    signal RadioBackoff.requestCongestionBackoff(msg);
  }
  
  async event void SubBackoff.requestCca(message_t *msg) {
    // Lower layers than this do not configure the CCA settings
    signal RadioBackoff.requestCca(msg);
  }
  
  
  /***************** Tasks ****************/
  task void sendDone_task() {
    error_t packetErr;
    atomic packetErr = sendErr;
    if(call SplitControlState.isState(S_STOPPING)) {
      shutdown();
      
    } else {
      call SplitControlState.forceState(S_STARTED);
    }
    
    signal Send.sendDone( m_msg, packetErr );
  }

  task void startDone_task() {
    call SubControl.start();
    call CC1200Power.rxOn();
//    call Resource.release();
    call SplitControlState.forceState(S_STARTED);
    signal SplitControl.startDone( SUCCESS );
  }
  
  task void stopDone_task() {
    call SplitControlState.forceState(S_STOPPED);
    signal SplitControl.stopDone( SUCCESS );
  }
  
  
  /***************** Functions ****************/
  /**
   * Shut down all sub-components and turn off the radio
   */
  void shutdown() {
    call SubControl.stop();
    call CC1200Power.stopVReg();
    post stopDone_task();
  }

  /***************** Defaults ***************/
  default event void SplitControl.startDone(error_t error) {
  }
  
  default event void SplitControl.stopDone(error_t error) {
  }
  
  default async event void RadioBackoff.requestInitialBackoff(message_t *msg) {
  }

  default async event void RadioBackoff.requestCongestionBackoff(message_t *msg) {
  }
  
  default async event void RadioBackoff.requestCca(message_t *msg) {
  }
  
  
}

