#!/bin/bash

export LD_LIBRARY_PATH=~/MSP430Flasher_1.3.7/

clear
./MSP430Flasher -w "Firmware.txt" -v -g -z [VCC]
read -p "Press any key to continue..."
./MSP430Flasher -r [Firmware Output.txt,MAIN]
read -p "Press any key to continue..."
