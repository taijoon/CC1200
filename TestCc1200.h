/*
 * Copyright (c) 2010-2015 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Data structure, states, and constants for CC1200 test.
 *
 * @author Suchang Lee <suchanglee@sinbinet.com>
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

#ifndef TESTCC1200_H
#define TESTCC1200_H

#include "message.h"

enum {
  TESTCC1200_PERIOD = 1024,
};


typedef uint8_t testcc1200_code_t;
typedef nx_uint8_t nx_testcc1200_code_t;
enum {
  TESTCC1200_CODE_INIT = 0x01,
  TESTCC1200_CODE_LED_ON = 0x11,
  TESTCC1200_CODE_LED_OFF = 0x12,

  TESTCC1200_CODE_GET_REG = 0x21,
  TESTCC1200_CODE_SET_REG = 0x22,
};


enum {
  TESTCC1200_DFLT_VAL = 0x11,
};


enum {
  AM_TESTCC1200_DATA_MSG = 0xA4,
  AM_TESTCC1200_CMD_MSG = 0xA5,
  AM_TESTCC1200_REPLY_MSG = 0xA6,
};


typedef nx_struct cc1200test_cmd_reg {
  nx_uint8_t addr;
  nx_uint8_t val;
} cc1200test_cmd_reg_t;

typedef nx_struct cc1200test_reply_reg {
  nx_uint8_t val;
} cc1200test_reply_reg_t;


typedef nx_union cc1200test_data_data {
  nx_uint8_t reserved[TOSH_DATA_LENGTH - 6];
} cc1200test_data_data_t;

typedef nx_union cc1200test_cmd_data {
  cc1200test_cmd_reg_t reg;
  nx_uint8_t reserved[TOSH_DATA_LENGTH - 3];
} cc1200test_cmd_data_t;

typedef nx_union cc1200test_reply_data {
  cc1200test_reply_reg_t reg;
  nx_uint8_t reserved[TOSH_DATA_LENGTH - 3];
} cc1200test_reply_data_t;

typedef nx_struct testcc1200_data_msg {
  nx_am_addr_t srcId;
  nx_uint32_t seqNo;
  cc1200test_data_data_t dataData;
} testcc1200_data_msg_t;

typedef nx_struct testcc1200_cmd_msg {
  nx_am_addr_t destId;
  nx_testcc1200_code_t cmdCode;
  cc1200test_cmd_data_t cmdData;
} testcc1200_cmd_msg_t;

typedef nx_struct testcc1200_reply_msg {
  nx_am_addr_t srcId;
  nx_testcc1200_code_t replyCode;
  cc1200test_reply_data_t replyData;
} testcc1200_reply_msg_t;

#endif // TESTCC1200_H
