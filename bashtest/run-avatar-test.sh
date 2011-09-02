#!/bin/bash

# this script runs the run-clients.sh (a <=) 3 times
# findstr.sh will be run to search the log files for errors and if errors are found the log files will be copied to
# /logs/errorlogX folder
# with the value a <= 10 the execution lasts about 26 mins...
# a <= 50 started 16.6.2011 11:33

source config.sh

sudo mkdir $wiresTempDir #temp dir with root as owner for wireshark

for ((a=1; a <=1 ; a++))
do
	time=$(date --iso=seconds)
	mkdir -p $avatarOutputDir/logs_$time
	./run-clients.sh 2 $a

	sleep 70
	#./findstr.sh $a
	sleep 5

	sudo chown -R $USER $wiresTempDir/ # change owner to allow move
	mv $wiresTempDir/captured*.pcap $avatarOutputDir/logs_$time
	sudo chown root $wiresTempDir/ # change owner for next run for tshark
	echo "pcap files moved to logs_$time"
done

sudo rmdir $wiresTempDir #rm empty tempdir

cd $testDir
./auto-report.sh avatar-test
