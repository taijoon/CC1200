/*
 * Copyright (c) 2010-2013 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Implementation for simple server communication.
 *
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

module SimpleServerCommP
{
  provides {
    interface Receive;
    interface AMSend;
  }
  uses {
    interface Boot;
    interface Leds;

    interface AMPacket as SerialPacket;
    interface SplitControl as RadioControl;
    interface SplitControl as SerialControl;

    interface Receive as CmdSerialReceive;
    interface AMSend as CmdRadioSend;
    interface Receive as CmdRadioReceive;

    interface AMSend as RptSerialDirectSend;
    interface AMSend as RptRadioSend;
    interface Receive as RptRadioReceive;
    interface AMSend as RptSerialSend;
  }
}

implementation
{
  message_t cmdMsgBffr;
  void *cmdMsg;
  uint8_t cmdLen;

  message_t rptDirectMsgBffr;
  void *rptDirectMsg;
  uint8_t rptDirectLen;
  message_t *rptReturnMsg;
  error_t rptReturnError;

  message_t rptMsgBffr;
  void *rptMsg;
  uint8_t rptLen;

  bool cmdBusy;
  bool rptDirectBusy;
  bool rptBusy;


  event void Boot.booted() {
    cmdMsg = call CmdRadioSend.getPayload(
      &cmdMsgBffr, call CmdRadioSend.maxPayloadLength());

    rptDirectMsg = call RptSerialDirectSend.getPayload(
      &rptDirectMsgBffr, call RptSerialDirectSend.maxPayloadLength());
    call SerialPacket.setSource(&rptDirectMsgBffr, TOS_NODE_ID);
    call SerialPacket.setGroup(&rptDirectMsgBffr, TOS_AM_GROUP);

    rptMsg = call RptSerialSend.getPayload(
      &rptMsgBffr, call RptSerialSend.maxPayloadLength());
    call SerialPacket.setSource(&rptMsgBffr, TOS_NODE_ID);
    call SerialPacket.setGroup(&rptMsgBffr, TOS_AM_GROUP);

    cmdBusy = FALSE;
    rptDirectBusy = FALSE;
    rptBusy = FALSE;

    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t error) {
    call SerialControl.start();
  }

  event void RadioControl.stopDone(error_t error) {
  }

  event void SerialControl.startDone(error_t error) {
  }

  event void SerialControl.stopDone(error_t error) {
  }


  task void cmdSendTask();
  event message_t* CmdSerialReceive.receive(message_t* msg, void* payload,
    uint8_t len) {
    signal Receive.receive(msg, payload, len);

    if (cmdBusy) return msg;

    memcpy(cmdMsg, payload, len);
    cmdLen = len;

    cmdBusy = TRUE;
    post cmdSendTask();
    return msg;
  }

  void cmdSendDone();
  task void cmdSendTask() {
    if (call CmdRadioSend.send(AM_BROADCAST_ADDR, &cmdMsgBffr, cmdLen)
      != SUCCESS) {
      cmdSendDone();
    }
  }

  event void CmdRadioSend.sendDone(message_t* msg, error_t error) {
    cmdSendDone();
  }

  void cmdSendDone() {
    cmdBusy = FALSE;
  }

  event message_t* CmdRadioReceive.receive(message_t* msg, void* payload,
    uint8_t len) {
    signal Receive.receive(msg, payload, len);
    return msg;
  }


  task void rptDirectSendTask();
  command error_t AMSend.send(am_addr_t addr, message_t* msg, uint8_t len) {
    if (rptDirectBusy) return EBUSY;

    memcpy(rptDirectMsg, call AMSend.getPayload(msg, len), len);
    rptDirectLen = len;
    rptReturnMsg = msg;
    rptReturnError = SUCCESS;

    rptDirectBusy = TRUE;
    rptReturnError = call RptRadioSend.send(AM_BROADCAST_ADDR, msg, len);
    if (rptReturnError != SUCCESS) post rptDirectSendTask();
    return SUCCESS;
  }
  command error_t AMSend.cancel(message_t* msg) {
    return call RptRadioSend.cancel(msg);
  }
  command uint8_t AMSend.maxPayloadLength() {
    return call RptRadioSend.maxPayloadLength();
  }
  command void* AMSend.getPayload(message_t* msg, uint8_t len) {
    return call RptRadioSend.getPayload(msg, len);
  }

  task void rptDirectSendDone();
  event void RptRadioSend.sendDone(message_t* msg, error_t error) {
    if (rptReturnError == SUCCESS) rptReturnError = error;
    post rptDirectSendTask();
  }

  task void rptDirectSendTask() {
    error_t tmpRptReturnError;
    tmpRptReturnError = call RptSerialDirectSend.send(
      AM_BROADCAST_ADDR, &rptDirectMsgBffr, rptDirectLen);

    if (rptReturnError == SUCCESS) rptReturnError = tmpRptReturnError;
    if (tmpRptReturnError != SUCCESS) post rptDirectSendDone();
  }

  event void RptSerialDirectSend.sendDone(message_t* msg, error_t error) {
    if (rptReturnError == SUCCESS) rptReturnError = error;
    post rptDirectSendDone();
  }

  task void rptDirectSendDone() {
    rptDirectBusy = FALSE;
    signal AMSend.sendDone(rptReturnMsg, rptReturnError);
  }


  task void rptSendTask();
  event message_t* RptRadioReceive.receive(message_t* msg, void* payload,
    uint8_t len) {
    if (rptBusy) return msg;

    memcpy(rptMsg, payload, len);
    rptLen = len;

    rptBusy = TRUE;
    post rptSendTask();
    return msg;
  }

  void rptSendDone();
  task void rptSendTask() {
    if (call RptSerialSend.send(AM_BROADCAST_ADDR, &rptMsgBffr, rptLen)
      != SUCCESS) {
      rptSendDone();
    }
  }

  event void RptSerialSend.sendDone(message_t* msg, error_t error) {
    rptSendDone();
  }

  void rptSendDone() {
    rptBusy = FALSE;
  }


  default event void AMSend.sendDone(message_t* msg, error_t error) {
  }

  default event message_t* Receive.receive(message_t* msg, void* payload,
    uint8_t len) {
    return msg;
  }
}

