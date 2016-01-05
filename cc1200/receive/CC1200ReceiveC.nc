
configuration CC1200ReceiveC {

  provides interface StdControl;
  provides interface CC1200Receive;
  provides interface Receive;
  provides interface ReceiveIndicator as PacketIndicator;

}

implementation {
  components MainC;
  components CC1200ReceiveP;
  components CC1200PacketC;
  components new CC1200SpiC() as Spi;
  components CC1200ControlC;
  
  components HplCC1200PinsC as Pins;
  components HplCC1200InterruptsC as InterruptsC;

  components LedsC as Leds;
  CC1200ReceiveP.Leds -> Leds;

  StdControl = CC1200ReceiveP;
  CC1200Receive = CC1200ReceiveP;
  Receive = CC1200ReceiveP;
  PacketIndicator = CC1200ReceiveP.PacketIndicator;

  MainC.SoftwareInit -> CC1200ReceiveP;
  
  CC1200ReceiveP.CSN -> Pins.CSN;
  CC1200ReceiveP.FIFO -> Pins.FIFO;
  CC1200ReceiveP.FIFOP -> Pins.FIFOP;
  CC1200ReceiveP.InterruptFIFOP -> InterruptsC.InterruptFIFOP;
  CC1200ReceiveP.SpiResource -> Spi;
  CC1200ReceiveP.RXFIFO -> Spi.RXFIFO;
  CC1200ReceiveP.SFLUSHRX -> Spi.SFLUSHRX;
  CC1200ReceiveP.SACK -> Spi.SACK;
  CC1200ReceiveP.CC1200Packet -> CC1200PacketC;
  CC1200ReceiveP.CC1200PacketBody -> CC1200PacketC;
  CC1200ReceiveP.PacketTimeStamp -> CC1200PacketC;
  CC1200ReceiveP.CC1200Config -> CC1200ControlC;

	// Create by TJ
  CC1200ReceiveP.SRX -> Spi.SRX;
  CC1200ReceiveP.SFRX -> Spi.SFRX;
  CC1200ReceiveP.NUM_RXBYTES -> Spi.NUM_RXBYTES;
  CC1200ReceiveP.MARCSTATE -> Spi.MARCSTATE;

  CC1200ReceiveP.SECCTRL0 -> Spi.SECCTRL0;
  CC1200ReceiveP.SECCTRL1 -> Spi.SECCTRL1;
  CC1200ReceiveP.SRXDEC -> Spi.SRXDEC;
  CC1200ReceiveP.RXNONCE -> Spi.RXNONCE;
  CC1200ReceiveP.KEY0 -> Spi.KEY0;
  CC1200ReceiveP.KEY1 -> Spi.KEY1;
  CC1200ReceiveP.RXFIFO_RAM -> Spi.RXFIFO_RAM;
  CC1200ReceiveP.SNOP -> Spi.SNOP;
}
