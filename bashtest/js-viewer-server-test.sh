#!/bin/bash

source config.sh
testfile=`readlink -f $1`

# load arg script to server and connect with viewer

if [ ! -e $jvstOutputDir ];then
	mkdir -p $jvstOutputDir
fi

cd $rexbinDir

echo 'var d = frame.DelayedExecute(15.0); d.Triggered.connect(function (time) { print("exiting!"); framework.Exit(); });' > $jvstOutputDir/exitdelay.js
echo 'var d = frame.DelayedExecute(0.5); d.Triggered.connect(function (time) { client.Login("localhost",2345,"foo"," ","tcp");});' > $jvstOutputDir/dologin.js

case $testfile in 
    *.js)
	echo "Setting up args for a js file ($testfile)"
	cat $jvstOutputDir/exitdelay.js $testfile > $jvstOutputDir/s.js
	servercmd="./server --headless --run $jvstOutputDir/s.js"
	viewercmd="./viewer --headless --run $jvstOutputDir/v.js"
	;;
    *.txml)
	echo "Setting up args for a txml file ($testfile)"
	servercmd="./server --headless --file $testfile --run $jvstOutputDir/exitdelay.js"
	viewercmd="./viewer --headless --storage `dirname $testfile`/ --run $jvstOutputDir/v.js"
	;;
esac

ulimit -t 60 # cpu time limit
ulimit -c unlimited # i'd like core dumps with that
cat $jvstOutputDir/exitdelay.js $jvstOutputDir/dologin.js > $jvstOutputDir/v.js
xterm -e bash -c "$servercmd"' 2>&1 | tee '$jvstOutputDir'/s.out; echo $? > '$jvstOutputDir'/exitstatus.s' &
xterm -e bash -c "$viewercmd"' 2>&1 | tee '$jvstOutputDir'/v.out; echo $? > '$jvstOutputDir'/exitstatus.v' 
wait
grep . $jvstOutputDir/exitstatus.?
grep Error: $jvstOutputDir/[sv].out


if [ -e "core" ]
then
	mv core $jvstOutputDir
fi

function autoReport {
	cd $testDir 
	./auto-report.sh js-viewer-server-test
}
test -f $jvstOutputDir/core #&& exit 1
if test `cat $jvstOutputDir/exitstatus.s` = 0 && test `cat $jvstOutputDir/exitstatus.v` = 0; then
    echo 'test outcome: success'
	autoReport
    exit 0
else
    echo 'test outcome: failure'
	autoReport
    exit 1
fi




