/*
 * Copyright (c) 2013 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * Implementation for interfacing a packet.
 *
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

module RadioTestPacketP
{
  provides interface RadioTestPacket;
#if defined(PLATFORM_TELOSB)
  #if defined(CC1200_TEST)
    uses interface CC1200Packet as SubPacket;
  #else
    uses interface CC2420Packet as SubPacket;
  #endif
#elif defined(PLATFORM_MANGO2)
  uses interface MG245XCommPacket as SubPacket;
#else
#endif
}

implementation
{
  async command uint8_t RadioTestPacket.getPower( message_t* p_msg) {
    return call SubPacket.getPower(p_msg);
  }

  async command void RadioTestPacket.setPower( message_t* p_msg,
    uint8_t power ) {
#if defined(PLATFORM_TELOSB)
#elif defined(PLATFORM_MANGO2)
    if (power == 31) {
      power = 0;
    } else {
      power = (31 - power) / 2;
      if (power < 9) power++;
    }
#endif
    call SubPacket.setPower(p_msg, power);
  }

  async command int8_t RadioTestPacket.getRssi( message_t* p_msg ) {
    return call SubPacket.getRssi(p_msg);
  }

  async command uint8_t RadioTestPacket.getLqi( message_t* p_msg ) {
    return call SubPacket.getLqi(p_msg);
  }
}

