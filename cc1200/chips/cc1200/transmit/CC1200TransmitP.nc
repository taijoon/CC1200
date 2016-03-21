
#include "CC1200.h"
#include "CC1200TimeSyncMessage.h"
#include "crc.h"
#include "message.h"

module CC1200TransmitP @safe() {

  provides interface Init;
  provides interface StdControl;
  provides interface CC1200Transmit as Send;
  provides interface RadioBackoff;
  provides interface ReceiveIndicator as EnergyIndicator;
  provides interface ReceiveIndicator as ByteIndicator;
  
  uses interface Alarm<T32khz,uint32_t> as BackoffTimer;
  uses interface CC1200Packet;
  uses interface CC1200PacketBody;
  uses interface PacketTimeStamp<T32khz,uint32_t>;
  uses interface PacketTimeSyncOffset;
  uses interface GpioCapture as CaptureSFD;
  uses interface GeneralIO as CCA;  // CCA == 0 clear, CCA.get() == 1 busy
  uses interface GeneralIO as CSN;
  uses interface GeneralIO as SFD;

  uses interface Resource as SpiResource;
  uses interface ChipSpiResource;
  uses interface CC1200Fifo as TXFIFO;
  uses interface CC1200Ram as TXFIFO_RAM;
  uses interface CC1200Register as TXCTRL;
  uses interface CC1200Strobe as SNOP;
  uses interface CC1200Strobe as STXON;
  uses interface CC1200Strobe as STXONCCA;
  uses interface CC1200Strobe as SFLUSHTX;
  uses interface CC1200Register as MDMCTRL1;

  uses interface CC1200Strobe as STXENC;
  uses interface CC1200Register as SECCTRL0;
  uses interface CC1200Register as SECCTRL1;
  uses interface CC1200Ram as KEY0;
  uses interface CC1200Ram as KEY1;
  uses interface CC1200Ram as TXNONCE;
  // Add by TJ
  uses interface CC1200Strobe as SIDLE;
  uses interface CC1200Strobe as STX;
  uses interface CC1200Strobe as SRX;
  uses interface CC1200Strobe as SFTX;
  uses interface CC1200Strobe as SFRX;
  uses interface CC1200Register as RFEND_CFG0;
  uses interface CC1200Register as TXFIRST;
  uses interface CC1200Register as TXLAST;
  uses interface CC1200Register as MARCSTATE;

  uses interface CC1200Receive;
  uses interface Leds;
}

implementation {

	typedef enum {
		S_IDLE,
		S_RX,
		S_TX,
		S_FSTXON,
		S_CALIbRATE,
		S_SETTING,
		S_RX_FIFO_ERROR,
		S_TX_FIFO_ERROR,
	}cc1200_chip_status;

  typedef enum {
    S_STOPPED,
    S_STARTED,
    S_LOAD,
    S_SAMPLE_CCA,
    S_BEGIN_TRANSMIT,
    S_SFD,
    S_EFD,
    S_ACK_WAIT,
    S_CANCEL,
  } cc1200_transmit_state_t;

  // This specifies how many jiffies the stack should wait after a
  // TXACTIVE to receive an SFD interrupt before assuming something is
  // wrong and aborting the send. There seems to be a condition
  // on the micaZ where the SFD interrupt is never handled.
  enum {
    CC1200_ABORT_PERIOD = 320
  };

  norace message_t * ONE_NOK m_msg;
  
  norace bool m_cca;
  
  norace uint8_t m_tx_power;
  
  norace cc1200_transmit_state_t m_state = S_STOPPED;

  bool m_receiving = FALSE;
  
  uint16_t m_prev_time;
  
  /** Byte reception/transmission indicator */
  bool sfdHigh;
  
  /** Let the CC1200 driver keep a lock on the SPI while waiting for an ack */
  norace bool abortSpiRelease;
  
  /** Total CCA checks that showed no activity before the NoAck LPL send */
  norace int8_t totalCcaChecks;
  
  /** The initial backoff period */
  norace uint16_t myInitialBackoff;
  
  /** The congestion backoff period */
  norace uint16_t myCongestionBackoff;
  
  norace uint8_t txBuffer[256];

  /***************** Prototypes ****************/
  error_t send( message_t * ONE p_msg, bool cca );
  error_t resend( bool cca );
  void loadTXFIFO();
  void attemptSend();
  void congestionBackoff();
  error_t acquireSpiResource();
  error_t releaseSpiResource();
  void signalDone( error_t err );
  void flush();
  
  
  /***************** Init Commands *****************/
  command error_t Init.init() {
    call CCA.makeInput();
    call CSN.makeOutput();
    call SFD.makeInput();
    return SUCCESS;
  }

  /***************** StdControl Commands ****************/
  command error_t StdControl.start() {
    atomic {
      //call CaptureSFD.captureRisingEdge();
      m_state = S_STARTED;
      m_receiving = FALSE;
      abortSpiRelease = FALSE;
      m_tx_power = 0;
    }
    return SUCCESS;
  }

  command error_t StdControl.stop() {
    atomic {
      m_state = S_STOPPED;
      call BackoffTimer.stop();
      call CaptureSFD.disable();
      call SpiResource.release();  // REMOVE
      call CSN.set();
    }
    return SUCCESS;
  }


  /**************** Send Commands ****************/
  async command error_t Send.send( message_t* ONE p_msg, bool useCca ) {
    return send( p_msg, useCca );
  }

  async command error_t Send.resend(bool useCca) {
    return resend( useCca );
  }

  async command error_t Send.cancel() {
    atomic {
      switch( m_state ) {
      case S_LOAD:
      case S_SAMPLE_CCA:
      case S_BEGIN_TRANSMIT:
        m_state = S_CANCEL;
        break;
        
      default:
        // cancel not allowed while radio is busy transmitting
        return FAIL;
      }
    }
    return SUCCESS;
  }

  async command error_t Send.modify( uint8_t offset, uint8_t* buf, 
                                     uint8_t len ) {
//    call CSN.clr();
//    call TXFIFO_RAM.write( offset, buf, len );
//    call CSN.set();
    return SUCCESS;
  }
  
  /***************** Indicator Commands ****************/
  command bool EnergyIndicator.isReceiving() {
    return !(call CCA.get());
  }
  
  command bool ByteIndicator.isReceiving() {
    bool high;
    atomic high = sfdHigh;
    return high;
  }
  

  /***************** RadioBackoff Commands ****************/
  /**
   * Must be called within a requestInitialBackoff event
   * @param backoffTime the amount of time in some unspecified units to backoff
   */
  async command void RadioBackoff.setInitialBackoff(uint16_t backoffTime) {
    myInitialBackoff = backoffTime + 1;
  }
  
  /**
   * Must be called within a requestCongestionBackoff event
   * @param backoffTime the amount of time in some unspecified units to backoff
   */
  async command void RadioBackoff.setCongestionBackoff(uint16_t backoffTime) {
    myCongestionBackoff = backoffTime + 1;
  }
  
  async command void RadioBackoff.setCca(bool useCca) {
  }
  
  // this method converts a 16-bit timestamp into a 32-bit one
  inline uint32_t getTime32(uint16_t captured_time)
  {
    uint32_t now = call BackoffTimer.getNow();

    // the captured_time is always in the past
    return now - (uint16_t)(now - captured_time);
  }

  /**
   * The CaptureSFD event is actually an interrupt from the capture pin
   * which is connected to timing circuitry and timer modules.  This
   * type of interrupt allows us to see what time (being some relative value)
   * the event occurred, and lets us accurately timestamp our packets.  This
   * allows higher levels in our system to synchronize with other nodes.
   *
   * Because the SFD events can occur so quickly, and the interrupts go
   * in both directions, we set up the interrupt but check the SFD pin to
   * determine if that interrupt condition has already been met - meaning,
   * we should fall through and continue executing code where that interrupt
   * would have picked up and executed had our microcontroller been fast enough.
   */
  async event void CaptureSFD.captured( uint16_t time ) {
  }

  /***************** ChipSpiResource Events ****************/
  async event void ChipSpiResource.releasing() {
    if(abortSpiRelease) {
      call ChipSpiResource.abortRelease();
    }
  }
  
  
  /***************** CC1200Receive Events ****************/
  /**
   * If the packet we just received was an ack that we were expecting,
   * our send is complete.
   */
  async event void CC1200Receive.receive( uint8_t type, message_t* ack_msg ) {
    if ( type == S_TX ) {
      if ( m_state == S_SFD ) {
        call BackoffTimer.stop();
        signalDone( SUCCESS );
        //releaseSpiResource();
      }
    }
  }

  /***************** SpiResource Events ****************/
  event void SpiResource.granted() {
    int8_t cur_state;
    atomic {
      cur_state = m_state;
    }
    switch( cur_state ) {
      case S_LOAD:
        loadTXFIFO();
        break;

      case S_BEGIN_TRANSMIT:
        attemptSend();
        break;

      case S_CANCEL:
        call CSN.clr();  call SFTX.strobe();  call CSN.set();
        releaseSpiResource();
        atomic {
          m_state = S_STARTED;
        }
        signal Send.sendDone( m_msg, ECANCEL );
        break;

      default:
        releaseSpiResource();
        break;
    }
  }
  
  /***************** TXFIFO Events ****************/
  /**
   * The TXFIFO is used to load packets into the transmit buffer on the
   * chip
   */
  async event void TXFIFO.writeDone( uint8_t* tx_buf, uint8_t tx_len,
                                     error_t error ) {
    uint8_t chip_status = 0;
    call CSN.set();

    atomic {
      call CSN.clr();  chip_status = call SNOP.strobe();  call CSN.set();
    }
    chip_status = chip_status >> 4;
    if( chip_status == S_TX_FIFO_ERROR ){
      flush();
      releaseSpiResource();
      signalDone(FAIL);
      return;
    }

    if ( m_state == S_CANCEL ) {
      atomic {
        call CSN.clr();  call SFTX.strobe();  call CSN.set();
      }
      releaseSpiResource();
      atomic m_state = S_STARTED;
      signal Send.sendDone( m_msg, ECANCEL );
      
    } else if ( !m_cca ) {
      atomic {
        m_state = S_BEGIN_TRANSMIT;
      }
      attemptSend();
    } else {
      releaseSpiResource();
      atomic m_state = S_SAMPLE_CCA;
      signal RadioBackoff.requestInitialBackoff(m_msg);
      call BackoffTimer.start(myInitialBackoff);
    }
  }

  
  async event void TXFIFO.readDone( uint8_t* tx_buf, uint8_t tx_len, 
      error_t error ) {
  }
  
  
  /***************** Timer Events ****************/
  /**
   * The backoff timer is mainly used to wait for a moment before trying
   * to send a packet again. But we also use it to timeout the wait for
   * an acknowledgement, and timeout the wait for an SFD interrupt when
   * we should have gotten one.
   */
  async event void BackoffTimer.fired() {
    atomic {
      switch( m_state ) {
        
      case S_SAMPLE_CCA : 
        // sample CCA and wait a little longer if free, just in case we
        // sampled during the ack turn-around window
        if ( call CCA.get() == 0 ) {
          m_state = S_BEGIN_TRANSMIT;
	  call BackoffTimer.start( CC1200_TIME_ACK_TURNAROUND );
        } else {
          congestionBackoff();
        }
        break;
        
      case S_BEGIN_TRANSMIT:
      case S_CANCEL:
        if( acquireSpiResource() == SUCCESS ) {
          attemptSend();
        }
        break;
        
      case S_ACK_WAIT:
        signalDone( SUCCESS );
        break;

      case S_SFD:
        // We didn't receive an SFD interrupt within CC1200_ABORT_PERIOD
        // jiffies. Assume something is wrong.
        //call CaptureSFD.captureRisingEdge();
        //call BackoffTimer.stop();
        signalDone( FAIL );
        //releaseSpiResource();
        break;

      default:
        break;
      }
    }
  }
      
  /***************** Functions ****************/

  /**
   * Flush out the Tx FIFO
   */
  void flush() {
    uint16_t first = 0, last = 0;
    atomic {
      call CSN.clr();  call SFTX.strobe();  call CSN.set();
    }

    call CSN.clr();  call TXFIRST.read(&first);  call CSN.set();
    call CSN.clr();  call TXLAST.read(&last);  call CSN.set();
    while ( 1 ) {
      if ( first == last ) break;
        call CSN.clr();  call TXFIRST.read(&first);  call CSN.set();
        call CSN.clr();  call TXLAST.read(&last);  call CSN.set();
    }

    call CSN.clr();  call SRX.strobe();   call CSN.set();
  }

  /**
   * Set up a message to be sent. First load it into the outbound tx buffer
   * on the chip, then attempt to send it.
   * @param *p_msg Pointer to the message that needs to be sent
   * @param cca TRUE if this transmit should use clear channel assessment
   */
  error_t send( message_t* ONE p_msg, bool cca ) {
    atomic {
      if (m_state == S_CANCEL) {
        return ECANCEL;
      }
      
      if ( m_state != S_STARTED ) {
        return FAIL;
      }
      
      m_state = S_LOAD;
      m_cca = cca;
      m_msg = p_msg;
      totalCcaChecks = 0;
    }
    if( acquireSpiResource() == SUCCESS ) {
      loadTXFIFO();
    }
    return SUCCESS;
  }
  
  /**
   * Resend a packet that already exists in the outbound tx buffer on the
   * chip
   * @param cca TRUE if this transmit should use clear channel assessment
   */
  error_t resend( bool cca ) {
    atomic {
      if (m_state == S_CANCEL) {
        return ECANCEL;
      }
      
      if ( m_state != S_STARTED ) {
        return FAIL;
      }
      
      m_cca = cca;
      m_state = cca ? S_SAMPLE_CCA : S_BEGIN_TRANSMIT;
      totalCcaChecks = 0;
    }
    
    if(m_cca) {
      signal RadioBackoff.requestInitialBackoff(m_msg);
      call BackoffTimer.start( myInitialBackoff );
      
    } else if ( acquireSpiResource() == SUCCESS ) {
      attemptSend();
    }
    return SUCCESS;
  }

  /**
   * Attempt to send the packet we have loaded into the tx buffer on 
   * the radio chip.  The STXONCCA will send the packet immediately if
   * the channel is clear.  If we're not concerned about whether or not
   * the channel is clear (i.e. m_cca == FALSE), then STXON will send the
   * packet without checking for a clear channel.
   *
   * If the packet didn't get sent, then congestion == TRUE.  In that case,
   * we reset the backoff timer and try again in a moment.
   *
   * If the packet got sent, we should expect an SFD interrupt to take
   * over, signifying the packet is getting sent.
   * 
   * If security is enabled, STXONCCA or STXON will perform inline security
   * options before transmitting the packet.
   */
  void attemptSend() {
    uint8_t state = 0;
    uint16_t first = 0, last = 0;
    atomic {
      if (m_state == S_CANCEL) {
        call CSN.clr();  call SFTX.strobe();  call CSN.set();
        releaseSpiResource();
        signalDone( ECANCEL );
      }
      else{
        call CSN.clr();  state = call SNOP.strobe();  call CSN.set();
        if ( state == S_TX ) {
          call CSN.clr();  call SIDLE.strobe();  call CSN.set();
        }

        if ( call CCA.get() == 0 ) {
          call CSN.clr();  call STX.strobe();  call CSN.set();

          call CSN.clr();  call TXFIRST.read(&first);  call CSN.set();
          call CSN.clr();  call TXLAST.read(&last);  call CSN.set();
          while ( 1 ) {
            if ( first == last ) break;
            call CSN.clr();  call TXFIRST.read(&first);  call CSN.set();
            call CSN.clr();  call TXLAST.read(&last);  call CSN.set();
	  }
          call Leds.led2Off();

          atomic m_state = S_SFD;
          call BackoffTimer.start(CC1200_ABORT_PERIOD);
          releaseSpiResource();
        } else {
          atomic m_state = S_SAMPLE_CCA;
          releaseSpiResource();
          congestionBackoff();
        }
      }
    }
  }
  
  
  /**  
   * Congestion Backoff
   */
  void congestionBackoff() {
    atomic {
      signal RadioBackoff.requestCongestionBackoff(m_msg);
      call BackoffTimer.start(myCongestionBackoff);
    }
  }
  
  error_t acquireSpiResource() {
    error_t error = call SpiResource.immediateRequest();
    if ( error != SUCCESS ) {
      call SpiResource.request();
    }
    return error;
  }

  error_t releaseSpiResource() {
    call SpiResource.release();
    return SUCCESS;
  }


  /** 
   * Setup the packet transmission power and load the tx fifo buffer on
   * the chip with our outbound packet.  
   *
   * Warning: the tx_power metadata might not be initialized and
   * could be a value other than 0 on boot.  Verification is needed here
   * to make sure the value won't overstep its bounds in the TXCTRL register
   * and is transmitting at max power by default.
   *
   * It should be possible to manually calculate the packet's CRC here and
   * tack it onto the end of the header + payload when loading into the TXFIFO,
   * so the continuous modulation low power listening strategy will continually
   * deliver valid packets.  This would increase receive reliability for
   * mobile nodes and lossy connections.  The crcByte() function should use
   * the same CRC polynomial as the CC1200's AUTOCRC functionality.
   */

  void loadTXFIFO() {
    cc1200_header_t* header = call CC1200PacketBody.getHeader( m_msg );
    uint8_t tmpLen __DEPUTY_UNUSED__ = header->length - 1;

    atomic{
      call Leds.led2On();
      header->length = header->length-2;
      call CSN.clr();
      call TXFIFO.write( (uint8_t*)header, tmpLen);
//      memcpy(&txBuffer[ 1 ], header, tmpLen);
//      txBuffer[ 0 ] = tmpLen;
//      call CSN.clr();
//      call TXFIFO.write(txBuffer, tmpLen + 1);

    }
  }
  
  void signalDone( error_t err ) {
    atomic m_state = S_STARTED;
    abortSpiRelease = FALSE;
    call ChipSpiResource.attemptRelease();
    signal Send.sendDone( m_msg, err );
  }

}

