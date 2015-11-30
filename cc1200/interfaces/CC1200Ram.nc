
#include "CC1200.h"

interface CC1200Ram {

  /**
   * Read data from a RAM. This operation is sychronous.
   *
   * @param offset within the field.
   * @param data a pointer to the receive buffer.
   * @param length number of bytes to read.
   * @return status byte returned when sending the last byte
   * of the SPI transaction.
   */
  async command cc1200_status_t read( uint8_t offset, uint8_t* COUNT_NOK(length) data, uint8_t length );

  /**
   * Write data to RAM. This operation is sychronous.
   *
   * @param offset within the field.
   * @param data a pointer to the send buffer.
   * @param length number of bytes to write.
   * @return status byte returned when sending the last address byte
   * of the SPI transaction.
   */
  async command cc1200_status_t write( uint8_t offset, uint8_t* COUNT_NOK(length) data, uint8_t length );

}
