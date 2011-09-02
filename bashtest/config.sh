#!/bin/bash

# folder config
rexbinDir=$(dirname $(readlink -f $0))/../../bin
testDir=$(dirname $(readlink -f $0))

# AVATAR-TEST
# test chiru or local server
#js=$testDir/autoConnect.js
js=$testDir/autoConnectLocal.js
avatarOutputDir=$testDir/logs/avatar-output
wiresTempDir=$testDir/wireshark_temp

# JsViewerServer-TEST
jvstOutputDir=$testDir/logs/jvst-output

