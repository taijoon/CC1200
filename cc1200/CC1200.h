
#ifndef __CC1200_H__
#define __CC1200_H__

typedef uint8_t cc1200_status_t;

#if defined(TFRAMES_ENABLED) && defined(IEEE154FRAMES_ENABLED)
#error "Both TFRAMES and IEEE154FRAMES enabled!"
#endif

/**
 * CC1200 header definition.
 * 
 * An I-frame (interoperability frame) header has an extra network 
 * byte specified by 6LowPAN
 * 
 * Length = length of the header + payload of the packet, minus the size
 *   of the length byte itself (1).  This is what allows for variable 
 *   length packets.
 * 
 * FCF = Frame Control Field, defined in the 802.15.4 specs and the
 *   CC1200 datasheet.
 *
 * DSN = Data Sequence Number, a number incremented for each packet sent
 *   by a particular node.  This is used in acknowledging that packet, 
 *   and also filtering out duplicate packets.
 *
 * DestPan = The destination PAN (personal area network) ID, so your 
 *   network can sit side by side with another TinyOS network and not
 *   interfere.
 * 
 * Dest = The destination address of this packet. 0xFFFF is the broadcast
 *   address.
 *
 * Src = The local node ID that generated the message.
 * 
 * Network = The TinyOS network ID, for interoperability with other types
 *   of 802.15.4 networks. 
 * 
 * Type = TinyOS AM type.  When you create a new AMSenderC(AM_MYMSG), 
 *   the AM_MYMSG definition is the type of packet.
 * 
 * TOSH_DATA_LENGTH defaults to 28, it represents the maximum size of 
 * the payload portion of the packet, and is specified in the 
 * tos/types/message.h file.
 *
 * All of these fields will be filled in automatically by the radio stack 
 * when you attempt to send a message.
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
  /** CC1200 802.15.4 header ends here */
#ifdef CC1200_HW_SECURITY
  security_header_t secHdr;
#endif
  
#ifndef TFRAMES_ENABLED
  /** I-Frame 6LowPAN interoperability byte */
  nxle_uint8_t network;
#endif

  nxle_uint8_t type;
} cc1200_header_t;

/**
 * CC1200 Packet Footer
 */
typedef nx_struct cc1200_footer_t {
} cc1200_footer_t;

/**
 * CC1200 Packet metadata. Contains extra information about the message
 * that will not be transmitted.
 *
 * Note that the first two bytes automatically take in the values of the
 * FCS when the payload is full. Do not modify the first two bytes of metadata.
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
  CC1200_BACKOFF_PERIOD = ( 20 / CC1200_TIME_SYMBOL ), // symbols
  CC1200_MIN_BACKOFF = ( 20 / CC1200_TIME_SYMBOL ),  // platform specific?
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

#endif
