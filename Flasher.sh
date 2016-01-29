#!/bin/bash

export LD_LIBRARY_PATH=~/MSP430Flasher_1.3.7/

#clear
#~/MSP430Flasher_1.3.7/MSP430Flasher -w "./build/telosz/main.txt" -z [VCC=3300]
~/MSP430Flasher_1.3.7/MSP430Flasher -w "./build/telosz/main.txt" -z [VCC=3000]
#read -p "Press any key to continue..."
#./MSP430Flasher -r [Firmware Output.txt,MAIN]
#read -p "Press any key to continue..."
