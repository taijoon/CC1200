
configuration HplCC1200InterruptsC {

  provides interface GpioCapture as CaptureSFD;
  provides interface GpioInterrupt as InterruptCCA;
  provides interface GpioInterrupt as InterruptFIFOP;

}

implementation {

  components HplMsp430GeneralIOC as GeneralIOC;
  components Msp430TimerC;
  components new GpioCaptureC() as CaptureSFDC;
  CaptureSFDC.Msp430TimerControl -> Msp430TimerC.ControlB1;
  CaptureSFDC.Msp430Capture -> Msp430TimerC.CaptureB1;
  CaptureSFDC.GeneralIO -> GeneralIOC.Port41;

  components HplMsp430InterruptC;
  components new Msp430InterruptC() as InterruptCCAC;
  components new Msp430InterruptC() as InterruptFIFOPC;
  InterruptCCAC.HplInterrupt -> HplMsp430InterruptC.Port14;
  InterruptFIFOPC.HplInterrupt -> HplMsp430InterruptC.Port10;

  CaptureSFD = CaptureSFDC.Capture;
  InterruptCCA = InterruptCCAC.Interrupt;
  InterruptFIFOP = InterruptFIFOPC.Interrupt;

}
