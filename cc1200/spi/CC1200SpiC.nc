
generic configuration CC1200SpiC() {

  provides interface Resource;
  provides interface ChipSpiResource;

  // commands
  provides interface CC1200Strobe as SNOP;
  provides interface CC1200Strobe as SXOSCON;
  provides interface CC1200Strobe as STXCAL;
  provides interface CC1200Strobe as SRXON;
  provides interface CC1200Strobe as STXON;
  provides interface CC1200Strobe as STXONCCA;
  provides interface CC1200Strobe as SRFOFF;
  provides interface CC1200Strobe as SXOSCOFF;
  provides interface CC1200Strobe as SFLUSHRX;
  provides interface CC1200Strobe as SFLUSHTX;
  provides interface CC1200Strobe as SACK;
  provides interface CC1200Strobe as SACKPEND;
  provides interface CC1200Strobe as SRXDEC;
  provides interface CC1200Strobe as STXENC;
  provides interface CC1200Strobe as SAES;

	// TJ ADD
  provides interface CC1200Strobe as SRES;

  // registers
  provides interface CC1200Register as MAIN;
  provides interface CC1200Register as MDMCTRL0;
  provides interface CC1200Register as MDMCTRL1;
  provides interface CC1200Register as RSSI;
  provides interface CC1200Register as SYNCWORD;
  provides interface CC1200Register as TXCTRL;
  provides interface CC1200Register as RXCTRL0;
  provides interface CC1200Register as RXCTRL1;
  provides interface CC1200Register as FSCTRL;
  provides interface CC1200Register as SECCTRL0;
  provides interface CC1200Register as SECCTRL1;
  provides interface CC1200Register as BATTMON;
  provides interface CC1200Register as IOCFG0;
  provides interface CC1200Register as IOCFG1;
  provides interface CC1200Register as MANFIDL;
  provides interface CC1200Register as MANFIDH;
  provides interface CC1200Register as FSMTC;
  provides interface CC1200Register as MANAND;
  provides interface CC1200Register as MANOR;
  provides interface CC1200Register as AGCCTRL;
  provides interface CC1200Register as RXFIFO_REGISTER;

  // ram
  provides interface CC1200Ram as IEEEADR;
  provides interface CC1200Ram as PANID;
  provides interface CC1200Ram as SHORTADR;
  provides interface CC1200Ram as TXFIFO_RAM;
  provides interface CC1200Ram as RXFIFO_RAM;
  provides interface CC1200Ram as KEY0;
  provides interface CC1200Ram as KEY1;
  provides interface CC1200Ram as SABUF;
  provides interface CC1200Ram as TXNONCE;
  provides interface CC1200Ram as RXNONCE;

  // fifos
  provides interface CC1200Fifo as RXFIFO;
  provides interface CC1200Fifo as TXFIFO;

}

implementation {

  enum {
    CLIENT_ID = unique( "CC1200Spi.Resource" ),
  };
  
  components HplCC1200PinsC as Pins;
  components CC1200SpiWireC as Spi;
  
  ChipSpiResource = Spi.ChipSpiResource;
  Resource = Spi.Resource[ CLIENT_ID ];
  
  // commands
  SNOP = Spi.Strobe[ CC1200_SNOP ];
  SXOSCON = Spi.Strobe[ CC1200_SXOSCON ];
  STXCAL = Spi.Strobe[ CC1200_STXCAL ];
  SRXON = Spi.Strobe[ CC1200_SRXON ];
  STXON = Spi.Strobe[ CC1200_STXON ];
  STXONCCA = Spi.Strobe[ CC1200_STXONCCA ];
  SRFOFF = Spi.Strobe[ CC1200_SRFOFF ];
  SXOSCOFF = Spi.Strobe[ CC1200_SXOSCOFF ];
  SFLUSHRX = Spi.Strobe[ CC1200_SFLUSHRX ];
  SFLUSHTX = Spi.Strobe[ CC1200_SFLUSHTX ];
  SACK = Spi.Strobe[ CC1200_SACK ];
  SACKPEND = Spi.Strobe[ CC1200_SACKPEND ];
  SRXDEC = Spi.Strobe[ CC1200_SRXDEC ];
  STXENC = Spi.Strobe[ CC1200_STXENC ];
  SAES = Spi.Strobe[ CC1200_SAES ];

	// TJ ADD
  SRES = Spi.Strobe[ CC120X_SRES ];
  
  // registers
  MAIN = Spi.Reg[ CC1200_MAIN ];
  MDMCTRL0 = Spi.Reg[ CC1200_MDMCTRL0 ];
  MDMCTRL1 = Spi.Reg[ CC1200_MDMCTRL1 ];
  RSSI = Spi.Reg[ CC1200_RSSI ];
  SYNCWORD = Spi.Reg[ CC1200_SYNCWORD ];
  TXCTRL = Spi.Reg[ CC1200_TXCTRL ];
  RXCTRL0 = Spi.Reg[ CC1200_RXCTRL0 ];
  RXCTRL1 = Spi.Reg[ CC1200_RXCTRL1 ];
  FSCTRL = Spi.Reg[ CC1200_FSCTRL ];
  SECCTRL0 = Spi.Reg[ CC1200_SECCTRL0 ];
  SECCTRL1 = Spi.Reg[ CC1200_SECCTRL1 ];
  BATTMON = Spi.Reg[ CC1200_BATTMON ];
  IOCFG0 = Spi.Reg[ CC1200_IOCFG0 ];
  IOCFG1 = Spi.Reg[ CC1200_IOCFG1 ];
  MANFIDL = Spi.Reg[ CC1200_MANFIDL ];
  MANFIDH = Spi.Reg[ CC1200_MANFIDH ];
  FSMTC = Spi.Reg[ CC1200_FSMTC ];
  MANAND = Spi.Reg[ CC1200_MANAND ];
  MANOR = Spi.Reg[ CC1200_MANOR ];
  AGCCTRL = Spi.Reg[ CC1200_AGCCTRL ];
  RXFIFO_REGISTER = Spi.Reg[ CC1200_RXFIFO ];

  // ram
  IEEEADR = Spi.Ram[ CC1200_RAM_IEEEADR ];
  PANID = Spi.Ram[ CC1200_RAM_PANID ];
  SHORTADR = Spi.Ram[ CC1200_RAM_SHORTADR ];
  TXFIFO_RAM = Spi.Ram[ CC1200_RAM_TXFIFO ];
  RXFIFO_RAM = Spi.Ram[ CC1200_RAM_RXFIFO ];
  KEY0 = Spi.Ram[ CC1200_RAM_KEY0 ];
  KEY1 = Spi.Ram[ CC1200_RAM_KEY1 ];
  SABUF = Spi.Ram[ CC1200_RAM_SABUF ];
  TXNONCE = Spi.Ram[ CC1200_RAM_TXNONCE ];
  RXNONCE = Spi.Ram[ CC1200_RAM_RXNONCE ];

  // fifos
  RXFIFO = Spi.Fifo[ CC1200_RXFIFO ];
  TXFIFO = Spi.Fifo[ CC1200_TXFIFO ];

}

