
configuration CC1200PacketC {

  provides {
    interface CC1200Packet;
    interface PacketAcknowledgements as Acks;
    interface CC1200PacketBody;
    interface LinkPacketMetadata;

    interface PacketTimeStamp<T32khz, uint32_t> as PacketTimeStamp32khz;
    interface PacketTimeStamp<TMilli, uint32_t> as PacketTimeStampMilli;
    interface PacketTimeSyncOffset;
  }

}

implementation {
  components CC1200PacketP;
  CC1200Packet         = CC1200PacketP;
  Acks                 = CC1200PacketP;
  CC1200PacketBody     = CC1200PacketP;
  LinkPacketMetadata   = CC1200PacketP;
  PacketTimeStamp32khz = CC1200PacketP;
  PacketTimeStampMilli = CC1200PacketP;
  PacketTimeSyncOffset = CC1200PacketP;

  components Counter32khz32C, new CounterToLocalTimeC(T32khz);
  CounterToLocalTimeC.Counter -> Counter32khz32C;
  CC1200PacketP.LocalTime32khz -> CounterToLocalTimeC;

  //DummyTimer is introduced to compile apps that use no timers
  components HilTimerMilliC, new TimerMilliC() as DummyTimer;
  CC1200PacketP.LocalTimeMilli -> HilTimerMilliC;
}
