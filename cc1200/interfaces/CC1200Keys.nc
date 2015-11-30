
interface CC1200Keys
{
  command error_t setKey(uint8_t keyNo, uint8_t* key);
  event void setKeyDone(uint8_t keyNo, uint8_t* key);
}
