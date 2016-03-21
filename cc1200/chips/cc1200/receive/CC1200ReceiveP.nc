
#include "IEEE802154.h"
#include "message.h"
#include "AM.h"

module CC1200ReceiveP @safe() {

  provides interface Init;
  provides interface StdControl;
  provides interface CC1200Receive;
  provides interface Receive;
  provides interface ReceiveIndicator as PacketIndicator;

  uses interface GeneralIO as CSN;
  uses interface GeneralIO as FIFO;
  uses interface GeneralIO as FIFOP;
  uses interface GpioInterrupt as InterruptFIFOP;

  uses interface Resource as SpiResource;
  uses interface CC1200Fifo as RXFIFO;
  uses interface CC1200Strobe as SACK;
  uses interface CC1200Strobe as SFLUSHRX;
  uses interface CC1200Packet;
  uses interface CC1200PacketBody;
  uses interface CC1200Config;
  uses interface PacketTimeStamp<T32khz,uint32_t>;

  uses interface CC1200Strobe as SRXDEC;
  uses interface CC1200Register as SECCTRL0;
  uses interface CC1200Register as SECCTRL1;
  uses interface CC1200Ram as KEY0;
  uses interface CC1200Ram as KEY1;
  uses interface CC1200Ram as RXNONCE;
  uses interface CC1200Ram as RXFIFO_RAM;
  uses interface CC1200Strobe as SNOP;

  // Create by TJ
  uses interface CC1200Strobe as SRES;
  uses interface CC1200Strobe as SRX;
  uses interface CC1200Strobe as SFRX;
  uses interface CC1200Strobe as SFTX;
  uses interface CC1200Strobe as SIDLE;
  uses interface CC1200Register as NUM_RXBYTES;
  uses interface CC1200Register as MARCSTATE;
  uses interface CC1200Register as RXLAST;
  uses interface CC1200Register as RXFIRST;
  uses interface Leds;
}

implementation {

  typedef enum {
    S_STOPPED,
    S_STARTED,
    S_RX_LENGTH,
    S_RX_DEC,
    S_RX_DEC_WAIT,
    S_RX_FCF,
    S_RX_PAYLOAD,
    S_RX_ERROR,
  } cc1200_receive_state_t;

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

  enum {
    RXFIFO_SIZE = 128,
    TIMESTAMP_QUEUE_SIZE = 8,
    SACK_HEADER_LENGTH = 7,
  };

  uint32_t m_timestamp_queue[ TIMESTAMP_QUEUE_SIZE ];

  norace uint8_t m_timestamp_head;
  
  norace uint8_t m_timestamp_size;
  
  /** Number of packets we missed because we were doing something else */
  norace uint8_t m_missed_packets;

  /** TRUE if we are receiving a valid packet into the stack */
  bool receivingPacket;
  
  /** The length of the frame we're currently receiving */
  norace uint8_t rxFrameLength;
  
  norace uint8_t m_bytes_left;
  
  norace message_t* ONE_NOK m_p_rx_buf;

  message_t m_rx_buf;
#ifdef CC1200_HW_SECURITY
  norace cc1200_receive_state_t m_state;
  norace uint8_t packetLength = 0;
  norace uint8_t pos = 0;
  norace uint8_t secHdrPos = 0;
  uint8_t nonceValue[16] = {0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01};
  norace uint8_t skip;
  norace uint8_t securityOn = 0;
  norace uint8_t authentication = 0;
  norace uint8_t micLength = 0;
  uint8_t flush_flag = 0;
  uint16_t startTime = 0;

  void beginDec();
  void dec();
#else
  cc1200_receive_state_t m_state;
#endif

  /***************** Prototypes ****************/
  void reset_state();
  void beginReceive();
  void receive();
  void waitForNextPacket();
  void flush();
  bool passesAddressCheck(message_t * ONE msg);

  task void receiveDone_task();
  void InterruptTask();

  /***************** Init Commands ****************/
  command error_t Init.init() {
    m_p_rx_buf = &m_rx_buf;
    return SUCCESS;
  }

  /***************** StdControl ****************/
  command error_t StdControl.start() {
    atomic {
      reset_state();
      m_state = S_STARTED;
      atomic receivingPacket = FALSE;
      /* Note:
         We use the falling edge because the FIFOP polarity is reversed. 
         This is done in CC1200Power.startOscillator from CC1200ControlP.nc.
       */
      call InterruptFIFOP.enableFallingEdge();
    }
    return SUCCESS;
  }
  
  command error_t StdControl.stop() {
    atomic {
      m_state = S_STOPPED;
      reset_state();
      call CSN.set();
      call InterruptFIFOP.disable();
    }
    return SUCCESS;
  }

  /***************** CC1200Receive Commands ****************/
  /**
   * Start frame delimiter signifies the beginning/end of a packet
   * See the CC1200 datasheet for details.
   */
  async command void CC1200Receive.sfd( uint32_t time ) {
    if ( m_timestamp_size < TIMESTAMP_QUEUE_SIZE ) {
      uint8_t tail =  ( ( m_timestamp_head + m_timestamp_size ) % 
                        TIMESTAMP_QUEUE_SIZE );
      m_timestamp_queue[ tail ] = time;
      m_timestamp_size++;
    }
  }

  async command void CC1200Receive.sfd_dropped() {
    if ( m_timestamp_size ) {
      m_timestamp_size--;
    }
  }

  /***************** PacketIndicator Commands ****************/
  command bool PacketIndicator.isReceiving() {
    bool receiving;
    atomic {
      receiving = receivingPacket;
    }
    return receiving;
  }


  /***************** InterruptFIFOP Events ****************/
  uint8_t rxbuff[300];
  uint8_t errbuff[300];
  uint16_t readReg = 0xff;
  uint8_t cnt=0;
  async event void InterruptFIFOP.fired() {
    if ( m_state == S_STARTED ) {
      m_state = S_RX_LENGTH;
      beginReceive();
    } else {
      m_missed_packets++;
    }
  }

  /***************** SpiResource Events ****************/
  event void SpiResource.granted() {
    receive();
  }
  
  /***************** RXFIFO Events ****************/
  /**
   * We received some bytes from the SPI bus.  Process them in the context
   * of the state we're in.  Remember the length byte is not part of the length
   */
  async event void RXFIFO.readDone( uint8_t* rx_buf, uint8_t rx_len,
                                    error_t error ) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader( m_p_rx_buf );
    uint8_t tmpLen __DEPUTY_UNUSED__ = sizeof(message_t) - 
              (offsetof(message_t, data) - sizeof(cc1200_header_t));
    uint8_t* COUNT(tmpLen) buf = TCAST(uint8_t* COUNT(tmpLen), header);

    call CSN.set();
    rxFrameLength = buf[ 0 ];

    switch ( m_state ) {
    case S_RX_LENGTH:
      m_state = S_RX_FCF;
      if ( rxFrameLength + 1 > m_bytes_left ) {
        m_state = S_RX_ERROR;
        atomic receivingPacket = FALSE;
        
        call RXFIFO.beginRead ( errbuff, m_bytes_left);

        //call CSN.clr(); call SRX.strobe();  call CSN.set();
        //waitForNextPacket();

        //flush();
      } else {
        //if ( !call FIFO.get() && !call FIFOP.get() ) {
        //  m_bytes_left -= rxFrameLength + 1;
        //}
        if ( rxFrameLength <= MAC_PACKET_SIZE ) {
          if ( rxFrameLength > 0 ) {
            //if( rxFrameLength > SACK_HEADER_LENGTH ) {
            //  call RXFIFO.continueRead(buf + 1, SACK_HEADER_LENGTH);    
            //} else {
            m_state = S_RX_PAYLOAD;
            call CSN.clr();
            //call RXFIFO.beginRead ( &rxbuff[1], rxFrameLength + 2);
            call RXFIFO.beginRead ( &buf[1], rxFrameLength+2); // + 2 = CRC
          } else {
            atomic receivingPacket = FALSE;
            //call CSN.set();
            //call SpiResource.release();
            call CSN.clr(); call SRX.strobe();  call CSN.set();
            waitForNextPacket();
          }
        } else {
          atomic receivingPacket = FALSE;
          call CSN.clr(); call SRX.strobe();  call CSN.set();
          waitForNextPacket();
          //flush();
        }
      }
      break;
/*
    case S_RX_FCF:
      m_state = S_RX_PAYLOAD;
      if ( call CC1200Config.isAutoAckEnabled() &&
           !call CC1200Config.isHwAutoAckDefault() ) {

//        if ( ( ( ( header->fcf >> IEEE154_FCF_ACK_REQ ) & 0x01 ) == 1 )
//           && ( ( header->dest == call CC1200Config.getShortAddr() )
//             || ( header->dest == AM_BROADCAST_ADDR ) )
//           && ( ( ( header ->fcf >> IEEE154_FCF_FRAME_TYPE ) & 7 ) 
//             == IEEE154_TYPE_DATA ) ) {
//        call CSN.set();
//        call CSN.clr();
//        call SACK.strobe();
//        call CSN.set();
//        call CSN.clr();
//        call RXFIFO.beginRead(buf + 1 + SACK_HEADER_LENGTH,
//                              rxFrameLength - SACK_HEADER_LENGTH);

        return;
      }
      call RXFIFO.continueRead(buf + 1 + SACK_HEADER_LENGTH,
                               rxFrameLength - SACK_HEADER_LENGTH);
      break;
*/
    case S_RX_PAYLOAD:
//      if ( !m_missed_packets ) {
//        call SpiResource.release();
//      }

//      if ( ( buf[ rxFrameLength ] >> 7 ) && rx_buf ) 
      {
        uint8_t type = ( header->fcf >> IEEE154_FCF_FRAME_TYPE ) & 7;
//        signal CC1200Receive.receive( type, m_p_rx_buf );
        if ( type == IEEE154_TYPE_DATA ) {
          header->length = header->length+2;
          post receiveDone_task();
          return;
        }
      }

      waitForNextPacket();
      break;

    default:
      call Leds.led0Off();
      atomic receivingPacket = FALSE;
      //call CSN.set();
      //call SpiResource.release();
      call CSN.clr(); call SRX.strobe();  call CSN.set();
      waitForNextPacket();
      break;
    }

  }

  async event void RXFIFO.writeDone( uint8_t* tx_buf, uint8_t tx_len, error_t error ) {
  }  
  
  /***************** Tasks *****************/
  /**
   * Fill in metadata details, pass the packet up the stack, and
   * get the next packet.
   */
  task void receiveDone_task() {
    cc1200_metadata_t* metadata = 
      call CC1200PacketBody.getMetadata( m_p_rx_buf );
    cc1200_header_t* header = call CC1200PacketBody.getHeader( m_p_rx_buf);
    uint8_t length = header->length;
    uint8_t tmpLen __DEPUTY_UNUSED__ = 
      sizeof(message_t) - (offsetof(message_t, data) - sizeof(cc1200_header_t));
    uint8_t* COUNT(tmpLen) buf = TCAST(uint8_t* COUNT(tmpLen), header);

    metadata->crc = buf[ length ] >> 7;
    metadata->lqi = buf[ length ] & 0x7f;
    metadata->rssi = buf[ length - 1 ];

    if (passesAddressCheck(m_p_rx_buf) && length >= CC1200_SIZE) {
      m_p_rx_buf = signal Receive.receive( m_p_rx_buf, m_p_rx_buf->data,
                                         length - CC1200_SIZE);
    }
    atomic receivingPacket = FALSE;
    waitForNextPacket();
  }

  /****************** CC1200Config Events ****************/
  event void CC1200Config.syncDone( error_t error ) {
  }
  
  /****************** Functions ****************/
  /**
   * Attempt to acquire the SPI bus to receive a packet.
   */
  void beginReceive() { 
    m_state = S_RX_LENGTH;
    atomic receivingPacket = TRUE;
    if ( call SpiResource.isOwner() ) {
      receive();
    } else if ( call SpiResource.immediateRequest() == SUCCESS ) {
      receive();
    } else {
      call SpiResource.request();
    }
  }
  
  /**
   * Flush out the Rx FIFO
   */
  void flush() {
//    uint8_t state = 0;
    uint16_t first = 0, last = 0;
    reset_state();

    call CSN.set();
    call CSN.clr();  call SFRX.strobe();  call CSN.set();

    call CSN.clr();  call RXFIRST.read(&first);  call CSN.set();
    call CSN.clr();  call RXLAST.read(&last);  call CSN.set();
    while ( 1 ) {
      if ( first == last ) break;
      call CSN.clr();  call RXFIRST.read(&first);  call CSN.set();
      call CSN.clr();  call RXLAST.read(&last);  call CSN.set();
    }

    call CSN.clr(); call SRX.strobe();  call CSN.set();
    waitForNextPacket();
  }
  
  /**
   * The first byte of each packet is the length byte.  Read in that single
   * byte, and then read in the rest of the packet.  The CC1200 could contain
   * multiple packets that have been buffered up, so if something goes wrong, 
   * we necessarily want to flush out the FIFO unless we have to.
   */
  void receive() {
    uint8_t chip_status=0;
    call CSN.clr();  call NUM_RXBYTES.read(&readReg);  call CSN.set();
    if(readReg == 0) {
      signal CC1200Receive.receive(S_TX, NULL);// TXDONE
      waitForNextPacket();
    }
    else {
  call Leds.led1On();
      call CSN.clr();  chip_status = call SNOP.strobe();  call CSN.set();
      chip_status = chip_status >> 4;
      if(chip_status == S_RX_FIFO_ERROR) {
        flush();
        return;
      }
      call CSN.clr();
      call RXFIFO.beginRead ( (uint8_t*)(call CC1200PacketBody.getHeader( m_p_rx_buf )), 1);
    }
  }

  /**
   * Determine if there's a packet ready to go, or if we should do nothing
   * until the next packet arrives
   */
  void waitForNextPacket() {
    atomic {
      if ( m_state == S_STOPPED ) {
        call SpiResource.release();
        //call CSN.clr();  call SRX.strobe();  call CSN.set();
        return;
      }
      atomic receivingPacket = FALSE;

      //if ( ( m_missed_packets && call FIFO.get() ) || !call FIFOP.get() ) {
      if ( m_missed_packets ) {
        m_missed_packets--;
        beginReceive();
      } else {
        m_state = S_STARTED;
        m_missed_packets = 0;
        //call CSN.clr();  call SRX.strobe();  call CSN.set();
        call SpiResource.release();
  call Leds.led1Off();
      }
    }
  }
  
  /**
   * Reset this component
   */
  void reset_state() {
    m_bytes_left = RXFIFO_SIZE;
    atomic receivingPacket = FALSE;
    m_timestamp_head = 0;
    m_timestamp_size = 0;
    m_missed_packets = 0;
  }

  /**
   * @return TRUE if the given message passes address recognition
   */
  bool passesAddressCheck(message_t *msg) {
    cc1200_header_t *header = call CC1200PacketBody.getHeader( msg );
    int mode = (header->fcf >> IEEE154_FCF_DEST_ADDR_MODE) & 3;
    ieee_eui64_t *ext_addr;  

    if(!(call CC1200Config.isAddressRecognitionEnabled())) {
      return TRUE;
    }

    if (mode == IEEE154_ADDR_SHORT) {
      return (header->dest == call CC1200Config.getShortAddr()
              || header->dest == IEEE154_BROADCAST_ADDR);
    } else if (mode == IEEE154_ADDR_EXT) {
      ieee_eui64_t local_addr = (call CC1200Config.getExtAddr());
      ext_addr = TCAST(ieee_eui64_t* ONE, &header->dest);
      return (memcmp(ext_addr->data, local_addr.data, IEEE_EUI64_LENGTH) == 0);
    } else {
      /* reject frames with either no address or invalid type */
      return FALSE;
    }
  }

}
