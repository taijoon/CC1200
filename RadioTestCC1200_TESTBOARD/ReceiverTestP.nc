/*
 * Copyright (c) 2010-2013 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Implementation for receiver test.
 *
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

module ReceiverTestP
{
  uses {
    interface Boot;
    interface Leds;
    interface Receive;
    interface AMSend;

    interface Timer<TMilli> as MilliTimer;

    interface RadioTestPacket;
    interface SplitControl as RadioControl;

    interface Receive as DataReceive;
  }
}

implementation
{
  am_addr_t sender;
  uint8_t seqNo;
  uint16_t period;
  uint16_t sample;
  uint8_t padding;
  uint8_t ctrlDup;
  uint16_t ctrlDelay;

  message_t rptMsgBffr;
  radiotest_rpt_msg_t *rptMsg;

  uint16_t dataSeqNo;

  uint16_t msgCnt;
  int32_t rssiSum;
  uint32_t lqiSum;

  uint8_t rptSeqNo;

  radiotest_receiver_state_t state;


  event void Boot.booted() {
    rptMsg = (radiotest_rpt_msg_t *)call AMSend.getPayload(
      &rptMsgBffr, sizeof(radiotest_rpt_msg_t));
    rptMsg->receiver = TOS_NODE_ID;

    state = RADIOTEST_RECEIVER_STATE_INIT;
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t error) {
  }

  event void RadioControl.stopDone(error_t error) {
  }


  task void startTimer();
  event message_t* Receive.receive(message_t* msg, void* payload,
    uint8_t len) {
    radiotest_cmd_msg_t *cmdMsg = (radiotest_cmd_msg_t *)payload;
    if (cmdMsg->receiver != TOS_NODE_ID) return msg;
    if (state != RADIOTEST_RECEIVER_STATE_INIT) return msg;

    // Update local variables
    sender = cmdMsg->sender;
    seqNo = cmdMsg->seqNo;
    period = cmdMsg->period;
    sample = cmdMsg->sample;
    padding = cmdMsg->padding;
    ctrlDup = cmdMsg->ctrlDup;
    ctrlDelay = cmdMsg->ctrlDelay;

    msgCnt = 0;
    rssiSum = 0;
    lqiSum = 0;

    call Leds.led1On();
    state = RADIOTEST_RECEIVER_STATE_CMD;
    post startTimer();
    return msg;
  }

  task void startTimer() {
    uint32_t timerPeriod;
    switch (state) {
    case RADIOTEST_RECEIVER_STATE_INIT:
      // This case should not happen
      break;

    case RADIOTEST_RECEIVER_STATE_CMD:
      timerPeriod = sample + 4 * padding + ctrlDup - seqNo - 1;
      timerPeriod *= period;
      timerPeriod += 2 * ctrlDelay;
      timerPeriod += 2 * timerPeriod / RADIOTEST_SAFETY_FACTOR
	+ 2 * RADIOTEST_SAFETY_DELAY;
      call MilliTimer.startOneShot(timerPeriod);
      break;

    case RADIOTEST_RECEIVER_STATE_DATA:
      timerPeriod = sample + 4 * padding - dataSeqNo - 1;
      timerPeriod *= period;
      timerPeriod += ctrlDelay;
      timerPeriod += 2 * timerPeriod / RADIOTEST_SAFETY_FACTOR
        + 2 * RADIOTEST_SAFETY_DELAY;
      call MilliTimer.stop();
      call MilliTimer.startOneShot(timerPeriod);
      break;

    case RADIOTEST_RECEIVER_STATE_RPT:
      rptMsg->sender = sender;
      rptMsg->msgCnt = msgCnt;
      rptMsg->rssiSum = rssiSum;
      rptMsg->lqiSum = lqiSum;
      rptSeqNo = 0;
      call MilliTimer.startPeriodic(period);
      break;

    default:
      // This case should not happen
    }
  }

  event message_t* DataReceive.receive(message_t* msg, void* payload,
    uint8_t len) {
    radiotest_data_msg_t *dataMsg = (radiotest_data_msg_t *)payload;
    if (dataMsg->sender != sender) return msg;
    if (dataMsg->receiver != TOS_NODE_ID) return msg;
    if (state != RADIOTEST_RECEIVER_STATE_CMD
      && state != RADIOTEST_RECEIVER_STATE_DATA) {
      return msg;
    }

    // For sample
    if (dataMsg->seqNo >= 2 * padding
      && dataMsg->seqNo < sample + 2 * padding) {
      // Update stat
      msgCnt++;
      atomic rssiSum += call RadioTestPacket.getRssi(msg);
      atomic lqiSum += call RadioTestPacket.getLqi(msg);
    }

    // Restart timer
    dataSeqNo = dataMsg->seqNo;
    state = RADIOTEST_RECEIVER_STATE_DATA;
    post startTimer();

    return msg;
  }

  task void sendTask();
  event void MilliTimer.fired() {
    switch (state) {
    case RADIOTEST_RECEIVER_STATE_INIT:
      // This case should not happen
      break;

    case RADIOTEST_RECEIVER_STATE_CMD:
    case RADIOTEST_RECEIVER_STATE_DATA:
      state = RADIOTEST_RECEIVER_STATE_RPT;
      post startTimer();
      break;

    case RADIOTEST_RECEIVER_STATE_RPT:
      // Done
      if (rptSeqNo >= ctrlDup) {
        call MilliTimer.stop();
	call Leds.led1Off();
	state = RADIOTEST_RECEIVER_STATE_INIT;

      // More
      } else {
        rptMsg->seqNo = rptSeqNo++;
	post sendTask();
      }

      break;

    default:
      // This case should not happen
    }
  }

  task void sendTask() {
    call AMSend.send(
      AM_BROADCAST_ADDR, &rptMsgBffr, sizeof(radiotest_rpt_msg_t));
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    call Leds.led2Toggle();
  }
}

