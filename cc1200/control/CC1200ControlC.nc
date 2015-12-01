
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

  CC1200ControlP.IOCFG2  -> Spi.IOCFG2;

  components new CC1200SpiC() as SyncSpiC;
  CC1200ControlP.SyncResource -> SyncSpiC;

  components new CC1200SpiC() as RssiResource;
  CC1200ControlP.RssiResource -> RssiResource;
  
  components ActiveMessageAddressC;
  CC1200ControlP.ActiveMessageAddress -> ActiveMessageAddressC;

  components LocalIeeeEui64C;
  CC1200ControlP.LocalIeeeEui64 -> LocalIeeeEui64C;

}

