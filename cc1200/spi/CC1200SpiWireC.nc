
configuration CC1200SpiWireC {
  
  provides interface Resource[ uint8_t id ];
  provides interface ChipSpiResource;
  provides interface CC1200Fifo as Fifo[ uint8_t id ];
  provides interface CC1200Ram as Ram[ uint16_t id ];
  provides interface CC1200Register as Reg[ uint8_t id ];
  provides interface CC1200Strobe as Strobe[ uint8_t id ];

}

implementation {

  components CC1200SpiP as SpiP;
  Resource = SpiP;
  Fifo = SpiP;
  Ram = SpiP;
  Reg = SpiP;
  Strobe = SpiP;
  ChipSpiResource = SpiP;

  components new StateC() as WorkingStateC;
  SpiP.WorkingState -> WorkingStateC;
  
  components new HplCC1200SpiC();
  SpiP.SpiResource -> HplCC1200SpiC;
  SpiP.SpiByte -> HplCC1200SpiC;
  SpiP.SpiPacket -> HplCC1200SpiC;

  components LedsC;
  SpiP.Leds -> LedsC;

}
