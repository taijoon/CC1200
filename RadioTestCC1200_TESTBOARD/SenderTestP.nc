/*
 * Copyright (c) 2010-2013 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Implementation for sender test.
 *
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

module SenderTestP
{
  uses {
    interface Boot;
    interface Leds;
    interface Receive;

    interface Timer<TMilli> as MilliTimer;

    interface RadioTestPacket;
    interface SplitControl as RadioControl;

    interface AMSend as DataSend;
  }
}

implementation
{
  am_addr_t receiver;
  uint8_t seqNo;
  uint8_t rfPower;
  uint16_t period;
  uint16_t sample;
  uint8_t padding;
  uint8_t ctrlDup;
  uint16_t ctrlDelay;

  message_t dataMsgBffr;
  radiotest_data_msg_t *dataMsg;

  uint16_t dataSeqNo;

  radiotest_sender_state_t state;


  event void Boot.booted() {
    dataMsg = (radiotest_data_msg_t *)call DataSend.getPayload(
      &dataMsgBffr, call DataSend.maxPayloadLength());
    dataMsg->sender = TOS_NODE_ID;

    state = RADIOTEST_SENDER_STATE_INIT;
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
    if (cmdMsg->sender != TOS_NODE_ID) return msg;
    if (state != RADIOTEST_SENDER_STATE_INIT) return msg;

    // Update local variables
    receiver = cmdMsg->receiver;
    seqNo = cmdMsg->seqNo;
    rfPower = cmdMsg->rfPower;
    period = cmdMsg->period;
    sample = cmdMsg->sample;
    padding = cmdMsg->padding;
    ctrlDup = cmdMsg->ctrlDup;
    ctrlDelay = cmdMsg->ctrlDelay;

    call Leds.led0On();
    state = RADIOTEST_SENDER_STATE_CMD;
    post startTimer();
    return msg;
  }

  task void startTimer() {
    uint32_t timerPeriod;
    switch (state) {
    case RADIOTEST_SENDER_STATE_INIT:
      // This case should not happen
      break;

    case RADIOTEST_SENDER_STATE_CMD:
      timerPeriod = ctrlDup - seqNo - 1;
      timerPeriod *= period;
      timerPeriod += ctrlDelay;
      timerPeriod
        += timerPeriod / RADIOTEST_SAFETY_FACTOR + RADIOTEST_SAFETY_DELAY;
      call MilliTimer.startOneShot(timerPeriod);
      break;

    case RADIOTEST_SENDER_STATE_DATA:
      dataMsg->receiver = receiver;
      dataSeqNo = 0;
      call MilliTimer.startPeriodic(period);
      break;

    default:
      // This case should not happen
    }
  }

  task void sendTask();
  event void MilliTimer.fired() {
    switch (state) {
    case RADIOTEST_SENDER_STATE_INIT:
      // This case should not happen
      break;

    case RADIOTEST_SENDER_STATE_CMD:
      state = RADIOTEST_SENDER_STATE_DATA;
      post startTimer();
      break;

    case RADIOTEST_SENDER_STATE_DATA:
      // Done
      if (dataSeqNo >= sample + 4 * padding) {
        call MilliTimer.stop();
	call Leds.led0Off();
	state = RADIOTEST_SENDER_STATE_INIT;

      // More
      } else {
        // Set rfPower
	call RadioTestPacket.setPower(&dataMsgBffr,
	  dataSeqNo >= 1 * padding && dataSeqNo < sample + 3 * padding
	    ? rfPower : RADIOTEST_DEF_RFPOWER);
        dataMsg->seqNo = dataSeqNo++;
	post sendTask();
      }

      break;

    default:
      // This case should not happen
    }
  }

  task void sendTask() {
    call DataSend.send(
      AM_BROADCAST_ADDR, &dataMsgBffr, call DataSend.maxPayloadLength());
  }

  event void DataSend.sendDone(message_t* msg, error_t error) {
    call Leds.led2Toggle();
  }
}

