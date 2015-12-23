/*
 * Copyright (c) 2012-2015 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Implementation for CC1200 test.
 *
 * @author Suchang Lee <suchanglee@sinbinet.com>
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

module TestCc1200C
{
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli> as DataTimer;
    interface Timer<TMilli> as ReplyTimer;

    interface SplitControl as SerialControl;

    interface AMSend as DataSend;
    interface Receive as CmdReceive;
    interface AMSend as ReplySend;

    interface GeneralIO as CC1200CSN;

    interface Resource;
    interface SpiByte;
    interface SpiPacket;
  }
}

implementation
{
  uint32_t period;

  message_t dataMsgBuf;
  testcc1200_data_msg_t *dataMsg;

  testcc1200_cmd_msg_t cmdMsg;

  message_t replyMsgBuf;
  testcc1200_reply_msg_t *replyMsg;

  uint32_t seqNo;

  uint8_t state;


  event void Boot.booted() {
    dataMsg = (testcc1200_data_msg_t *)call DataSend.getPayload(
      &dataMsgBuf, sizeof(testcc1200_data_msg_t));
    dataMsg->srcId = TOS_NODE_ID;
    memset(&dataMsg->dataData, TESTCC1200_DFLT_VAL, TOSH_DATA_LENGTH - 6);

    replyMsg = (testcc1200_reply_msg_t *)call ReplySend.getPayload(
      &replyMsgBuf, sizeof(testcc1200_reply_msg_t));
    replyMsg->srcId = TOS_NODE_ID;

    seqNo = 0;

    state = TESTCC1200_CODE_INIT;
    atomic {
      call CC1200CSN.set();
      call CC1200CSN.makeOutput();
    }
    call SerialControl.start();
  }


  event void SerialControl.startDone(error_t error) {
    call DataTimer.startPeriodic(TESTCC1200_PERIOD);
  }

  event void SerialControl.stopDone(error_t error) {
  }


  task void dataSendTask();
  event void DataTimer.fired() {
		call Leds.led1Toggle();
    post dataSendTask();
  }

  task void dataSendTask() {
    memset(&dataMsg->dataData, TESTCC1200_DFLT_VAL, TOSH_DATA_LENGTH - 6);

    dataMsg->seqNo = seqNo++;

    call DataSend.send(AM_BROADCAST_ADDR, &dataMsgBuf,
      sizeof(testcc1200_data_msg_t));
  }

  event void DataSend.sendDone(message_t* msg, error_t error) {
  }


  task void intprCmd();
  event message_t* CmdReceive.receive(message_t* msg, void* payload,
    uint8_t len) {
    testcc1200_cmd_msg_t *newCmdMsg = (testcc1200_cmd_msg_t *)payload;
    if ((newCmdMsg->destId != AM_BROADCAST_ADDR)
      && (newCmdMsg->destId != TOS_NODE_ID)) return msg;

    if (state != TESTCC1200_CODE_INIT) return msg;

    memcpy(&cmdMsg, newCmdMsg, sizeof(testcc1200_cmd_msg_t));
    state = cmdMsg.cmdCode;

    post intprCmd();
    return msg;
  }

  task void intprCmd() {
    error_t error;
    switch (state) {

    case TESTCC1200_CODE_LED_ON:
      call Leds.led2On();
      state = TESTCC1200_CODE_INIT;
      break;

    case TESTCC1200_CODE_LED_OFF:
      call Leds.led2Off();
      state = TESTCC1200_CODE_INIT;
      break;

    case TESTCC1200_CODE_GET_REG:
    case TESTCC1200_CODE_SET_REG:
      atomic error = call Resource.request();
      if (error != SUCCESS) state = TESTCC1200_CODE_INIT;
      break;

    default:
      // Wrong code
      state = TESTCC1200_CODE_INIT;
    }
  }

  task void replySendTask();
  event void Resource.granted() {
    uint8_t val;
    switch (state) {

    case TESTCC1200_CODE_GET_REG:
      atomic {
        call CC1200CSN.clr();
	call SpiByte.write(0x80 | cmdMsg.cmdData.reg.addr);
	val = call SpiByte.write(0x00);
	call CC1200CSN.set();
	call Resource.release();
      }
      replyMsg->replyData.reg.val = val;
      post replySendTask();
      break;

    case TESTCC1200_CODE_SET_REG:
      atomic {
        call CC1200CSN.clr();
        call SpiByte.write(cmdMsg.cmdData.reg.addr);
	call SpiByte.write(cmdMsg.cmdData.reg.val);
	call SpiByte.write(0x80 | cmdMsg.cmdData.reg.addr);
	val = call SpiByte.write(0x00);
	call CC1200CSN.set();
	call Resource.release();
      }
      replyMsg->replyData.reg.val = val;
      post replySendTask();
      break;

    default:
      // Error
    }
  }

  async event void SpiPacket.sendDone(uint8_t* txBuf, uint8_t* rxBuf,
    uint16_t len, error_t error ) {
  }

  event void ReplyTimer.fired() {
  }

  task void replySendTask() {
    switch (state) {

    case TESTCC1200_CODE_GET_REG:
      break;

    case TESTCC1200_CODE_SET_REG:
      break;

    default:
      // Error
    }

    replyMsg->replyCode = state;

    if (call ReplySend.send(AM_BROADCAST_ADDR, &replyMsgBuf,
      sizeof(testcc1200_reply_msg_t)) != SUCCESS) {
      state = TESTCC1200_CODE_INIT;
    }
  }

  event void ReplySend.sendDone(message_t* msg, error_t error) {
    state = TESTCC1200_CODE_INIT;
  }
}
