
#include "Timer.h"

module BlinkC @safe()
{
  uses interface Timer<TMilli> as Timer0;
  uses interface Timer<TMilli> as Timer1;
  uses interface Timer<TMilli> as Timer2;
  uses interface Leds;
  uses interface Boot;

	uses interface HplMsp430GeneralIO as P31;
	uses interface HplMsp430GeneralIO as P32;
	uses interface HplMsp430GeneralIO as P33;
	uses interface HplMsp430GeneralIO as P42;
}
implementation
{ 
	int cnt=0;
  event void Boot.booted()
  {
		call P31.makeOutput();
		call P32.makeOutput();
		call P33.makeOutput();
		call P42.makeOutput();
		call Leds.set(7);
    call Timer0.startPeriodic( 1024 );
  }
 
  event void Timer0.fired()
  {
		call Leds.led0Toggle();
		call P31.toggle();
		call P32.toggle();
		call P33.toggle();
		call P42.toggle();
		cnt++;
  }
  
  event void Timer1.fired()
  { 
  }
  
  event void Timer2.fired()
  {
  }
}
