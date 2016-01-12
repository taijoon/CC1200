/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Oscilloscope demo application. Uses the demo sensor - change the
 * new DemoSensorC() instantiation if you want something else.
 *
 * See README.txt file in this directory for usage instructions.
 *
 * @author David Gay
 */
configuration OscilloscopeAppC { }
implementation
{
  components OscilloscopeC, MainC, LedsC,
		ActiveMessageC, 
    new TimerMilliC(),
    new TimerMilliC() as SEC,
    new AMSenderC(AM_OSCILLOSCOPE), new AMReceiverC(AM_OSCILLOSCOPE);

  OscilloscopeC.Boot -> MainC;
  OscilloscopeC.RadioControl -> ActiveMessageC;
  OscilloscopeC.Timer -> TimerMilliC;
  OscilloscopeC.Timer2 -> SEC.Timer;
  OscilloscopeC.Leds -> LedsC;
  OscilloscopeC.AMSend -> AMSenderC;
  OscilloscopeC.Receive -> AMReceiverC;

	components HplMsp430GeneralIOC as MSP430IOC;
	OscilloscopeC.P61 -> MSP430IOC.Port61;

//  components PlatformSerialC as UART;
//  OscilloscopeC.SerialControl -> UART.StdControl;
//  OscilloscopeC.UartStream -> UART.UartStream;	

  components SerialActiveMessageC,                   // Serial messaging
    new SerialAMSenderC(0x11);   // Sends to the serial port

  OscilloscopeC.SerialControl -> SerialActiveMessageC;
  OscilloscopeC.SerialSend -> SerialAMSenderC.AMSend;
}
