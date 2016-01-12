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
 * Oscilloscope demo application. See README.txt file in this directory.
 *
 * @author David Gay
 */
#include "Timer.h"
#include "Oscilloscope.h"
#include "cc120x_spi.h"

module OscilloscopeC @safe()
{
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface Timer<TMilli>;
    interface Timer<TMilli> as Timer2;
    interface Leds;
    interface AMSend;
    interface Receive;

		interface HplMsp430GeneralIO as P61;
    interface StdControl as SerialControl;
		interface UartStream;
	}
}
implementation
{
  message_t sendBuf;
  bool sendBusy;

  /* Current local state - interval, version and accumulated readings */
  oscilloscope_t local;

  uint8_t reading; /* 0 to NREADINGS */

  /* When we head an Oscilloscope message, we check it's sample count. If
     it's ahead of ours, we "jump" forwards (set our count to the received
     count). However, we must then suppress our next count increment. This
     is a very simple form of "time" synchronization (for an abstract
     notion of time). */
  bool suppressCountChange;

  // Use LEDs to report various status issues.
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
	void report_received() { call Leds.led2Toggle();}

  void startTimer() {
    call Timer.startPeriodic(local.interval);
    call Timer2.startPeriodic(100);
    reading = 0;
  }

  event void Boot.booted() {
		call Leds.set(7);
		call P61.makeInput();
    local.interval = DEFAULT_INTERVAL;
    local.id = TOS_NODE_ID;
    local.readings[0] = 0x1155;
    startTimer();
    if (call RadioControl.start() != SUCCESS)
			;
		call SerialControl.start();
  }

  event void RadioControl.startDone(error_t error) {
  }

  event void RadioControl.stopDone(error_t error) {
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    oscilloscope_t *omsg = payload;
		if(omsg->readings[0] == 0x1155)
    	report_received();
    return msg;
  }

  /* At each sample period:
     - if local sample buffer is full, send accumulated samples
     - read next sample
  */
	uint8_t status = 0;
  event void Timer2.fired() {
		uint8_t x  = call P61.get();
		if(x == 1 && status == 0){
			status = 1;
		}
		else if(x == 0 && status == 1){
	    memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
	    call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local);
			local.count++;
			status = 0;
		}
	}

	uint8_t IR[] = "AAA\n\r";
  event void Timer.fired() {
		call Leds.led0Toggle();
		call UartStream.send(IR, 6);
//	    memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
//	    if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) == SUCCESS)
//	      sendBusy = TRUE;
/*    if (reading == NREADINGS){
			if (!sendBusy && sizeof local <= call AMSend.maxPayloadLength()){
	    // Don't need to check for null because we've already checked length
	    // above
	    memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
	    if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) == SUCCESS)
	      sendBusy = TRUE;
		  }
			if (!sendBusy)
				;

			reading = 0;
			if (!suppressCountChange)
			  local.count++;
			suppressCountChange = FALSE;
    }
      reading++;
*/
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (error == SUCCESS)
      report_sent();

    sendBusy = FALSE;
  }

  async event void UartStream.receivedByte( uint8_t byte ) {
	}

  async event void UartStream.sendDone( uint8_t* buf, uint16_t len, error_t error ) {
	}

  async event void UartStream.receiveDone( uint8_t* buf, uint16_t len, error_t error ) {
	}
}
