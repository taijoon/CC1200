/*
 * Copyright (c) 2010-2013 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Configuration for sender test.
 *
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

configuration SenderTestC
{
  uses interface Boot;
  uses interface Leds;
  uses interface Receive;
}

implementation
{
  components SenderTestP;
  components new TimerMilliC();
  components RadioTestPacketC;
  components ActiveMessageC;

  components new AMSenderC(AM_RADIOTEST_DATA_MSG);


  SenderTestP.Boot = Boot;
  SenderTestP.Leds = Leds;
  SenderTestP.Receive = Receive;

  SenderTestP.MilliTimer -> TimerMilliC;

  SenderTestP.RadioTestPacket -> RadioTestPacketC;
  SenderTestP.RadioControl -> ActiveMessageC;

  SenderTestP.DataSend -> AMSenderC;
}

