
#include "IEEE802154.h"

interface CC1200Config {

  /**
   * Sync configuration changes with the radio hardware. This only
   * applies to set commands below.
   *
   * @return SUCCESS if the request was accepted, FAIL otherwise.
   */
  command error_t sync();
  event void syncDone( error_t error );

  /**
   * Change the channel of the radio, between 11 and 26
   */
  command uint8_t getChannel();
  command void setChannel( uint8_t channel );

  /**
   * Get the long address of the radio: set in hardware
   */
  command ieee_eui64_t getExtAddr();

  /**
   * Change the short address of the radio.
   */
  async command uint16_t getShortAddr();
  command void setShortAddr( uint16_t address );

  /**
   * Change the PAN address of the radio.
   */
  async command uint16_t getPanAddr();
  command void setPanAddr( uint16_t address );

  
  /**
   * @param enableAddressRecognition TRUE to turn address recognition on
   * @param useHwAddressRecognition TRUE to perform address recognition first
   *     in hardware. This doesn't affect software address recognition. The
   *     driver must sync with the chip after changing this value.
   */
  command void setAddressRecognition(bool enableAddressRecognition, bool useHwAddressRecognition);
  
  
  /**
   * @return TRUE if address recognition is enabled
   */
  async command bool isAddressRecognitionEnabled();
  
  /**
   * @return TRUE if address recognition is performed first in hardware.
   */
  async command bool isHwAddressRecognitionDefault();
  
  /**
   * Sync must be called for acknowledgement changes to take effect
   * @param enableAutoAck TRUE to enable auto acknowledgements
   * @param hwAutoAck TRUE to default to hardware auto acks, FALSE to
   *     default to software auto acknowledgements
   */
  command void setAutoAck(bool enableAutoAck, bool hwAutoAck);
  
  /**
   * @return TRUE if hardware auto acks are the default, FALSE if software
   *     acks are the default
   */
  async command bool isHwAutoAckDefault();
  
  /**
   * @return TRUE if auto acks are enabled
   */
  async command bool isAutoAckEnabled();
  

  
}
