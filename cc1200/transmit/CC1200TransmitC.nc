
#include "IEEE802154.h"

configuration CC1200TransmitC {

  provides {
    interface StdControl;
    interface CC1200Transmit;
    interface RadioBackoff;
    interface ReceiveIndicator as EnergyIndicator;
    interface ReceiveIndicator as ByteIndicator;
  }
}

implementation {

  components CC1200TransmitP;
  StdControl = CC1200TransmitP;
  CC1200Transmit = CC1200TransmitP;
  RadioBackoff = CC1200TransmitP;
  EnergyIndicator = CC1200TransmitP.EnergyIndicator;
  ByteIndicator = CC1200TransmitP.ByteIndicator;

  components MainC;
  MainC.SoftwareInit -> CC1200TransmitP;
  MainC.SoftwareInit -> Alarm;
  
  components AlarmMultiplexC as Alarm;
  CC1200TransmitP.BackoffTimer -> Alarm;

  components HplCC1200PinsC as Pins;
  CC1200TransmitP.CCA -> Pins.CCA;
  CC1200TransmitP.CSN -> Pins.CSN;
  CC1200TransmitP.SFD -> Pins.SFD;

  components HplCC1200InterruptsC as Interrupts;
  CC1200TransmitP.CaptureSFD -> Interrupts.CaptureSFD;

  components new CC1200SpiC() as Spi;
  CC1200TransmitP.SpiResource -> Spi;
  CC1200TransmitP.ChipSpiResource -> Spi;
  CC1200TransmitP.SNOP        -> Spi.SNOP;
  CC1200TransmitP.STXON       -> Spi.STXON;
  CC1200TransmitP.STXONCCA    -> Spi.STXONCCA;
  CC1200TransmitP.SFLUSHTX    -> Spi.SFLUSHTX;
  CC1200TransmitP.TXCTRL      -> Spi.TXCTRL;
  CC1200TransmitP.TXFIFO      -> Spi.TXFIFO;
  CC1200TransmitP.TXFIFO_RAM  -> Spi.TXFIFO_RAM;
  CC1200TransmitP.MDMCTRL1    -> Spi.MDMCTRL1;
  CC1200TransmitP.SECCTRL0 -> Spi.SECCTRL0;
  CC1200TransmitP.SECCTRL1 -> Spi.SECCTRL1;
  CC1200TransmitP.STXENC -> Spi.STXENC;
  CC1200TransmitP.TXNONCE -> Spi.TXNONCE;
  CC1200TransmitP.KEY0 -> Spi.KEY0;
  CC1200TransmitP.KEY1 -> Spi.KEY1;
  
  components CC1200ReceiveC;
  CC1200TransmitP.CC1200Receive -> CC1200ReceiveC;
  
  components CC1200PacketC;
  CC1200TransmitP.CC1200Packet -> CC1200PacketC;
  CC1200TransmitP.CC1200PacketBody -> CC1200PacketC;
  CC1200TransmitP.PacketTimeStamp -> CC1200PacketC;
  CC1200TransmitP.PacketTimeSyncOffset -> CC1200PacketC;

  components LedsC;
  CC1200TransmitP.Leds -> LedsC;

}
