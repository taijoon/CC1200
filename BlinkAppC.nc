
configuration BlinkAppC
{
}
implementation
{
  components MainC, BlinkC, LedsC;
  components new TimerMilliC() as Timer0;
  components new TimerMilliC() as Timer1;
  components new TimerMilliC() as Timer2;


  BlinkC -> MainC.Boot;

  BlinkC.Timer0 -> Timer0;
  BlinkC.Timer1 -> Timer1;
  BlinkC.Timer2 -> Timer2;
  BlinkC.Leds -> LedsC;

	components HplMsp430GeneralIOC as MSP430IOC;

	BlinkC.P31 -> MSP430IOC.Port31;
	BlinkC.P32 -> MSP430IOC.Port32;
	BlinkC.P33 -> MSP430IOC.Port33;
	BlinkC.P42 -> MSP430IOC.Port42;
}

