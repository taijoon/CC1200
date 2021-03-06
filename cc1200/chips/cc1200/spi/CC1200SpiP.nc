
module CC1200SpiP @safe() {

  provides {
    interface ChipSpiResource;
    interface Resource[ uint8_t id ];
    interface CC1200Fifo as Fifo[ uint8_t id ];
    interface CC1200Ram as Ram[ uint16_t id ];
    interface CC1200Register as Reg[ uint16_t id ];
    interface CC1200Strobe as Strobe[ uint8_t id ];
  }
  
  uses {
    interface Resource as SpiResource;
    interface SpiByte;
    interface SpiPacket;
    interface State as WorkingState;
    interface Leds;
  }
}

implementation {

  enum {
    RESOURCE_COUNT = uniqueCount( "CC1200Spi.Resource" ),
    NO_HOLDER = 0xFF,
  };

  /** WorkingStates */
  enum {
    S_IDLE,
    S_BUSY,
  };

  /** Address to read/write on the CC1200, also maintains caller's client id */
  norace uint16_t m_addr;
  
  /** Each bit represents a client ID that is requesting SPI bus access */
  norace uint8_t m_requests = 0;
  
  /** The current client that owns the SPI bus */
  norace uint8_t m_holder = NO_HOLDER;
  
  /** TRUE if it is safe to release the SPI bus after all users say ok */
  bool release;
  
  /***************** Prototypes ****************/
  error_t attemptRelease();
  task void grant();
  
  /***************** ChipSpiResource Commands ****************/
  /**
   * Abort the release of the SPI bus.  This must be called only with the
   * releasing() event
   */
  async command void ChipSpiResource.abortRelease() {
    atomic release = FALSE;
  }
  
  /**
   * Release the SPI bus if there are no objections
   */
  async command error_t ChipSpiResource.attemptRelease() {
    return attemptRelease();
  }
  
  /***************** Resource Commands *****************/
  async command error_t Resource.request[ uint8_t id ]() {
        
    atomic {
      if ( call WorkingState.requestState(S_BUSY) == SUCCESS ) {
        m_holder = id;
        if(call SpiResource.isOwner()) {
          post grant();
          
        } else {
          call SpiResource.request();
        }
        
      } else {
        m_requests |= 1 << id;
      }
    }
    return SUCCESS;
  }
  
  async command error_t Resource.immediateRequest[ uint8_t id ]() {
    error_t error;
        
    atomic {
      if ( call WorkingState.requestState(S_BUSY) != SUCCESS ) {
        return EBUSY;
      }
      
      
      if(call SpiResource.isOwner()) {
        m_holder = id;
        error = SUCCESS;
      
      } else if ((error = call SpiResource.immediateRequest()) == SUCCESS ) {
        m_holder = id;
        
      } else {
        call WorkingState.toIdle();
      }
    }
    return error;
  }

  async command error_t Resource.release[ uint8_t id ]() {
    uint8_t i;
    atomic {
      if ( m_holder != id ) {
        return FAIL;
      }

      m_holder = NO_HOLDER;
      if ( !m_requests ) {
        call WorkingState.toIdle();
        attemptRelease();
        
      } else {
        for ( i = m_holder + 1; ; i++ ) {
          i %= RESOURCE_COUNT;
          
          if ( m_requests & ( 1 << i ) ) {
            m_holder = i;
            m_requests &= ~( 1 << i );
            post grant();
            return SUCCESS;
          }
        }
      }
    }
    
    return SUCCESS;
  }
  
  async command bool Resource.isOwner[ uint8_t id ]() {
    atomic return (m_holder == id);
  }


  /***************** SpiResource Events ****************/
  event void SpiResource.granted() {
    post grant();
  }
  
  /***************** Fifo Commands ****************/
  async command cc1200_status_t Fifo.beginRead[ uint8_t addr ]( uint8_t* data, 
                                                                uint8_t len ) {
    cc1200_status_t status = 0;
    
    atomic {
      if(call WorkingState.isIdle()) {
        return status;
      }
    }
    
    m_addr = addr | 0x40;
    status = call SpiByte.write( m_addr );
    
    //while(w_len < len){
    //  data[w_len++] = call SpiByte.write(0x3D);
    //}
    call Fifo.continueRead[ addr ]( data, len );
    return status;
  }

  async command error_t Fifo.continueRead[ uint8_t addr ]( uint8_t* data,
                                                           uint8_t len ) {
    return call SpiPacket.send( NULL, data, len );
  }

  async command cc1200_status_t Fifo.write[ uint8_t addr ]( uint8_t* data, 
                                                            uint8_t len ) {
    uint8_t status = 0;
    atomic {
      if(call WorkingState.isIdle()) {
        return status;
      }
    }
    
    m_addr = addr;

    //status = call SpiByte.write( m_addr);
    status = call SpiByte.write( m_addr );
    call SpiPacket.send( data, NULL, len );
    return status;

  }

  /***************** RAM Commands ****************/
  async command cc1200_status_t Ram.read[ uint16_t addr ]( uint8_t offset,
                                                           uint8_t* data, 
                                                           uint8_t len ) {

    cc1200_status_t status = 0;
/*
    atomic {
      if(call WorkingState.isIdle()) {
        return status;
      }
    }
    
    addr += offset;

    status = call SpiByte.write( addr | 0x80 );
    call SpiByte.write( ( ( addr >> 1 ) & 0xC0 ) | 0x20 );
    for ( ; len; len-- ) {
      *data++ = call SpiByte.write( 0 );
    }
*/
    return status;
  }


  async command cc1200_status_t Ram.write[ uint16_t addr ]( uint8_t offset,
                                                            uint8_t* data, 
                                                            uint8_t len ) {
    cc1200_status_t status = 0;
/*
    uint8_t tmpLen = len;
    uint8_t * COUNT(tmpLen) tmpData = (uint8_t * COUNT(tmpLen))data;

    atomic {
      if(call WorkingState.isIdle()) {
        return status;
      }
    }
    
    addr += offset;

    status = call SpiByte.write( addr | 0x80 );
    call SpiByte.write( ( addr >> 1 ) & 0xc0 );
    for ( ; len; len-- ) {
      call SpiByte.write( tmpData[tmpLen-len] );
    }
*/
    return status;
  }

  /***************** Register Commands ****************/
  async command cc1200_status_t Reg.read[ uint16_t addr ]( uint16_t* data ) {
    cc1200_status_t status = 0;
    
    atomic {
      if(call WorkingState.isIdle()) {
        return status;
      }
    }
    
    if( (addr >> 8) != 0x2F)
      status = call SpiByte.write( addr | 0x80 | 0x40);
    else{
      call SpiByte.write( 0x80 | 0x40 | 0x2F );
      call SpiByte.write( addr );
    }
    *data = call SpiByte.write( 0x3D );
    
    return status;

  }

  async command cc1200_status_t Reg.write[ uint16_t addr ]( uint16_t data ) {
    atomic {
      if(call WorkingState.isIdle()) {
        return 0;
      }
    }
		
    if( (addr >> 8) != 0x2F)
      call SpiByte.write( 0x40 | addr );
    else{
      call SpiByte.write( 0x40 | 0x2F );
      call SpiByte.write( addr );
    }
    if( (data >> 8) != 0x00)
      call SpiByte.write( data >> 8 );
    return call SpiByte.write( data & 0xff );
  }

  /***************** Strobe Commands ****************/
  async command cc1200_status_t Strobe.strobe[ uint8_t addr ]() {
    atomic {
      if(call WorkingState.isIdle()) {
        return 0;
      }
    }
    
    return call SpiByte.write( addr );
  }

  /***************** SpiPacket Events ****************/
  async event void SpiPacket.sendDone( uint8_t* tx_buf, uint8_t* rx_buf, 
                                       uint16_t len, error_t error ) {
    if ( m_addr & 0x80 ) {
      //signal Fifo.readDone[ m_addr & ~0x80 ]( rx_buf, len, error );
      signal Fifo.readDone[ m_addr ]( rx_buf, len, error );
    } else {
      signal Fifo.writeDone[ m_addr ]( tx_buf, len, error );
    }
  }
  
  /***************** Functions ****************/
  error_t attemptRelease() {
    if(m_requests > 0 
        || m_holder != NO_HOLDER 
        || !call WorkingState.isIdle()) {
      return FAIL;
    }
    
    atomic release = TRUE;
    signal ChipSpiResource.releasing();
    atomic {
      if(release) {
        call SpiResource.release();
        return SUCCESS;
      }
    }
    
    return EBUSY;
  }
  
  task void grant() {
    uint8_t holder;
    atomic { 
      holder = m_holder;
    }
    signal Resource.granted[ holder ]();
  }

  /***************** Defaults ****************/
  default event void Resource.granted[ uint8_t id ]() {
  }

  default async event void Fifo.readDone[ uint8_t addr ]( uint8_t* rx_buf, uint8_t rx_len, error_t error ) {
  }
  
  default async event void Fifo.writeDone[ uint8_t addr ]( uint8_t* tx_buf, uint8_t tx_len, error_t error ) {
  }

  default async event void ChipSpiResource.releasing() {
  }
  
}
