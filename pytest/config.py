#!/usr/local/bin/python
import getpass
import os
import os.path

### FOLDER CONFIG ###

#COMMON
rexbinDir = "/home/" + getpass.getuser() + "/src/old/realxtend/bin/"
scriptDir = os.path.abspath(os.getcwd())
testDir = os.path.abspath(os.path.join(scriptDir, '..'))

#JVST-TEST
jvstLogsDir = os.path.abspath(os.path.join(scriptDir, 'logs/jvst-output/'))

#AVATAR-TEST
avatarLogsDir = os.path.abspath(os.path.join(scriptDir, 'logs/avatar-output'))
wiresTempDir = os.path.abspath(os.path.join(scriptDir, 'wireshark_temp'))
tsharkLocation = "c:/Program Files/Wireshark/"

#LAUNCHTUNDRA-TEST
tundraLogsDir = os.path.abspath(os.path.join(scriptDir, 'logs/launchtundra/'))
