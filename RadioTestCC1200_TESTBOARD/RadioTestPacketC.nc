/*
 * Copyright (c) 2013 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Configuration for interfacing a packet.
 *
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

configuration RadioTestPacketC
{
  provides interface RadioTestPacket;
}

implementation
{
  components RadioTestPacketP;
#if defined(PLATFORM_TELOSB)
  #if defined(CC1200_TEST)
    components CC1200PacketC as SubPacketC;
  #else
    components CC2420PacketC as SubPacketC;
  #endif
#elif defined(PLATFORM_MANGO2)
  components MG245XCommPacketC as SubPacketC;
#endif


  RadioTestPacket = RadioTestPacketP;

  RadioTestPacketP.SubPacket -> SubPacketC;
}

