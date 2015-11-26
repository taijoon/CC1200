/*
 * Copyright (c) 2015 Sinbinet Corporation
 *
 * @author Taijoon
 */

#ifndef __CC1200_H__
#define __CC1200_H__

typedef uint8_t cc1200_status_t;

#if defined(TFRAMES_ENABLED) && defined(IEEE154FRAMES_ENABLED)
#error "Both TFRAMES and IEEE154FRAMES enabled!"
#endif

/**
 * CC1200 header definition.
 * 
 */
/**
 * CC1200 Security Header
 */
typedef nx_struct security_header_t {
  nx_uint8_t secLevel:3;
  nx_uint8_t keyMode:2;
  nx_uint8_t reserved:3;
  nx_uint32_t frameCounter;
  nx_uint8_t keyID[1]; // One byte for now
} security_header_t;

typedef nx_struct cc1200_header_t {
  nxle_uint8_t length;
  nxle_uint16_t fcf;
  nxle_uint8_t dsn;
  nxle_uint16_t destpan;
  nxle_uint16_t dest;
  nxle_uint16_t src;
#ifdef CC1200_HW_SECURITY
  security_header_t secHdr;
#endif
  
#ifndef TFRAMES_ENABLED
  nxle_uint8_t network;
#endif

  nxle_uint8_t type;
} cc1200_header_t;

/**
 */
typedef nx_struct cc1200_footer_t {
} cc1200_footer_t;

/**
 */
typedef nx_struct cc1200_metadata_t {
  nx_uint8_t rssi;
  nx_uint8_t lqi;
  nx_uint8_t tx_power;
  nx_bool crc;
  nx_bool ack;
  nx_bool timesync;
  nx_uint32_t timestamp;
  nx_uint16_t rxInterval;

  /** Packet Link Metadata */
#ifdef PACKET_LINK
  nx_uint16_t maxRetries;
  nx_uint16_t retryDelay;
#endif
} cc1200_metadata_t;


typedef nx_struct cc1200_packet_t {
  cc1200_header_t packet;
  nx_uint8_t data[];
} cc1200_packet_t;


#ifndef TOSH_DATA_LENGTH
#define TOSH_DATA_LENGTH 28
#endif

#ifndef CC1200_DEF_CHANNEL
#define CC1200_DEF_CHANNEL 26
#endif

#ifndef CC1200_DEF_RFPOWER
#define CC1200_DEF_RFPOWER 31
#endif

/**
 * Ideally, your receive history size should be equal to the number of
 * RF neighbors your node will have
 */
#ifndef RECEIVE_HISTORY_SIZE
#define RECEIVE_HISTORY_SIZE 4
#endif

/** 
 * The 6LowPAN NALP ID for a TinyOS network is 63 (TEP 125).
 */
#ifndef TINYOS_6LOWPAN_NETWORK_ID
#define TINYOS_6LOWPAN_NETWORK_ID 0x3f
#endif

enum {
  // size of the header not including the length byte
  MAC_HEADER_SIZE = sizeof( cc1200_header_t ) - 1,
  // size of the footer (FCS field)
  MAC_FOOTER_SIZE = sizeof( uint16_t ),
  // MDU
  MAC_PACKET_SIZE = MAC_HEADER_SIZE + TOSH_DATA_LENGTH + MAC_FOOTER_SIZE,

  CC1200_SIZE = MAC_HEADER_SIZE + MAC_FOOTER_SIZE,
};

enum cc1200_enums {
  CC1200_TIME_ACK_TURNAROUND = 7, // jiffies
  CC1200_TIME_VREN = 20,          // jiffies
  CC1200_TIME_SYMBOL = 2,         // 2 symbols / jiffy
  CC1200_BACKOFF_PERIOD = ( 20 / CC2420_TIME_SYMBOL ), // symbols
  CC1200_MIN_BACKOFF = ( 20 / CC2420_TIME_SYMBOL ),  // platform specific?
  CC1200_ACK_WAIT_DELAY = 256,    // jiffies
};

enum cc1200_status_enums {
  CC1200_STATUS_RSSI_VALID = 1 << 1,
  CC1200_STATUS_LOCK = 1 << 2,
  CC1200_STATUS_TX_ACTIVE = 1 << 3,
  CC1200_STATUS_ENC_BUSY = 1 << 4,
  CC1200_STATUS_TX_UNDERFLOW = 1 << 5,
  CC1200_STATUS_XOSC16M_STABLE = 1 << 6,
};

enum cc1200_config_reg_enums {
   CC1200_IOCFG3                   0x0000
   CC1200_IOCFG2                   0x0001
   CC1200_IOCFG1                   0x0002
   CC1200_IOCFG0                   0x0003
   CC1200_SYNC3                    0x0004
   CC1200_SYNC2                    0x0005
   CC1200_SYNC1                    0x0006
   CC1200_SYNC0                    0x0007
   CC1200_SYNC_CFG1                0x0008
   CC1200_SYNC_CFG0                0x0009
   CC1200_DEVIATION_M              0x000A
   CC1200_MODCFG_DEV_E             0x000B
   CC1200_DCFILT_CFG               0x000C
   CC1200_PREAMBLE_CFG1            0x000D
   CC1200_PREAMBLE_CFG0            0x000E
   CC1200_IQIC                     0x000F
   CC1200_CHAN_BW                  0x0010
   CC1200_MDMCFG1                  0x0011
   CC1200_MDMCFG0                  0x0012
   CC1200_SYMBOL_RATE2             0x0013
   CC1200_SYMBOL_RATE1             0x0014
   CC1200_SYMBOL_RATE0             0x0015
   CC1200_AGC_REF                  0x0016
   CC1200_AGC_CS_THR               0x0017
   CC1200_AGC_GAIN_ADJUST          0x0018
   CC1200_AGC_CFG3                 0x0019
   CC1200_AGC_CFG2                 0x001A
   CC1200_AGC_CFG1                 0x001B
   CC1200_AGC_CFG0                 0x001C
   CC1200_FIFO_CFG                 0x001D
   CC1200_DEV_ADDR                 0x001E
   CC1200_SETTLING_CFG             0x001F
   CC1200_FS_CFG                   0x0020
   CC1200_WOR_CFG1                 0x0021
   CC1200_WOR_CFG0                 0x0022
   CC1200_WOR_EVENT0_MSB           0x0023
   CC1200_WOR_EVENT0_LSB           0x0024
   CC1200_RXDCM_TIME               0x0025
   CC1200_PKT_CFG2                 0x0026
   CC1200_PKT_CFG1                 0x0027
   CC1200_PKT_CFG0                 0x0028
   CC1200_RFEND_CFG1               0x0029
   CC1200_RFEND_CFG0               0x002A
   CC1200_PA_CFG1                  0x002B
   CC1200_PA_CFG0                  0x002C
   CC1200_ASK_CFG                  0x002D
   CC1200_PKT_LEN                  0x002E
  
/* Extended Configuration Registers */
   CC1200_IF_MIX_CFG               0x2F00
   CC1200_FREQOFF_CFG              0x2F01
   CC1200_TOC_CFG                  0x2F02
   CC1200_MARC_SPARE               0x2F03
   CC1200_ECG_CFG                  0x2F04
   CC1200_MDMCFG2                  0x2F05
   CC1200_EXT_CTRL                 0x2F06
   CC1200_RCCAL_FINE               0x2F07
   CC1200_RCCAL_COARSE             0x2F08
   CC1200_RCCAL_OFFSET             0x2F09
   CC1200_FREQOFF1                 0x2F0A
   CC1200_FREQOFF0                 0x2F0B
   CC1200_FREQ2                    0x2F0C
   CC1200_FREQ1                    0x2F0D
   CC1200_FREQ0                    0x2F0E
   CC1200_IF_ADC2                  0x2F0F
   CC1200_IF_ADC1                  0x2F10
   CC1200_IF_ADC0                  0x2F11
   CC1200_FS_DIG1                  0x2F12
   CC1200_FS_DIG0                  0x2F13
   CC1200_FS_CAL3                  0x2F14
   CC1200_FS_CAL2                  0x2F15
   CC1200_FS_CAL1                  0x2F16
   CC1200_FS_CAL0                  0x2F17
   CC1200_FS_CHP                   0x2F18
   CC1200_FS_DIVTWO                0x2F19
   CC1200_FS_DSM1                  0x2F1A
   CC1200_FS_DSM0                  0x2F1B
   CC1200_FS_DVC1                  0x2F1C
   CC1200_FS_DVC0                  0x2F1D
   CC1200_FS_LBI                   0x2F1E
   CC1200_FS_PFD                   0x2F1F
   CC1200_FS_PRE                   0x2F20
   CC1200_FS_REG_DIV_CML           0x2F21
   CC1200_FS_SPARE                 0x2F22
   CC1200_FS_VCO4                  0x2F23
   CC1200_FS_VCO3                  0x2F24
   CC1200_FS_VCO2                  0x2F25
   CC1200_FS_VCO1                  0x2F26
   CC1200_FS_VCO0                  0x2F27
   CC1200_GBIAS6                   0x2F28
   CC1200_GBIAS5                   0x2F29
   CC1200_GBIAS4                   0x2F2A
   CC1200_GBIAS3                   0x2F2B
   CC1200_GBIAS2                   0x2F2C
   CC1200_GBIAS1                   0x2F2D
   CC1200_GBIAS0                   0x2F2E
   CC1200_IFAMP                    0x2F2F
   CC1200_LNA                      0x2F30
   CC1200_RXMIX                    0x2F31
   CC1200_XOSC5                    0x2F32
   CC1200_XOSC4                    0x2F33
   CC1200_XOSC3                    0x2F34
   CC1200_XOSC2                    0x2F35
   CC1200_XOSC1                    0x2F36
   CC1200_XOSC0                    0x2F37
   CC1200_ANALOG_SPARE             0x2F38
   CC1200_PA_CFG3                  0x2F39
   CC1200_IRQ0M                    0x2F3F
   CC1200_IRQ0F                    0x2F40  
  
/* Status Registers */
   CC1200_WOR_TIME1                0x2F64
   CC1200_WOR_TIME0                0x2F65
   CC1200_WOR_CAPTURE1             0x2F66
   CC1200_WOR_CAPTURE0             0x2F67
   CC1200_BIST                     0x2F68
   CC1200_DCFILTOFFSET_I1          0x2F69
   CC1200_DCFILTOFFSET_I0          0x2F6A
   CC1200_DCFILTOFFSET_Q1          0x2F6B
   CC1200_DCFILTOFFSET_Q0          0x2F6C
   CC1200_IQIE_I1                  0x2F6D
   CC1200_IQIE_I0                  0x2F6E
   CC1200_IQIE_Q1                  0x2F6F
   CC1200_IQIE_Q0                  0x2F70
   CC1200_RSSI1                    0x2F71
   CC1200_RSSI0                    0x2F72
   CC1200_MARCSTATE                0x2F73
   CC1200_LQI_VAL                  0x2F74
   CC1200_PQT_SYNC_ERR             0x2F75
   CC1200_DEM_STATUS               0x2F76
   CC1200_FREQOFF_EST1             0x2F77
   CC1200_FREQOFF_EST0             0x2F78
   CC1200_AGC_GAIN3                0x2F79
   CC1200_AGC_GAIN2                0x2F7A
   CC1200_AGC_GAIN1                0x2F7B
   CC1200_AGC_GAIN0                0x2F7C
   CC1200_CFM_RX_DATA_OUT         0x2F7D
   CC1200_CFM_TX_DATA_IN          0x2F7E
 CC1200_ASK_SOFT_RX_DATA         0x2F7F
 CC1200_RNDGEN                   0x2F80
 CC1200_MAGN2                    0x2F81
 CC1200_MAGN1                    0x2F82
 CC1200_MAGN0                    0x2F83
 CC1200_ANG1                     0x2F84
 CC1200_ANG0                     0x2F85
 CC1200_CHFILT_I2                0x2F86
 CC1200_CHFILT_I1                0x2F87
 CC1200_CHFILT_I0                0x2F88
 CC1200_CHFILT_Q2                0x2F89
 CC1200_CHFILT_Q1                0x2F8A
 CC1200_CHFILT_Q0                0x2F8B
 CC1200_GPIO_STATUS              0x2F8C
 CC1200_FSCAL_CTRL               0x2F8D
 CC1200_PHASE_ADJUST             0x2F8E
 CC1200_PARTNUMBER               0x2F8F
 CC1200_PARTVERSION              0x2F90
 CC1200_SERIAL_STATUS            0x2F91
 CC1200_MODEM_STATUS1            0x2F92
 CC1200_MODEM_STATUS0            0x2F93
 CC1200_MARC_STATUS1             0x2F94
 CC1200_MARC_STATUS0             0x2F95
 CC1200_PA_IFAMP_TEST            0x2F96
 CC1200_FSRF_TEST                0x2F97
 CC1200_PRE_TEST                 0x2F98
 CC1200_PRE_OVR                  0x2F99
 CC1200_ADC_TEST                 0x2F9A
 CC1200_DVC_TEST                 0x2F9B
 CC1200_ATEST                    0x2F9C
 CC1200_ATEST_LVDS               0x2F9D
 CC1200_ATEST_MODE               0x2F9E
 CC1200_XOSC_TEST1               0x2F9F
 CC1200_XOSC_TEST0               0x2FA0
 CC1200_AES                      0x2FA1
 CC1200_MDM_TEST                 0x2FA2  

 CC1200_RXFIRST                  0x2FD2   
 CC1200_TXFIRST                  0x2FD3   
 CC1200_RXLAST                   0x2FD4 
 CC1200_TXLAST                   0x2FD5 
 CC1200_NUM_TXBYTES              0x2FD6  /* Number of bytes in TXFIFO */ 
 CC1200_NUM_RXBYTES              0x2FD7  /* Number of bytes in RXFIFO */
 CC1200_FIFO_NUM_TXBYTES         0x2FD8  
 CC1200_FIFO_NUM_RXBYTES         0x2FD9  
 CC1200_RXFIFO_PRE_BUF           0x2FDA
  
/* DATA FIFO Access */
 CC1200_SINGLE_TXFIFO            0x003F     /*  TXFIFO  - Single accecss to Transmit FIFO */
 CC1200_BURST_TXFIFO             0x007F     /*  TXFIFO  - Burst accecss to Transmit FIFO  */
 CC1200_SINGLE_RXFIFO            0x00BF     /*  RXFIFO  - Single accecss to Receive FIFO  */
 CC1200_BURST_RXFIFO             0x00FF     /*  RXFIFO  - Busrrst ccecss to Receive FIFO  */
  
/* AES Workspace */
/* AES Key */
 CC1200_AES_KEY                  0x2FE0     /*  AES_KEY    - Address for AES key input  */
 CC1200_AES_KEY15	        0x2FE0
 CC1200_AES_KEY14	        0x2FE1
 CC1200_AES_KEY13	        0x2FE2
 CC1200_AES_KEY12	        0x2FE3
 CC1200_AES_KEY11	        0x2FE4
 CC1200_AES_KEY10	        0x2FE5
 CC1200_AES_KEY9	                0x2FE6
 CC1200_AES_KEY8	                0x2FE7
 CC1200_AES_KEY7	                0x2FE8
 CC1200_AES_KEY6	                0x2FE9
 CC1200_AES_KEY5	                0x2FE10
 CC1200_AES_KEY4	                0x2FE11
 CC1200_AES_KEY3	                0x2FE12
 CC1200_AES_KEY2	                0x2FE13
 CC1200_AES_KEY1	                0x2FE14
 CC1200_AES_KEY0	                0x2FE15

/* AES Buffer */
 CC1200_AES_BUFFER               0x2FF0     /*  AES_BUFFER - Address for AES Buffer     */ 
 CC1200_AES_BUFFER15		0x2FF0
 CC1200_AES_BUFFER14		0x2FF1
 CC1200_AES_BUFFER13		0x2FF2
 CC1200_AES_BUFFER12		0x2FF3
 CC1200_AES_BUFFER11		0x2FF4
 CC1200_AES_BUFFER10		0x2FF5
 CC1200_AES_BUFFER9		0x2FF6
 CC1200_AES_BUFFER8		0x2FF7
 CC1200_AES_BUFFER7		0x2FF8
 CC1200_AES_BUFFER6		0x2FF9
 CC1200_AES_BUFFER5		0x2FF10
 CC1200_AES_BUFFER4		0x2FF11
 CC1200_AES_BUFFER3		0x2FF12
 CC1200_AES_BUFFER2		0x2FF13
 CC1200_AES_BUFFER1		0x2FF14
 CC1200_AES_BUFFER0		0x2FF15

 CC1200_LQI_CRC_OK_BM            0x80
 CC1200_LQI_EST_BM               0x7F

/* Command strobe registers */
 CC1200_SRES                     0x30      /*  SRES    - Reset chip. */
 CC1200_SFSTXON                  0x31      /*  SFSTXON - Enable and calibrate frequency synthesizer. */
 CC1200_SXOFF                    0x32      /*  SXOFF   - Turn off crystal oscillator. */
 CC1200_SCAL                     0x33      /*  SCAL    - Calibrate frequency synthesizer and turn it off. */
 CC1200_SRX                      0x34      /*  SRX     - Enable RX. Perform calibration if enabled. */
 CC1200_STX                      0x35      /*  STX     - Enable TX. If in RX state, only enable TX if CCA passes. */
 CC1200_SIDLE                    0x36      /*  SIDLE   - Exit RX / TX, turn off frequency synthesizer. */
 CC1200_SAFC                     0x37      /*  AFC     - Automatic Frequency Correction */    
 CC1200_SWOR                     0x38      /*  SWOR    - Start automatic RX polling sequence (Wake-on-Radio) */
 CC1200_SPWD                     0x39      /*  SPWD    - Enter power down mode when CSn goes high. */
 CC1200_SFRX                     0x3A      /*  SFRX    - Flush the RX FIFO buffer. */
 CC1200_SFTX                     0x3B      /*  SFTX    - Flush the TX FIFO buffer. */
 CC1200_SWORRST                  0x3C      /*  SWORRST - Reset real time clock. */
 CC1200_SNOP                     0x3D      /*  SNOP    - No operation. Returns status byte. */
  
/* Chip states returned in status byte */
 CC1200_STATE_IDLE               0x00
 CC1200_STATE_RX                 0x10
 CC1200_STATE_TX                 0x20
 CC1200_STATE_FSTXON             0x30
 CC1200_STATE_CALIBRATE          0x40
 CC1200_STATE_SETTLING           0x50
 CC1200_STATE_RXFIFO_ERROR       0x60
 CC1200_STATE_TXFIFO_ERROR       0x70
 
  CC1200_SNOP = 0x00,
  CC1200_SXOSCON = 0x01,
  CC1200_STXCAL = 0x02,
  CC1200_SRXON = 0x03,
  CC1200_STXON = 0x04,
  CC1200_STXONCCA = 0x05,
  CC1200_SRFOFF = 0x06,
  CC1200_SXOSCOFF = 0x07,
  CC1200_SFLUSHRX = 0x08,
  CC1200_SFLUSHTX = 0x09,
  CC1200_SACK = 0x0a,
  CC1200_SACKPEND = 0x0b,
  CC1200_SRXDEC = 0x0c,
  CC1200_STXENC = 0x0d,
  CC1200_SAES = 0x0e,
  CC1200_MAIN = 0x10,
  CC1200_MDMCTRL0 = 0x11,
  CC1200_MDMCTRL1 = 0x12,
  CC1200_RSSI = 0x13,
  CC1200_SYNCWORD = 0x14,
  CC1200_TXCTRL = 0x15,
  CC1200_RXCTRL0 = 0x16,
  CC1200_RXCTRL1 = 0x17,
  CC1200_FSCTRL = 0x18,
  CC1200_SECCTRL0 = 0x19,
  CC1200_SECCTRL1 = 0x1a,
  CC1200_BATTMON = 0x1b,
  CC1200_IOCFG0 = 0x1c,
  CC1200_IOCFG1 = 0x1d,
  CC1200_MANFIDL = 0x1e,
  CC1200_MANFIDH = 0x1f,
  CC1200_FSMTC = 0x20,
  CC1200_MANAND = 0x21,
  CC1200_MANOR = 0x22,
  CC1200_AGCCTRL = 0x23,
  CC1200_AGCTST0 = 0x24,
  CC1200_AGCTST1 = 0x25,
  CC1200_AGCTST2 = 0x26,
  CC1200_FSTST0 = 0x27,
  CC1200_FSTST1 = 0x28,
  CC1200_FSTST2 = 0x29,
  CC1200_FSTST3 = 0x2a,
  CC1200_RXBPFTST = 0x2b,
  CC1200_FMSTATE = 0x2c,
  CC1200_ADCTST = 0x2d,
  CC1200_DACTST = 0x2e,
  CC1200_TOPTST = 0x2f,
  CC1200_TXFIFO = 0x3e,
  CC1200_RXFIFO = 0x3f,
};

/*
enum cc1200_ram_addr_enums {
  CC1200_RAM_TXFIFO = 0x000,
  CC1200_RAM_RXFIFO = 0x080,
  CC1200_RAM_KEY0 = 0x100,
  CC1200_RAM_RXNONCE = 0x110,
  CC1200_RAM_SABUF = 0x120,
  CC1200_RAM_KEY1 = 0x130,
  CC1200_RAM_TXNONCE = 0x140,
  CC1200_RAM_CBCSTATE = 0x150,
  CC1200_RAM_IEEEADR = 0x160,
  CC1200_RAM_PANID = 0x168,
  CC1200_RAM_SHORTADR = 0x16a,
};

enum cc1200_nonce_enums {
  CC1200_NONCE_BLOCK_COUNTER = 0,
  CC1200_NONCE_KEY_SEQ_COUNTER = 2,
  CC1200_NONCE_FRAME_COUNTER = 3,
  CC1200_NONCE_SOURCE_ADDRESS = 7,
  CC1200_NONCE_FLAGS = 15,
};

enum cc1200_main_enums {
  CC1200_MAIN_RESETn = 15,
  CC1200_MAIN_ENC_RESETn = 14,
  CC1200_MAIN_DEMOD_RESETn = 13,
  CC1200_MAIN_MOD_RESETn = 12,
  CC1200_MAIN_FS_RESETn = 11,
  CC1200_MAIN_XOSC16M_BYPASS = 0,
};

enum cc1200_mdmctrl0_enums {
  CC1200_MDMCTRL0_RESERVED_FRAME_MODE = 13,
  CC1200_MDMCTRL0_PAN_COORDINATOR = 12,
  CC1200_MDMCTRL0_ADR_DECODE = 11,
  CC1200_MDMCTRL0_CCA_HYST = 8,
  CC1200_MDMCTRL0_CCA_MOD = 6,
  CC1200_MDMCTRL0_AUTOCRC = 5,
  CC1200_MDMCTRL0_AUTOACK = 4,
  CC1200_MDMCTRL0_PREAMBLE_LENGTH = 0,
};

enum cc1200_mdmctrl1_enums {
  CC1200_MDMCTRL1_CORR_THR = 6,
  CC1200_MDMCTRL1_DEMOD_AVG_MODE = 5,
  CC1200_MDMCTRL1_MODULATION_MODE = 4,
  CC1200_MDMCTRL1_TX_MODE = 2,
  CC1200_MDMCTRL1_RX_MODE = 0,
};

enum cc1200_rssi_enums {
  CC1200_RSSI_CCA_THR = 8,
  CC1200_RSSI_RSSI_VAL = 0,
};

enum cc1200_syncword_enums {
  CC1200_SYNCWORD_SYNCWORD = 0,
};

enum cc1200_txctrl_enums {
  CC1200_TXCTRL_TXMIXBUF_CUR = 14,
  CC1200_TXCTRL_TX_TURNAROUND = 13,
  CC1200_TXCTRL_TXMIX_CAP_ARRAY = 11,
  CC1200_TXCTRL_TXMIX_CURRENT = 9,
  CC1200_TXCTRL_PA_CURRENT = 6,
  CC1200_TXCTRL_RESERVED = 5,
  CC1200_TXCTRL_PA_LEVEL = 0,
};

enum cc1200_rxctrl0_enums {
  CC1200_RXCTRL0_RXMIXBUF_CUR = 12,
  CC1200_RXCTRL0_HIGH_LNA_GAIN = 10,
  CC1200_RXCTRL0_MED_LNA_GAIN = 8,
  CC1200_RXCTRL0_LOW_LNA_GAIN = 6,
  CC1200_RXCTRL0_HIGH_LNA_CURRENT = 4,
  CC1200_RXCTRL0_MED_LNA_CURRENT = 2,
  CC1200_RXCTRL0_LOW_LNA_CURRENT = 0,
};

enum cc1200_rxctrl1_enums {
  CC1200_RXCTRL1_RXBPF_LOCUR = 13,
  CC1200_RXCTRL1_RXBPF_MIDCUR = 12,
  CC1200_RXCTRL1_LOW_LOWGAIN = 11,
  CC1200_RXCTRL1_MED_LOWGAIN = 10,
  CC1200_RXCTRL1_HIGH_HGM = 9,
  CC1200_RXCTRL1_MED_HGM = 8,
  CC1200_RXCTRL1_LNA_CAP_ARRAY = 6,
  CC1200_RXCTRL1_RXMIX_TAIL = 4,
  CC1200_RXCTRL1_RXMIX_VCM = 2,
  CC1200_RXCTRL1_RXMIX_CURRENT = 0,
};

enum cc1200_rsctrl_enums {
  CC1200_FSCTRL_LOCK_THR = 14,
  CC1200_FSCTRL_CAL_DONE = 13,
  CC1200_FSCTRL_CAL_RUNNING = 12,
  CC1200_FSCTRL_LOCK_LENGTH = 11,
  CC1200_FSCTRL_LOCK_STATUS = 10,
  CC1200_FSCTRL_FREQ = 0,
};

enum cc1200_secctrl0_enums {
  CC1200_SECCTRL0_RXFIFO_PROTECTION = 9,
  CC1200_SECCTRL0_SEC_CBC_HEAD = 8,
  CC1200_SECCTRL0_SEC_SAKEYSEL = 7,
  CC1200_SECCTRL0_SEC_TXKEYSEL = 6,
  CC1200_SECCTRL0_SEC_RXKEYSEL = 5,
  CC1200_SECCTRL0_SEC_M = 2,
  CC1200_SECCTRL0_SEC_MODE = 0,
};

enum cc1200_secctrl1_enums {
  CC1200_SECCTRL1_SEC_TXL = 8,
  CC1200_SECCTRL1_SEC_RXL = 0,
};

enum cc1200_battmon_enums {
  CC1200_BATTMON_BATT_OK = 6,
  CC1200_BATTMON_BATTMON_EN = 5,
  CC1200_BATTMON_BATTMON_VOLTAGE = 0,
};

enum cc1200_iocfg0_enums {
  CC1200_IOCFG0_BCN_ACCEPT = 11,
  CC1200_IOCFG0_FIFO_POLARITY = 10,
  CC1200_IOCFG0_FIFOP_POLARITY = 9,
  CC1200_IOCFG0_SFD_POLARITY = 8,
  CC1200_IOCFG0_CCA_POLARITY = 7,
  CC1200_IOCFG0_FIFOP_THR = 0,
};

enum cc1200_iocfg1_enums {
  CC1200_IOCFG1_HSSD_SRC = 10,
  CC1200_IOCFG1_SFDMUX = 5,
  CC1200_IOCFG1_CCAMUX = 0,
};

enum cc1200_manfidl_enums {
  CC1200_MANFIDL_PARTNUM = 12,
  CC1200_MANFIDL_MANFID = 0,
};

enum cc1200_manfidh_enums {
  CC1200_MANFIDH_VERSION = 12,
  CC1200_MANFIDH_PARTNUM = 0,
};

enum cc1200_fsmtc_enums {
  CC1200_FSMTC_TC_RXCHAIN2RX = 13,
  CC1200_FSMTC_TC_SWITCH2TX = 10,
  CC1200_FSMTC_TC_PAON2TX = 6,
  CC1200_FSMTC_TC_TXEND2SWITCH = 3,
  CC1200_FSMTC_TC_TXEND2PAOFF = 0,
};

enum cc1200_sfdmux_enums {
  CC1200_SFDMUX_SFD = 0,
  CC1200_SFDMUX_XOSC16M_STABLE = 24,
};

enum cc1200_security_enums{
  CC1200_NO_SEC = 0,
  CC1200_CBC_MAC = 1,
  CC1200_CTR = 2,
  CC1200_CCM = 3,
  NO_SEC = 0,
  CBC_MAC_4 = 1,
  CBC_MAC_8 = 2,
  CBC_MAC_16 = 3,
  CTR = 4,
  CCM_4 = 5,
  CCM_8 = 6,
  CCM_16 = 7
};
norace uint8_t SECURITYLOCK = 0;

enum
{
  CC1200_INVALID_TIMESTAMP  = 0x80000000L,
};
*/
#endif
