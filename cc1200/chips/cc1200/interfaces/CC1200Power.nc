
interface CC1200Power {

  /**
   * Start the voltage regulator on the CC1200. On SUCCESS,
   * <code>startVReg()</code> will be signalled when the voltage
   * regulator is fully on.
   *
   * @return SUCCESS if the request was accepted, FAIL otherwise.
   */
  async command error_t startVReg();

  /**
   * Signals that the voltage regulator has been started.
   */
  async event void startVRegDone();
  
  /**
   * Stop the voltage regulator immediately.
   *
   * @return SUCCESS always
   */
  async command error_t stopVReg();

  /**
   * Start the oscillator. On SUCCESS, <code>startOscillator</code>
   * will be signalled when the oscillator has been started.
   *
   * @return SUCCESS if the request was accepted, FAIL otherwise.
   */
  async command error_t startOscillator();

  /**
   * Signals that the oscillator has been started.
   */
  async event void startOscillatorDone();

  /**
   * Stop the oscillator.
   *
   * @return SUCCESS if the oscillator was stopped, FAIL otherwise.
   */
  async command error_t stopOscillator();

  /**
   * Enable RX.
   *
   * @return SUCCESS if receive mode has been enabled, FAIL otherwise.
   */
  async command error_t rxOn();

  /**
   * Disable RX.
   *
   * @return SUCCESS if receive mode has been disabled, FAIL otherwise.
   */
  async command error_t rfOff();

}
