/*
 * Copyright (c) 2010-2013 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Configuration for receiver test.
 *
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

configuration ReceiverTestC
{
  uses interface Boot;
  uses interface Leds;
  uses interface Receive;
  uses interface AMSend;
}

implementation
{
  components ReceiverTestP;
  components new TimerMilliC();
  components RadioTestPacketC;
  components ActiveMessageC;

  components new AMReceiverC(AM_RADIOTEST_DATA_MSG);


  ReceiverTestP.Boot = Boot;
  ReceiverTestP.Leds = Leds;
  ReceiverTestP.Receive = Receive;
  ReceiverTestP.AMSend = AMSend;

  ReceiverTestP.MilliTimer -> TimerMilliC;

  ReceiverTestP.RadioTestPacket -> RadioTestPacketC;
  ReceiverTestP.RadioControl -> ActiveMessageC;

  ReceiverTestP.DataReceive -> AMReceiverC;
}

