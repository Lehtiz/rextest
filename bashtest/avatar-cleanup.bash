#!/bin/bash

rm -r logs/*

if [ -d "wireshark_temp" ]
then
	sudo rm -R wireshark_temp/
fi

