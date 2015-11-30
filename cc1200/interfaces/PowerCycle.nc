 
interface PowerCycle {
  
  /**
   * Set the sleep interval, in binary milliseconds
   * @param sleepIntervalMs the sleep interval in [ms]
   */
  command void setSleepInterval(uint16_t sleepIntervalMs);
  
  /**
   * @return the sleep interval in [ms]
   */
  command uint16_t getSleepInterval();
  
  /**
   * @deprecated Should be removed in the future when the PowerCycle
   *     component does packet-level detects and is in full control of radio
   *     power.
   */
  event void detected();
  
}

