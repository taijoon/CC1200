
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
  provides interface CC1200Strobe as SFSTXON;
  provides interface CC1200Strobe as SXOFF;
  provides interface CC1200Strobe as SCAL;
  provides interface CC1200Strobe as SRX;
  provides interface CC1200Strobe as STX;
  provides interface CC1200Strobe as SIDLE;
  provides interface CC1200Strobe as SAFC;
  provides interface CC1200Strobe as SWOR;
  provides interface CC1200Strobe as SPWD;
  provides interface CC1200Strobe as SFRX;
  provides interface CC1200Strobe as SFTX;
  provides interface CC1200Strobe as SWORRST;

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
//  provides interface CC1200Register as IOCFG0;
//  provides interface CC1200Register as IOCFG1;
  provides interface CC1200Register as MANFIDL;
  provides interface CC1200Register as MANFIDH;
  provides interface CC1200Register as FSMTC;
  provides interface CC1200Register as MANAND;
  provides interface CC1200Register as MANOR;
  provides interface CC1200Register as AGCCTRL;
  provides interface CC1200Register as RXFIFO_REGISTER;

	// TJ ADD
  provides interface CC1200Register as IOCFG3;
  provides interface CC1200Register as IOCFG2;
  provides interface CC1200Register as IOCFG1;
  provides interface CC1200Register as IOCFG0;
  provides interface CC1200Register as SYNC3;
  provides interface CC1200Register as SYNC2;
  provides interface CC1200Register as SYNC1;
  provides interface CC1200Register as SYNC0;
  provides interface CC1200Register as SYNC_CFG1;
  provides interface CC1200Register as SYNC_CFG0;
  provides interface CC1200Register as DEVIATION_M;
  provides interface CC1200Register as MODCFG_DEV_E;
  provides interface CC1200Register as DCFILT_CFG;
  provides interface CC1200Register as PREAMBLE_CFG1;
  provides interface CC1200Register as PREAMBLE_CFG0;
  provides interface CC1200Register as IQIC;
  provides interface CC1200Register as CHAN_BW;
  provides interface CC1200Register as MDMCFG1;
  provides interface CC1200Register as MDMCFG0;
  provides interface CC1200Register as SYMBOL_RATE2;
  provides interface CC1200Register as SYMBOL_RATE1;
  provides interface CC1200Register as SYMBOL_RATE0;
  provides interface CC1200Register as AGC_REF;
  provides interface CC1200Register as AGC_CS_THR;
  provides interface CC1200Register as AGC_GAIN_ADJUST;
  provides interface CC1200Register as AGC_CFG3;
  provides interface CC1200Register as AGC_CFG2;
  provides interface CC1200Register as AGC_CFG1;
  provides interface CC1200Register as AGC_CFG0;
  provides interface CC1200Register as FIFO_CFG;
  provides interface CC1200Register as FS_CFG;
  provides interface CC1200Register as WOR_CFG1;
  provides interface CC1200Register as WOR_CFG0;
  provides interface CC1200Register as WOR_EVENT0_MSB;
  provides interface CC1200Register as WOR_EVENT0_LSB;
  provides interface CC1200Register as RXDCM_TIME;
  provides interface CC1200Register as PKT_CFG2;
  provides interface CC1200Register as PKT_CFG1;
  provides interface CC1200Register as PKT_CFG0;
  provides interface CC1200Register as RFEND_CFG1;
  provides interface CC1200Register as RFEND_CFG0;
  provides interface CC1200Register as PA_CFG1;
  provides interface CC1200Register as PA_CFG0;
  provides interface CC1200Register as ASK_CFG;
  provides interface CC1200Register as PKT_LEN;
  provides interface CC1200Register as IF_MIX_CFG;
  provides interface CC1200Register as FREQOFF_CFG;
  provides interface CC1200Register as TOC_CFG;
  provides interface CC1200Register as MARC_SPARE;
  provides interface CC1200Register as ECG_CFG;
  provides interface CC1200Register as MDMCFG2;
  provides interface CC1200Register as EXT_CTRL;
  provides interface CC1200Register as RCCAL_FINE;
  provides interface CC1200Register as RCCAL_COARSE;
  provides interface CC1200Register as RCCAL_OFFSET;
  provides interface CC1200Register as FREQ2;
  provides interface CC1200Register as FREQ1;
  provides interface CC1200Register as FREQ0;
  provides interface CC1200Register as IF_ADC2;
  provides interface CC1200Register as IF_ADC1;
  provides interface CC1200Register as IF_ADC0;
  provides interface CC1200Register as FS_DIG1;
  provides interface CC1200Register as FS_DIG0;
  provides interface CC1200Register as FS_CAL3;
  provides interface CC1200Register as FS_CAL2;
  provides interface CC1200Register as FS_CAL1;
  provides interface CC1200Register as FS_CAL0;
  provides interface CC1200Register as FS_CHP;
  provides interface CC1200Register as FS_DIVTWO;
  provides interface CC1200Register as FS_DSM1;
  provides interface CC1200Register as FS_DSM0;
  provides interface CC1200Register as FS_DVC1;
  provides interface CC1200Register as FS_DVC0;
  provides interface CC1200Register as FS_PFD;
  provides interface CC1200Register as FS_PRE;
  provides interface CC1200Register as FS_REG_DIV_CML;
  provides interface CC1200Register as FS_SPARE;
  provides interface CC1200Register as FS_VCO4;
  provides interface CC1200Register as FS_VCO3;
  provides interface CC1200Register as FS_VCO2;
  provides interface CC1200Register as FS_VCO1;
  provides interface CC1200Register as FS_VCO0;
  provides interface CC1200Register as GBIAS6;
  provides interface CC1200Register as GBIAS5;
  provides interface CC1200Register as GBIAS4;
  provides interface CC1200Register as GBIAS3;
  provides interface CC1200Register as GBIAS2;
  provides interface CC1200Register as GBIAS1;
  provides interface CC1200Register as GBIAS0;
  provides interface CC1200Register as IFAMP;
  provides interface CC1200Register as LNA;
  provides interface CC1200Register as RXMIX;
  provides interface CC1200Register as XOSC5;
  provides interface CC1200Register as XOSC4;
  provides interface CC1200Register as XOSC3;
  provides interface CC1200Register as XOSC2;
  provides interface CC1200Register as XOSC1;
  provides interface CC1200Register as TXFIRST;
  provides interface CC1200Register as TXLAST;
  provides interface CC1200Register as RXFIRST;
  provides interface CC1200Register as RXLAST;

  provides interface CC1200Register as NUM_RXBYTES;
  provides interface CC1200Register as MARCSTATE;
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
  //SNOP = Spi.Strobe[ CC1200_SNOP ];
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
  SFSTXON = Spi.Strobe[ CC120X_SFSTXON ];
  SXOFF = Spi.Strobe[ CC120X_SXOFF ];
  SCAL = Spi.Strobe[ CC120X_SCAL ];
  SRX = Spi.Strobe[ CC120X_SRX ];
  STX = Spi.Strobe[ CC120X_STX ];
  SIDLE = Spi.Strobe[ CC120X_SIDLE ];
  SAFC = Spi.Strobe[ CC120X_SAFC ];
  SWOR = Spi.Strobe[ CC120X_SWOR ];
  SPWD = Spi.Strobe[ CC120X_SPWD ];
  SFRX = Spi.Strobe[ CC120X_SFRX ];
  SFTX = Spi.Strobe[ CC120X_SFTX ];
  SWORRST = Spi.Strobe[ CC120X_SWORRST ];
  SNOP = Spi.Strobe[ CC120X_SNOP ];

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
//  IOCFG0 = Spi.Reg[ CC1200_IOCFG0 ];
//  IOCFG1 = Spi.Reg[ CC1200_IOCFG1 ];
  MANFIDL = Spi.Reg[ CC1200_MANFIDL ];
  MANFIDH = Spi.Reg[ CC1200_MANFIDH ];
  FSMTC = Spi.Reg[ CC1200_FSMTC ];
  MANAND = Spi.Reg[ CC1200_MANAND ];
  MANOR = Spi.Reg[ CC1200_MANOR ];
  AGCCTRL = Spi.Reg[ CC1200_AGCCTRL ];
  RXFIFO_REGISTER = Spi.Reg[ CC1200_RXFIFO ];

  
	// TJ ADD
  IOCFG3 = Spi.Reg[ CC120X_IOCFG3 ];
  IOCFG2 = Spi.Reg[ CC120X_IOCFG2 ];
  IOCFG1 = Spi.Reg[ CC120X_IOCFG1 ];
  IOCFG0 = Spi.Reg[ CC120X_IOCFG0 ];
  SYNC3 = Spi.Reg[ CC120X_SYNC3 ];
  SYNC2 = Spi.Reg[ CC120X_SYNC2 ];
  SYNC1 = Spi.Reg[ CC120X_SYNC1 ];
  SYNC0 = Spi.Reg[ CC120X_SYNC0 ];
  SYNC_CFG1 = Spi.Reg[ CC120X_SYNC_CFG1 ];
  SYNC_CFG0 = Spi.Reg[ CC120X_SYNC_CFG0 ];
  DEVIATION_M = Spi.Reg[ CC120X_DEVIATION_M ];
  MODCFG_DEV_E = Spi.Reg[ CC120X_MODCFG_DEV_E ];
  DCFILT_CFG = Spi.Reg[ CC120X_DCFILT_CFG ];
  PREAMBLE_CFG1 = Spi.Reg[ CC120X_PREAMBLE_CFG1 ];
  PREAMBLE_CFG0 = Spi.Reg[ CC120X_PREAMBLE_CFG0 ];
  IQIC = Spi.Reg[ CC120X_IQIC ];
  CHAN_BW = Spi.Reg[ CC120X_CHAN_BW ];
  MDMCFG1 = Spi.Reg[ CC120X_MDMCFG1 ];
  MDMCFG0 = Spi.Reg[ CC120X_MDMCFG0 ];
  SYMBOL_RATE2 = Spi.Reg[ CC120X_SYMBOL_RATE2 ];
  SYMBOL_RATE1 = Spi.Reg[ CC120X_SYMBOL_RATE1 ];
  SYMBOL_RATE0 = Spi.Reg[ CC120X_SYMBOL_RATE0 ];
  AGC_REF = Spi.Reg[ CC120X_AGC_REF ];
  AGC_CS_THR = Spi.Reg[ CC120X_AGC_CS_THR ];
  AGC_GAIN_ADJUST = Spi.Reg[ CC120X_AGC_GAIN_ADJUST ];
  AGC_CFG3 = Spi.Reg[ CC120X_AGC_CFG3 ];
  AGC_CFG2 = Spi.Reg[ CC120X_AGC_CFG2 ];
  AGC_CFG1 = Spi.Reg[ CC120X_AGC_CFG1 ];
  AGC_CFG0 = Spi.Reg[ CC120X_AGC_CFG0 ];
  FIFO_CFG = Spi.Reg[ CC120X_FIFO_CFG ];
  WOR_CFG1 = Spi.Reg[ CC120X_WOR_CFG1 ];
  WOR_CFG0 = Spi.Reg[ CC120X_WOR_CFG0 ];
  WOR_EVENT0_MSB = Spi.Reg[ CC120X_WOR_EVENT0_MSB ];
  WOR_EVENT0_LSB = Spi.Reg[ CC120X_WOR_EVENT0_LSB ];
  RXDCM_TIME = Spi.Reg[ CC120X_RXDCM_TIME ];
  FS_CFG = Spi.Reg[ CC120X_FS_CFG ];
  PKT_CFG2 = Spi.Reg[ CC120X_PKT_CFG2 ];
  PKT_CFG0 = Spi.Reg[ CC120X_PKT_CFG0 ];
  PKT_CFG1 = Spi.Reg[ CC120X_PKT_CFG1 ];
  RFEND_CFG1 = Spi.Reg[ CC120X_RFEND_CFG1 ];
  RFEND_CFG0 = Spi.Reg[ CC120X_RFEND_CFG0 ];
  PA_CFG1 = Spi.Reg[ CC120X_PA_CFG1 ];
  PA_CFG0 = Spi.Reg[ CC120X_PA_CFG0 ];
  ASK_CFG = Spi.Reg[ CC120X_ASK_CFG ];
  PKT_LEN = Spi.Reg[ CC120X_PKT_LEN ];
  IF_MIX_CFG = Spi.Reg[ CC120X_IF_MIX_CFG ];
  FREQOFF_CFG = Spi.Reg[ CC120X_FREQOFF_CFG ];
  TOC_CFG = Spi.Reg[ CC120X_TOC_CFG ];
  MARC_SPARE = Spi.Reg[ CC120X_MARC_SPARE ];
  ECG_CFG = Spi.Reg[ CC120X_ECG_CFG ];
  MDMCFG2 = Spi.Reg[ CC120X_MDMCFG2 ];
  EXT_CTRL = Spi.Reg[ CC120X_EXT_CTRL ];
  RCCAL_FINE = Spi.Reg[ CC120X_RCCAL_FINE ];
  RCCAL_COARSE = Spi.Reg[ CC120X_RCCAL_COARSE ];
  RCCAL_OFFSET = Spi.Reg[ CC120X_RCCAL_OFFSET ];
  FREQ2 = Spi.Reg[ CC120X_FREQ2 ];
  FREQ1 = Spi.Reg[ CC120X_FREQ1 ];
  FREQ0 = Spi.Reg[ CC120X_FREQ0 ];
  IF_ADC2 = Spi.Reg[ CC120X_IF_ADC2 ];
  IF_ADC1 = Spi.Reg[ CC120X_IF_ADC1 ];
  IF_ADC0 = Spi.Reg[ CC120X_IF_ADC0 ];
  FS_DIG1 = Spi.Reg[ CC120X_FS_DIG1 ];
  FS_DIG0 = Spi.Reg[ CC120X_FS_DIG0 ];
  FS_CAL3 = Spi.Reg[ CC120X_FS_CAL3 ];
  FS_CAL2 = Spi.Reg[ CC120X_FS_CAL2 ];
  FS_CAL1 = Spi.Reg[ CC120X_FS_CAL1 ];
  FS_CAL0 = Spi.Reg[ CC120X_FS_CAL0 ];
  FS_CHP = Spi.Reg[ CC120X_FS_CHP ];
  FS_DIVTWO = Spi.Reg[ CC120X_FS_DIVTWO ];
  FS_DSM1 = Spi.Reg[ CC120X_FS_DSM1 ];
  FS_DSM0 = Spi.Reg[ CC120X_FS_DSM0 ];
  FS_DVC1 = Spi.Reg[ CC120X_FS_DVC1 ];
  FS_DVC0 = Spi.Reg[ CC120X_FS_DVC0 ];
  FS_PFD = Spi.Reg[ CC120X_FS_PFD ];
  FS_PRE = Spi.Reg[ CC120X_FS_PRE ];
  FS_REG_DIV_CML = Spi.Reg[ CC120X_FS_REG_DIV_CML ];
  FS_SPARE = Spi.Reg[ CC120X_FS_SPARE ];
  FS_VCO4 = Spi.Reg[ CC120X_FS_VCO4 ];
  FS_VCO3 = Spi.Reg[ CC120X_FS_VCO3 ];
  FS_VCO2 = Spi.Reg[ CC120X_FS_VCO2 ];
  FS_VCO1 = Spi.Reg[ CC120X_FS_VCO1 ];
  FS_VCO0 = Spi.Reg[ CC120X_FS_VCO0 ];
  GBIAS6 = Spi.Reg[ CC120X_GBIAS6 ];
  GBIAS5 = Spi.Reg[ CC120X_GBIAS5 ];
  GBIAS4 = Spi.Reg[ CC120X_GBIAS4 ];
  GBIAS3 = Spi.Reg[ CC120X_GBIAS3 ];
  GBIAS2 = Spi.Reg[ CC120X_GBIAS2 ];
  GBIAS1 = Spi.Reg[ CC120X_GBIAS1 ];
  GBIAS0 = Spi.Reg[ CC120X_GBIAS0 ];
  IFAMP = Spi.Reg[ CC120X_IFAMP ];
  LNA = Spi.Reg[ CC120X_LNA ];
  RXMIX = Spi.Reg[ CC120X_RXMIX ];
  XOSC5 = Spi.Reg[ CC120X_XOSC5 ];
  XOSC4 = Spi.Reg[ CC120X_XOSC4 ];
  XOSC3 = Spi.Reg[ CC120X_XOSC3 ];
  XOSC2 = Spi.Reg[ CC120X_XOSC2 ];
  XOSC1 = Spi.Reg[ CC120X_XOSC1 ];
  TXFIRST = Spi.Reg[ CC120X_RXFIRST ];
  TXLAST = Spi.Reg[ CC120X_RXLAST ];
  RXFIRST = Spi.Reg[ CC120X_RXFIRST ];
  RXLAST = Spi.Reg[ CC120X_RXLAST ];

  NUM_RXBYTES = Spi.Reg[ CC120X_NUM_RXBYTES ];
  MARCSTATE = Spi.Reg[ CC120X_MARCSTATE ];

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

  // fifos edited by TJ
  RXFIFO = Spi.Fifo[ CC120X_BURST_RXFIFO ];
  TXFIFO = Spi.Fifo[ CC120X_BURST_TXFIFO ];

}

