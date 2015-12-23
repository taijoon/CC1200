/*
 * Copyright (c) 2012-2015 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Configuration for CC1200 test.
 *
 * @author Suchang Lee <suchanglee@sinbinet.com>
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

includes TestCc1200;

configuration TestCc1200AppC
{
}

implementation
{
  components TestCc1200C;
  components MainC, LedsC;
  components new TimerMilliC() as DataTimerC, new TimerMilliC() as ReplyTimerC;

  components SerialActiveMessageC;

  components new SerialAMSenderC(AM_TESTCC1200_DATA_MSG) as DataSenderC;
  components new SerialAMReceiverC(AM_TESTCC1200_CMD_MSG) as CmdReceiverC;
  components new SerialAMSenderC(AM_TESTCC1200_REPLY_MSG) as ReplySenderC;

  components HplMsp430GeneralIOC,
    new Msp430GpioC() as CC1200CSNC;
  components new Msp430Spi0C() as SpiC;


  TestCc1200C.Boot -> MainC;
  TestCc1200C.Leds -> LedsC;
  TestCc1200C.DataTimer -> DataTimerC;
  TestCc1200C.ReplyTimer -> ReplyTimerC;

  TestCc1200C.SerialControl -> SerialActiveMessageC;

  TestCc1200C.DataSend -> DataSenderC;
  TestCc1200C.CmdReceive -> CmdReceiverC;
  TestCc1200C.ReplySend -> ReplySenderC;

  TestCc1200C.CC1200CSN -> CC1200CSNC;
  CC1200CSNC.HplGeneralIO -> HplMsp430GeneralIOC.Port42;

  TestCc1200C.Resource -> SpiC;
  TestCc1200C.SpiByte -> SpiC;
  TestCc1200C.SpiPacket -> SpiC;
}
