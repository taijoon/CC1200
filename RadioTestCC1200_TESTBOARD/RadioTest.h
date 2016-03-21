/*
 * Copyright (c) 2010-2013 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Data structure, states, and constants for radio test.
 *
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

#ifndef RADIOTEST_H
#define RADIOTEST_H

#include "message.h"


enum {
  RADIOTEST_SAFETY_FACTOR = 1000,
  RADIOTEST_SAFETY_DELAY = 10,
};

enum {
  RADIOTEST_DEF_RFPOWER = 0x1F,
};

typedef enum {
  RADIOTEST_SENDER_STATE_INIT = 1,
  RADIOTEST_SENDER_STATE_CMD = 2,
  RADIOTEST_SENDER_STATE_DATA = 3,
} radiotest_sender_state_t;

typedef enum {
  RADIOTEST_RECEIVER_STATE_INIT = 1,
  RADIOTEST_RECEIVER_STATE_CMD = 2,
  RADIOTEST_RECEIVER_STATE_DATA = 3,
  RADIOTEST_RECEIVER_STATE_RPT = 4,
} radiotest_receiver_state_t;


enum {
  AM_RADIOTEST_CMD_MSG = 0xA0,
  AM_RADIOTEST_RPT_MSG = 0xA1,
  AM_RADIOTEST_DATA_MSG = 0xA2,
};


typedef nx_struct radiotest_cmd_msg {
  nx_am_addr_t sender;
  nx_am_addr_t receiver;
  nx_uint8_t seqNo;
  nx_uint8_t rfPower;
  nx_uint16_t period;
  nx_uint16_t sample;
  nx_uint8_t padding;
  nx_uint8_t ctrlDup;
  nx_uint16_t ctrlDelay;
} radiotest_cmd_msg_t;

typedef nx_struct radiotest_rpt_msg {
  nx_am_addr_t sender;
  nx_am_addr_t receiver;
  nx_uint8_t seqNo;
  nx_uint16_t msgCnt;
  nx_int32_t rssiSum;
  nx_uint32_t lqiSum;
} radiotest_rpt_msg_t;

typedef nx_struct radiotest_data_msg {
  nx_am_addr_t sender;
  nx_am_addr_t receiver;
  nx_uint16_t seqNo;
} radiotest_data_msg_t;

#endif // RADIOTEST_H

