#!/bin/bash

# script runs several clients in naali simultaneously.
# use ./run-clients.sh 3
# 3 is the number of clients to be run...
# also change the cache directory

source config.sh

time=$(date --iso=seconds)

pushd $rexbinDir
for ((a=1; a <= $1 ; a++))
do
	echo "writing log to file naaliLog"$2"."$a".log"
	echo "writing network log to file captured"$2"."$a".pcap"

	#export LD_PRELOAD="/home/oulusoft/src/knet/knet/lib/libkNet.so" #only for knet testing

	#cache="$testDir/cache"$a	# using designated cache folder
	 #export REXAPPDATA=$cache  # using designated cache folder

	sudo tshark -i any -w $wiresTempDir/captured$2.$a.pcap -f "port 2345"& #root temp folder w
	pid=$!	# for making pcap files (needs sudo rights for user)  

	gnome-terminal -x bash -c "./viewer 2>&1 --headless --run $js | tee -a $avatarOutputDir/logs_$time/naaliLog$2.$a.log" 
	kill $pid # killing pcap write process
	   sleep 15
done             


