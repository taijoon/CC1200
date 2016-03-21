#!/bin/bash
export LD_LIBRARY_PATH=~/MSP430Flasher_1.3.7/


usage() {
				echo "Usage: $0 <id>"
				echo "	where 0 <= id < 65535"
}

if [ $# -lt 1 ] ; then
	echo id is missing
	usage
elif ![[ $1 =~ [0-9]+ ]] ; then
	echo $1 is not a number
	usage
elif [ $1 -lt 0 ] || [ $1 -ge 65535 ] ; then
	echo $1 is out of range
	usage
else

make telosb install.$1 bsl,99
cp build/telosb/main.ihex.out-$1 build/telosb/main.txt
#~/MSP430Flasher_1.3.7/MSP430Flasher -w "./build/telosz/main.txt" -v -g -z [VCC=3300]

MSP430Flasher.exe -n MSP430F1611 -w "./build/telosb/main.txt" -v -g -z [VCC=0]


fi

