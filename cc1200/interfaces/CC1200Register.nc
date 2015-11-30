
#include "CC1200.h"

interface CC1200Register {

  /**
   * Read a 16-bit data word from the register.
   *
   * @param data pointer to place the register value.
   * @return status byte from the read.
   */
  async command cc1200_status_t read(uint16_t* data);

  /**
   * Write a 16-bit data word to the register.
   * 
   * @param data value to write to register.
   * @return status byte from the write.
   */
  async command cc1200_status_t write(uint16_t data);

}
