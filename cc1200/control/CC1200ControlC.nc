
#include "CC1200.h"
#include "cc120x_spi.h"
#include "IEEE802154.h"

configuration CC1200ControlC {

  provides interface Resource;
  provides interface CC1200Config;
  provides interface CC1200Power;
  provides interface Read<uint16_t> as ReadRssi;
}

implementation {
  
  components CC1200ControlP;
  Resource = CC1200ControlP;
  CC1200Config = CC1200ControlP;
  CC1200Power = CC1200ControlP;
  ReadRssi = CC1200ControlP;

  components MainC;
  MainC.SoftwareInit -> CC1200ControlP;
  
  components AlarmMultiplexC as Alarm;
  CC1200ControlP.StartupTimer -> Alarm;

  components HplCC1200PinsC as Pins;
  CC1200ControlP.CSN -> Pins.CSN;
  CC1200ControlP.RSTN -> Pins.RSTN;
  CC1200ControlP.VREN -> Pins.VREN;

  components HplCC1200InterruptsC as Interrupts;
  CC1200ControlP.InterruptCCA -> Interrupts.InterruptCCA;

  components new CC1200SpiC() as Spi;
  CC1200ControlP.SpiResource -> Spi;
  CC1200ControlP.SRXON -> Spi.SRXON;
  CC1200ControlP.SRFOFF -> Spi.SRFOFF;
  CC1200ControlP.SXOSCON -> Spi.SXOSCON;
  CC1200ControlP.SXOSCOFF -> Spi.SXOSCOFF;
  CC1200ControlP.FSCTRL -> Spi.FSCTRL;
  CC1200ControlP.IOCFG0 -> Spi.IOCFG0;
  CC1200ControlP.IOCFG1 -> Spi.IOCFG1;
  CC1200ControlP.MDMCTRL0 -> Spi.MDMCTRL0;
  CC1200ControlP.MDMCTRL1 -> Spi.MDMCTRL1;
  CC1200ControlP.PANID -> Spi.PANID;
  CC1200ControlP.IEEEADR -> Spi.IEEEADR;
  CC1200ControlP.RXCTRL1 -> Spi.RXCTRL1;
  CC1200ControlP.RSSI  -> Spi.RSSI;
  CC1200ControlP.TXCTRL  -> Spi.TXCTRL;
	// TJ ADD
  CC1200ControlP.SRES -> Spi.SRES;
  CC1200ControlP.SFSTXON -> Spi.SFSTXON;

  CC1200ControlP.IOCFG3  -> Spi.IOCFG3;
  CC1200ControlP.IOCFG2  -> Spi.IOCFG2;
  CC1200ControlP.DEVIATION_M  -> Spi.DEVIATION_M;
  CC1200ControlP.MODCFG_DEV_E  -> Spi.MODCFG_DEV_E;
  CC1200ControlP.DCFILT_CFG  -> Spi.DCFILT_CFG;
  CC1200ControlP.PREAMBLE_CFG0  -> Spi.PREAMBLE_CFG0;
  CC1200ControlP.IQIC  -> Spi.IQIC;
  CC1200ControlP.CHAN_BW  -> Spi.CHAN_BW;
  CC1200ControlP.MDMCFG1  -> Spi.MDMCFG1;
  CC1200ControlP.MDMCFG0  -> Spi.MDMCFG0;
  CC1200ControlP.SYMBOL_RATE2  -> Spi.SYMBOL_RATE2;
  CC1200ControlP.SYMBOL_RATE1  -> Spi.SYMBOL_RATE1;
  CC1200ControlP.SYMBOL_RATE0  -> Spi.SYMBOL_RATE0;
  CC1200ControlP.AGC_REF  -> Spi.AGC_REF;
  CC1200ControlP.AGC_CS_THR  -> Spi.AGC_CS_THR;
  CC1200ControlP.AGC_CFG1  -> Spi.AGC_CFG1;
  CC1200ControlP.AGC_CFG0  -> Spi.AGC_CFG0;
  CC1200ControlP.FIFO_CFG  -> Spi.FIFO_CFG;
  CC1200ControlP.FS_CFG  -> Spi.FS_CFG;
  CC1200ControlP.PKT_CFG0  -> Spi.PKT_CFG0;
  CC1200ControlP.PA_CFG1  -> Spi.PA_CFG1;
  CC1200ControlP.PKT_LEN  -> Spi.PKT_LEN;
  CC1200ControlP.IF_MIX_CFG  -> Spi.IF_MIX_CFG;
  CC1200ControlP.FREQOFF_CFG  -> Spi.FREQOFF_CFG;
  CC1200ControlP.MDMCFG2  -> Spi.MDMCFG2;
  CC1200ControlP.FREQ2  -> Spi.FREQ2;
  CC1200ControlP.FREQ1  -> Spi.FREQ1;
  CC1200ControlP.FREQ0  -> Spi.FREQ0;
  CC1200ControlP.FS_DIG1  -> Spi.FS_DIG1;
  CC1200ControlP.FS_DIG0  -> Spi.FS_DIG0;
  CC1200ControlP.FS_CAL1  -> Spi.FS_CAL1;
  CC1200ControlP.FS_CAL0  -> Spi.FS_CAL0;
  CC1200ControlP.FS_DIVTWO  -> Spi.FS_DIVTWO;
  CC1200ControlP.FS_DSM0  -> Spi.FS_DSM0;
  CC1200ControlP.FS_DVC0  -> Spi.FS_DVC0;
  CC1200ControlP.FS_PFD  -> Spi.FS_PFD;
  CC1200ControlP.FS_PRE  -> Spi.FS_PRE;
  CC1200ControlP.FS_REG_DIV_CML  -> Spi.FS_REG_DIV_CML;
  CC1200ControlP.FS_SPARE  -> Spi.FS_SPARE;
  CC1200ControlP.FS_VCO0  -> Spi.FS_VCO0;
  CC1200ControlP.XOSC5  -> Spi.XOSC5;
  CC1200ControlP.XOSC1  -> Spi.XOSC1;

  components new CC1200SpiC() as SyncSpiC;
  CC1200ControlP.SyncResource -> SyncSpiC;

  components new CC1200SpiC() as RssiResource;
  CC1200ControlP.RssiResource -> RssiResource;
  
  components ActiveMessageAddressC;
  CC1200ControlP.ActiveMessageAddress -> ActiveMessageAddressC;

  components LocalIeeeEui64C;
  CC1200ControlP.LocalIeeeEui64 -> LocalIeeeEui64C;

	components LedsC;
	CC1200ControlP.Leds -> LedsC;
}

