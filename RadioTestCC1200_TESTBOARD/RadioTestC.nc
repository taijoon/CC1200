/*
 * Copyright (c) 2010-2012 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Main configuration for radio test.
 *
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

includes RadioTest;

configuration RadioTestC
{
  uses interface Boot;
}

implementation
{
  components SimpleServerCommC, SenderTestC, ReceiverTestC;
  //components LedsC;
  components NoLedsC as LedsC ;

  SimpleServerCommC.Boot = Boot;
  SenderTestC.Boot = Boot;
  ReceiverTestC.Boot = Boot;

  SimpleServerCommC.Leds -> LedsC;
  SenderTestC.Leds -> LedsC;
  ReceiverTestC.Leds -> LedsC;

  SenderTestC.Receive -> SimpleServerCommC;
  ReceiverTestC.Receive -> SimpleServerCommC;
  ReceiverTestC.AMSend -> SimpleServerCommC;
}

