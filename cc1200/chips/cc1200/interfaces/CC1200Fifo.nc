
interface CC1200Fifo {

  /**
   * Start reading from the FIFO. The <code>readDone</code> event will
   * be signalled upon completion.
   *
   * @param data a pointer to the receive buffer.
   * @param length number of bytes to read.
   * @return status byte returned when sending the last address byte
   * of the SPI transaction.
   */
  async command cc1200_status_t beginRead( uint8_t* COUNT_NOK(length) data, uint8_t length );

  /**
   * Continue reading from the FIFO without having to send the address
   * byte again. The <code>readDone</code> event will be signalled
   * upon completion.
   *
   * @param data a pointer to the receive buffer.
   * @param length number of bytes to read.
   * @return SUCCESS always.
   */
  async command error_t continueRead( uint8_t* COUNT_NOK(length) data, uint8_t length );

  /**
   * Signals the completion of a read operation.
   *
   * @param data a pointer to the receive buffer.
   * @param length number of bytes read.
   * @param error notification of how the operation went
   */
  async event void readDone( uint8_t* COUNT_NOK(length) data, uint8_t length, error_t error );

  /**
   * Start writing the FIFO. The <code>writeDone</code> event will be
   * signalled upon completion.
   *
   * @param data a pointer to the send buffer.
   * @param length number of bytes to write.
   * @return status byte returned when sending the last address byte
   * of the SPI transaction.
   */
  async command cc1200_status_t write( uint8_t* COUNT_NOK(length) data, uint8_t length );

  /**
   * Signals the completion of a write operation.
   *
   * @param data a pointer to the send buffer.
   * @param length number of bytes written.
   * @param error notification of how the operation went
   */
  async event void writeDone( uint8_t* COUNT_NOK(length) data, uint8_t length, error_t error );

}
