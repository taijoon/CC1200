
interface CC1200SecurityMode
{
  command error_t setCtr(message_t* msg, uint8_t setKey, uint8_t setSkip);
  // Valid sizes are: 4, 6, 8, 10, 12, 14, 16
  command error_t setCbcMac(message_t* msg, uint8_t setKey, uint8_t setSkip, uint8_t size);
  command error_t setCcm(message_t* msg, uint8_t setKey, uint8_t setSkip, uint8_t size);
}
