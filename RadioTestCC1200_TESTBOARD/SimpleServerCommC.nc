/*
 * Copyright (c) 2010-2012 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Configuration for simple server communication.
 *
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

configuration SimpleServerCommC
{
  provides interface Receive;
  provides interface AMSend;
  uses interface Boot;
  uses interface Leds;
}

implementation
{
  components SimpleServerCommP;
  components ActiveMessageC;
  components SerialActiveMessageC;

  components new SerialAMReceiverC(AM_RADIOTEST_CMD_MSG) as CmdSerialReceiver;
  components new AMSenderC(AM_RADIOTEST_CMD_MSG) as CmdRadioSender;
  components new AMReceiverC(AM_RADIOTEST_CMD_MSG) as CmdRadioReceiver;

  components
    new SerialAMSenderC(AM_RADIOTEST_RPT_MSG) as RptSerialDirectSender;
  components new AMSenderC(AM_RADIOTEST_RPT_MSG) as RptRadioSender;
  components new AMReceiverC(AM_RADIOTEST_RPT_MSG) as RptRadioReceiver;
  components new SerialAMSenderC(AM_RADIOTEST_RPT_MSG) as RptSerialSender;


  Receive = SimpleServerCommP;
  AMSend = SimpleServerCommP;
  SimpleServerCommP.Boot = Boot;
  SimpleServerCommP.Leds = Leds;

  SimpleServerCommP.SerialPacket -> SerialActiveMessageC;
  SimpleServerCommP.RadioControl -> ActiveMessageC;
  SimpleServerCommP.SerialControl -> SerialActiveMessageC;

  SimpleServerCommP.CmdSerialReceive -> CmdSerialReceiver;
  SimpleServerCommP.CmdRadioSend -> CmdRadioSender;
  SimpleServerCommP.CmdRadioReceive -> CmdRadioReceiver;

  SimpleServerCommP.RptSerialDirectSend -> RptSerialDirectSender;
  SimpleServerCommP.RptRadioSend -> RptRadioSender;
  SimpleServerCommP.RptRadioReceive -> RptRadioReceiver;
  SimpleServerCommP.RptSerialSend -> RptSerialSender;
}

