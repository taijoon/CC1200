
#include <Ieee154.h>
#include "Timer.h"

module CC1200ControlP @safe() {

  provides interface Init;
  provides interface Resource;
  provides interface CC1200Config;
  provides interface CC1200Power;
  provides interface Read<uint16_t> as ReadRssi;

  uses interface LocalIeeeEui64;

  uses interface Alarm<T32khz,uint32_t> as StartupTimer;
  uses interface GeneralIO as CSN;
  uses interface GeneralIO as RSTN;
  uses interface GeneralIO as VREN;
  uses interface GpioInterrupt as InterruptCCA;
  uses interface ActiveMessageAddress;

  uses interface CC1200Ram as IEEEADR;
  uses interface CC1200Ram as PANID;
  uses interface CC1200Register as FSCTRL;
  uses interface CC1200Register as IOCFG0;
  uses interface CC1200Register as IOCFG1;
  uses interface CC1200Register as MDMCTRL0;
  uses interface CC1200Register as MDMCTRL1;
  uses interface CC1200Register as RXCTRL1;
  uses interface CC1200Register as RSSI;
  uses interface CC1200Register as TXCTRL;
  uses interface CC1200Strobe as SRXON;
  uses interface CC1200Strobe as SRFOFF;
  uses interface CC1200Strobe as SXOSCOFF;
  uses interface CC1200Strobe as SXOSCON;

	// TJ ADD
  uses interface CC1200Strobe as SRES;
  uses interface CC1200Strobe as SFSTXON;

  uses interface CC1200Register as IOCFG3;
  uses interface CC1200Register as IOCFG2;
  uses interface CC1200Register as DEVIATION_M;
  uses interface CC1200Register as MODCFG_DEV_E;
  uses interface CC1200Register as DCFILT_CFG;
  uses interface CC1200Register as PREAMBLE_CFG0;
  uses interface CC1200Register as IQIC;
  uses interface CC1200Register as CHAN_BW;
  uses interface CC1200Register as MDMCFG1;
  uses interface CC1200Register as MDMCFG0;
  uses interface CC1200Register as SYMBOL_RATE2;
  uses interface CC1200Register as SYMBOL_RATE1;
  uses interface CC1200Register as SYMBOL_RATE0;
  uses interface CC1200Register as AGC_REF;
  uses interface CC1200Register as AGC_CS_THR;
  uses interface CC1200Register as AGC_CFG1;
  uses interface CC1200Register as AGC_CFG0;
  uses interface CC1200Register as FIFO_CFG;
  uses interface CC1200Register as FS_CFG;
  uses interface CC1200Register as PKT_CFG0;
  uses interface CC1200Register as PA_CFG1;
  uses interface CC1200Register as PKT_LEN;
  uses interface CC1200Register as IF_MIX_CFG;
  uses interface CC1200Register as FREQOFF_CFG;
  uses interface CC1200Register as MDMCFG2;
  uses interface CC1200Register as FREQ2;
  uses interface CC1200Register as FREQ1;
  uses interface CC1200Register as FREQ0;
  uses interface CC1200Register as FS_DIG1;
  uses interface CC1200Register as FS_DIG0;
  uses interface CC1200Register as FS_CAL1;
  uses interface CC1200Register as FS_CAL0;
  uses interface CC1200Register as FS_DIVTWO;
  uses interface CC1200Register as FS_DSM0;
  uses interface CC1200Register as FS_DVC0;
  uses interface CC1200Register as FS_PFD;
  uses interface CC1200Register as FS_PRE;
  uses interface CC1200Register as FS_REG_DIV_CML;
  uses interface CC1200Register as FS_SPARE;
  uses interface CC1200Register as FS_VCO0;
  uses interface CC1200Register as XOSC5;
  uses interface CC1200Register as XOSC1;

  uses interface Resource as SpiResource;
  uses interface Resource as RssiResource;
  uses interface Resource as SyncResource;

  uses interface Leds;

}

implementation {

  typedef enum {
    S_VREG_STOPPED,
    S_VREG_STARTING,
    S_VREG_STARTED,
    S_XOSC_STARTING,
    S_XOSC_STARTED,
  } cc1200_control_state_t;

  uint8_t m_channel;
  
  uint8_t m_tx_power;
  
  uint16_t m_pan;
  
  uint16_t m_short_addr;

  ieee_eui64_t m_ext_addr;
  
  bool m_sync_busy;
  
  /** TRUE if acknowledgments are enabled */
  bool autoAckEnabled;
  
  /** TRUE if acknowledgments are generated in hardware only */
  bool hwAutoAckDefault;
  
  /** TRUE if software or hardware address recognition is enabled */
  bool addressRecognition;
  
  /** TRUE if address recognition should also be performed in hardware */
  bool hwAddressRecognition;
  
  norace cc1200_control_state_t m_state = S_VREG_STOPPED;
  
  /***************** Prototypes ****************/

  void writeFsctrl();
  void writeMdmctrl0();
  void writeId();
  void writeTxctrl();

  task void sync();
  task void syncDone();
    
  /***************** Init Commands ****************/
  command error_t Init.init() {
    int i, t;
    call CSN.makeOutput();
    call RSTN.makeOutput();
    //call VREN.makeOutput();
    
    m_short_addr = call ActiveMessageAddress.amAddress();
    m_ext_addr = call LocalIeeeEui64.getId();
    m_pan = call ActiveMessageAddress.amGroup();
    m_tx_power = CC1200_DEF_RFPOWER;
    m_channel = CC1200_DEF_CHANNEL;
    
    m_ext_addr = call LocalIeeeEui64.getId();
    for (i = 0; i < 4; i++) {
      t = m_ext_addr.data[i];
      m_ext_addr.data[i] = m_ext_addr.data[7-i];
      m_ext_addr.data[7-i] = t;
    }


#if defined(CC1200_NO_ADDRESS_RECOGNITION)
    addressRecognition = FALSE;
#else
    addressRecognition = TRUE;
#endif
    
#if defined(CC1200_HW_ADDRESS_RECOGNITION)
    hwAddressRecognition = TRUE;
#else
    hwAddressRecognition = FALSE;
#endif
    
    
#if defined(CC1200_NO_ACKNOWLEDGEMENTS)
    autoAckEnabled = FALSE;
#else
    autoAckEnabled = TRUE;
#endif
    
#if defined(CC1200_HW_ACKNOWLEDGEMENTS)
    hwAutoAckDefault = TRUE;
    hwAddressRecognition = TRUE;
#else
    hwAutoAckDefault = FALSE;
#endif
    
    
    return SUCCESS;
  }

  /***************** Resource Commands ****************/
  async command error_t Resource.immediateRequest() {
    error_t error = call SpiResource.immediateRequest();
    if ( error == SUCCESS ) {
      call CSN.clr();
    }
    return error;
  }

  async command error_t Resource.request() {
    return call SpiResource.request();
  }

  async command bool Resource.isOwner() {
    return call SpiResource.isOwner();
  }

  async command error_t Resource.release() {
    atomic {
      call CSN.set();
      return call SpiResource.release();
    }
  }

  /***************** CC1200Power Commands ****************/
  async command error_t CC1200Power.startVReg() {
    atomic {
      if ( m_state != S_VREG_STOPPED ) {
        return FAIL;
      }
      m_state = S_VREG_STARTING;
    }
    //call VREN.set();
    call StartupTimer.start( CC1200_TIME_VREN );
    return SUCCESS;
  }

  async command error_t CC1200Power.stopVReg() {
    m_state = S_VREG_STOPPED;
    call RSTN.clr();
    call VREN.clr();
    call RSTN.set();
    return SUCCESS;
  }

	uint16_t readReg = 0;
	uint16_t i = 0;
  async command error_t CC1200Power.startOscillator() {
    atomic {

		// Register Write
    call CSN.clr();		call IOCFG3.write(0x0006);		call CSN.set();
    call CSN.clr();		call DEVIATION_M.write(0x00D1);    call CSN.set();
    call CSN.clr();		call MODCFG_DEV_E.write(0x0000);    call CSN.set();
    call CSN.clr();		call DCFILT_CFG.write(0x5D);    call CSN.set();
    call CSN.clr();		call PREAMBLE_CFG0.write(0x008A);    call CSN.set();
    call CSN.clr();		call IQIC.write(0xCB);    call CSN.set();
    call CSN.clr();		call CHAN_BW.write(0xA6);    call CSN.set();
    call CSN.clr();		call MDMCFG1.write(0x40);    call CSN.set();
    call CSN.clr();		call MDMCFG0.write(0x05);    call CSN.set();
    call CSN.clr();		call SYMBOL_RATE2.write(0x3F);    call CSN.set();
    call CSN.clr();		call SYMBOL_RATE1.write(0x75);    call CSN.set();
    call CSN.clr();		call SYMBOL_RATE0.write(0x10);    call CSN.set();
    call CSN.clr();		call AGC_REF.write(0x20);    call CSN.set();
    call CSN.clr();		call AGC_CS_THR.write(0xEC);    call CSN.set();
    call CSN.clr();		call AGC_CFG1.write(0x51);    call CSN.set();
    call CSN.clr();		call AGC_CFG0.write(0xC7);    call CSN.set();
    call CSN.clr();		call FIFO_CFG.write(0x00);    call CSN.set();
    call CSN.clr();		call FS_CFG.write(0x12);    call CSN.set();
    call CSN.clr();		call PKT_CFG0.write(0x20);    call CSN.set();
    call CSN.clr();		call PA_CFG1.write(0x3F);    call CSN.set();
    call CSN.clr();		call PKT_LEN.write(0xFF);    call CSN.set();


		// Register Read
    call CSN.clr();		call IOCFG3.read(&readReg);    call CSN.set();
		if(readReg != 0x0006)		call Leds.led1Off();
		else		readReg = 0;
    call CSN.clr();		call DEVIATION_M.read(&readReg);    call CSN.set();
		if(readReg != 0x00D1)			call Leds.led1Off();
		else		readReg = 0;
    call CSN.clr();		call MODCFG_DEV_E.read(&readReg);    call CSN.set();
		if(readReg != 0x0000)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call DCFILT_CFG.read(&readReg); call CSN.set();
		if(readReg != 0x005D)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call PREAMBLE_CFG0.read(&readReg);	call CSN.set();
		if(readReg != 0x008A)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call IQIC.read(&readReg);	call CSN.set();
		if(readReg != 0x00CB)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call CHAN_BW.read(&readReg);	call CSN.set();
		if(readReg != 0x00A6)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call MDMCFG1.read(&readReg);	call CSN.set();
		if(readReg != 0x0040)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call MDMCFG0.read(&readReg);	call CSN.set();
		if(readReg != 0x0005)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call SYMBOL_RATE2.read(&readReg);	call CSN.set();
		if(readReg != 0x003F)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call SYMBOL_RATE1.read(&readReg);	call CSN.set();
		if(readReg != 0x0075)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call SYMBOL_RATE0.read(&readReg);	call CSN.set();
		if(readReg != 0x0010)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call AGC_REF.read(&readReg);	call CSN.set();
		if(readReg != 0x0020)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call AGC_CS_THR.read(&readReg);	call CSN.set();
		if(readReg != 0x00EC)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call AGC_CFG1.read(&readReg);	call CSN.set();
		if(readReg != 0x0051)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call AGC_CFG0.read(&readReg);	call CSN.set();
		if(readReg != 0x00C7)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FIFO_CFG.read(&readReg);	call CSN.set();
		if(readReg != 0x0000)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_CFG.read(&readReg);	call CSN.set();
		if(readReg != 0x0012)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call PKT_CFG0.read(&readReg);	call CSN.set();
		if(readReg != 0x0020)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call PA_CFG1.read(&readReg);	call CSN.set();
		if(readReg != 0x003F)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call PKT_LEN.read(&readReg);	call CSN.set();
		if(readReg != 0x00FF)			call Leds.led1Off();
		else			readReg = 0;

		// Extended addressd
    call CSN.clr();		call IF_MIX_CFG.write(0x1C);    call CSN.set();
    call CSN.clr();		call FREQOFF_CFG.write(0x22);    call CSN.set();
    call CSN.clr();		call MDMCFG2.write(0x0C);    call CSN.set();
    call CSN.clr();		call FREQ2.write(0x56);    call CSN.set();
    call CSN.clr();		call FREQ1.write(0xCC);    call CSN.set();
    call CSN.clr();		call FREQ0.write(0xCC);    call CSN.set();
    call CSN.clr();		call FS_DIG1.write(0x07);    call CSN.set();
    call CSN.clr();		call FS_DIG0.write(0xAF);    call CSN.set();
    call CSN.clr();		call FS_CAL1.write(0x40);    call CSN.set();
    call CSN.clr();		call FS_CAL0.write(0x0E);    call CSN.set();
    call CSN.clr();		call FS_DIVTWO.write(0x03);    call CSN.set();
    call CSN.clr();		call FS_DSM0.write(0x33);    call CSN.set();
    call CSN.clr();		call FS_DVC0.write(0x17);    call CSN.set();
    call CSN.clr();		call FS_PFD.write(0x00);    call CSN.set();
    call CSN.clr();		call FS_PRE.write(0x6E);    call CSN.set();
    call CSN.clr();		call FS_REG_DIV_CML.write(0x14);    call CSN.set();
    call CSN.clr();		call FS_SPARE.write(0xAC);    call CSN.set();
    call CSN.clr();		call FS_VCO0.write(0xB5);    call CSN.set();
    call CSN.clr();		call XOSC5.write(0x0E);    call CSN.set();
    call CSN.clr();		call XOSC1.write(0x03);    call CSN.set();

    call CSN.clr();		call IF_MIX_CFG.read(&readReg);	call CSN.set();
		if(readReg != 0x001C)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FREQOFF_CFG.read(&readReg);	call CSN.set();
		if(readReg != 0x0022)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call MDMCFG2.read(&readReg);	call CSN.set();
		if(readReg != 0x000C)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FREQ2.read(&readReg);	call CSN.set();
		if(readReg != 0x0056)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FREQ1.read(&readReg);	call CSN.set();
		if(readReg != 0x00CC)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FREQ0.read(&readReg);	call CSN.set();
		if(readReg != 0x00CC)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_DIG1.read(&readReg);	call CSN.set();
		if(readReg != 0x0007)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_DIG0.read(&readReg);	call CSN.set();
		if(readReg != 0x00AF)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_CAL1.read(&readReg);	call CSN.set();
		if(readReg != 0x0040)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_CAL0.read(&readReg);	call CSN.set();
		if(readReg != 0x000E)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_DIVTWO.read(&readReg);	call CSN.set();
		if(readReg != 0x0003)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_DSM0.read(&readReg);	call CSN.set();
		if(readReg != 0x0033)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_DVC0.read(&readReg);	call CSN.set();
		if(readReg != 0x0017)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_PFD.read(&readReg);	call CSN.set();
		if(readReg != 0x0000)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_PRE.read(&readReg);	call CSN.set();
		if(readReg != 0x006E)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_REG_DIV_CML.read(&readReg);	call CSN.set();
		if(readReg != 0x0014)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_SPARE.read(&readReg);	call CSN.set();
		if(readReg != 0x00AC)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call FS_VCO0.read(&readReg);	call CSN.set();
		if(readReg != 0x00B5)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call XOSC5.read(&readReg);	call CSN.set();
		if(readReg != 0x000E)			call Leds.led1Off();
		else			readReg = 0;
    call CSN.clr();		call XOSC1.read(&readReg);	call CSN.set();
		if(readReg != 0x0003)			call Leds.led1Off();
		else			readReg = 0;
    }
		signal InterruptCCA.fired();
		//call CC1200Power.startDone();
		return SUCCESS;
  }


  async command error_t CC1200Power.stopOscillator() {
    atomic {
      if ( m_state != S_XOSC_STARTED ) {
        return FAIL;
      }
      m_state = S_VREG_STARTED;
      call SXOSCOFF.strobe();
    }
    return SUCCESS;
  }

  async command error_t CC1200Power.rxOn() {
    atomic {
      if ( m_state != S_XOSC_STARTED ) {
        return FAIL;
      }
      call SRXON.strobe();
    }
    return SUCCESS;
  }

  async command error_t CC1200Power.rfOff() {
    atomic {  
      if ( m_state != S_XOSC_STARTED ) {
        return FAIL;
      }
      call SRFOFF.strobe();
    }
    return SUCCESS;
  }

  
  /***************** CC1200Config Commands ****************/
  command uint8_t CC1200Config.getChannel() {
    atomic return m_channel;
  }

  command void CC1200Config.setChannel( uint8_t channel ) {
    atomic m_channel = channel;
  }

  command ieee_eui64_t CC1200Config.getExtAddr() {
    return m_ext_addr;
  }

  async command uint16_t CC1200Config.getShortAddr() {
    atomic return m_short_addr;
  }

  command void CC1200Config.setShortAddr( uint16_t addr ) {
    atomic m_short_addr = addr;
  }

  async command uint16_t CC1200Config.getPanAddr() {
    atomic return m_pan;
  }

  command void CC1200Config.setPanAddr( uint16_t pan ) {
    atomic m_pan = pan;
  }

  /**
   * Sync must be called to commit software parameters configured on
   * the microcontroller (through the CC1200Config interface) to the
   * CC1200 radio chip.
   */
  command error_t CC1200Config.sync() {
    atomic {
      if ( m_sync_busy ) {
        return FAIL;
      }
      
      m_sync_busy = TRUE;
      if ( m_state == S_XOSC_STARTED ) {
        call SyncResource.request();
      } else {
        post syncDone();
      }
    }
    return SUCCESS;
  }

  /**
   * @param enableAddressRecognition TRUE to turn address recognition on
   * @param useHwAddressRecognition TRUE to perform address recognition first
   *     in hardware. This doesn't affect software address recognition. The
   *     driver must sync with the chip after changing this value.
   */
  command void CC1200Config.setAddressRecognition(bool enableAddressRecognition, bool useHwAddressRecognition) {
    atomic {
      addressRecognition = enableAddressRecognition;
      hwAddressRecognition = useHwAddressRecognition;
    }
  }
  
  /**
   * @return TRUE if address recognition is enabled
   */
  async command bool CC1200Config.isAddressRecognitionEnabled() {
    atomic return addressRecognition;
  }
  
  /**
   * @return TRUE if address recognition is performed first in hardware.
   */
  async command bool CC1200Config.isHwAddressRecognitionDefault() {
    atomic return hwAddressRecognition;
  }
  
  
  /**
   * Sync must be called for acknowledgement changes to take effect
   * @param enableAutoAck TRUE to enable auto acknowledgements
   * @param hwAutoAck TRUE to default to hardware auto acks, FALSE to
   *     default to software auto acknowledgements
   */
  command void CC1200Config.setAutoAck(bool enableAutoAck, bool hwAutoAck) {
    atomic autoAckEnabled = enableAutoAck;
    atomic hwAutoAckDefault = hwAutoAck;
  }
  
  /**
   * @return TRUE if hardware auto acks are the default, FALSE if software
   *     acks are the default
   */
  async command bool CC1200Config.isHwAutoAckDefault() {
    atomic return hwAutoAckDefault;    
  }
  
  /**
   * @return TRUE if auto acks are enabled
   */
  async command bool CC1200Config.isAutoAckEnabled() {
    atomic return autoAckEnabled;
  }
  
  /***************** ReadRssi Commands ****************/
  command error_t ReadRssi.read() { 
    return call RssiResource.request();
  }
  
  /***************** Spi Resources Events ****************/
  event void SyncResource.granted() {
    //call CSN.clr();
    //call SRFOFF.strobe();
    //writeFsctrl();
    //writeMdmctrl0();
    writeId();
    //call CSN.set();
    //call CSN.clr();
    //call SRXON.strobe();
    //call CSN.set();
    //call SyncResource.release();
    //post syncDone();
  }

  event void SpiResource.granted() {
    call CSN.clr();
    signal Resource.granted();
  }

  event void RssiResource.granted() { 
    uint16_t data = 0;
    call CSN.clr();
    call RSSI.read(&data);
    call CSN.set();
    
    call RssiResource.release();
    data += 0x7f;
    data &= 0x00ff;
    signal ReadRssi.readDone(SUCCESS, data); 
  }
  
  /***************** StartupTimer Events ****************/
  async event void StartupTimer.fired() {
    if ( m_state == S_VREG_STARTING ) {
      m_state = S_VREG_STARTED;
      call RSTN.clr();
      call RSTN.set();
      signal CC1200Power.startVRegDone();
    }
  }

  /***************** InterruptCCA Events ****************/
  async event void InterruptCCA.fired() {
    m_state = S_XOSC_STARTED;
//    call InterruptCCA.disable();
//    call IOCFG1.write( 0 );
    writeId();
//    call CSN.set();
//    call CSN.clr();
    signal CC1200Power.startOscillatorDone();
  }
 
  /***************** ActiveMessageAddress Events ****************/
  async event void ActiveMessageAddress.changed() {
    atomic {
      m_short_addr = call ActiveMessageAddress.amAddress();
      m_pan = call ActiveMessageAddress.amGroup();
    }
    
    post sync();
  }
  
  /***************** Tasks ****************/
  /**
   * Attempt to synchronize our current settings with the CC1200
   */
  task void sync() {
    call CC1200Config.sync();
  }
  
  task void syncDone() {
    atomic m_sync_busy = FALSE;
    signal CC1200Config.syncDone( SUCCESS );
  }
  
  
  /***************** Functions ****************/
  /**
   * Write teh FSCTRL register
   */
  void writeFsctrl() {
    uint8_t channel;
    
    atomic {
      channel = m_channel;
    }
    
    call FSCTRL.write( ( 1 << CC1200_FSCTRL_LOCK_THR ) |
          ( ( (channel - 11)*5+357 ) << CC1200_FSCTRL_FREQ ) );
  }

  /**
   * Write the MDMCTRL0 register
   * Disabling hardware address recognition improves acknowledgment success
   * rate and low power communications reliability by causing the local node
   * to do work while the real destination node of the packet is acknowledging.
   */
  void writeMdmctrl0() {
    atomic {
      call MDMCTRL0.write( ( 1 << CC1200_MDMCTRL0_RESERVED_FRAME_MODE ) |
          ( ((addressRecognition && hwAddressRecognition) ? 1 : 0) << CC1200_MDMCTRL0_ADR_DECODE ) |
          ( 2 << CC1200_MDMCTRL0_CCA_HYST ) |
          ( 3 << CC1200_MDMCTRL0_CCA_MOD ) |
          ( 1 << CC1200_MDMCTRL0_AUTOCRC ) |
          ( (autoAckEnabled && hwAutoAckDefault) << CC1200_MDMCTRL0_AUTOACK ) |
          ( 0 << CC1200_MDMCTRL0_AUTOACK ) |
          ( 2 << CC1200_MDMCTRL0_PREAMBLE_LENGTH ) );
    }
    // Jon Green:
    // MDMCTRL1.CORR_THR is defaulted to 20 instead of 0 like the datasheet says
    // If we add in changes to MDMCTRL1, be sure to include this fix.
  }
  
  /**
   * Write the PANID register
   */
  void writeId() {
    nxle_uint16_t id[ 6 ];

    atomic {
      /* Eui-64 is stored in big endian */
      memcpy((uint8_t *)id, m_ext_addr.data, 8);
      id[ 4 ] = m_pan;
      id[ 5 ] = m_short_addr;
    }

    call IEEEADR.write(0, (uint8_t *)&id, 12);
  }

  /* Write the Transmit control register. This
     is needed so acknowledgments are sent at the
     correct transmit power even if a node has
     not sent a packet (Google Code Issue #27) -pal */

  void writeTxctrl() {
    atomic {
      call TXCTRL.write( ( 2 << CC1200_TXCTRL_TXMIXBUF_CUR ) |
			 ( 3 << CC1200_TXCTRL_PA_CURRENT ) |
			 ( 1 << CC1200_TXCTRL_RESERVED ) |
			 ( (CC1200_DEF_RFPOWER & 0x1F) << CC1200_TXCTRL_PA_LEVEL ) );
    }
  }
  /***************** Defaults ****************/
  default event void CC1200Config.syncDone( error_t error ) {
  }

  default event void ReadRssi.readDone(error_t error, uint16_t data) {
  }
  
}
