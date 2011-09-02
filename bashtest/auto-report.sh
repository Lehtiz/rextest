#!/bin/bash

##
# Script needs the following packages installed:
# - ftp-upload, for uploading files
# - curl, for reporting issues to github
##

# FTP-CONFIG for fileUpload
  FTPHOST="xxx"
  FTPUSER="xxx"
  FTPPASSWD="xxx"

# GITHUB-CONFIG for createGithubIssue
  GITHUBLOGIN="rex-test-autoreport" # user
  GITHUBAPITOKEN="4b05500b0593b50f4c89dacb6d11449c" #users api token
  GITHUBREPO="rex-test-autoreport/issueReportTest" # e.g. "projectowner/project"

# todo more dynamic issue report ?
# issue report body for github report 
issueBodyInfo="
Errors were found during a test.
This issue was created automatically by the auto-report script.
"

# OPTIONS
# Option for preserving test output files after archive has been created
# default true
 preserveLogs=false

# Option for moving test output files to an old archives folder (debug-standalone-run)
# default true, if preserveLogs is set to false option is ignored
 configMoveOld=true

# Option for cleaning up (removing temp files) the the folder after running the script
# default true
 configCleanUp=true

# Option for uploading report .zip to host
# default false (needs config)
 configUploadFile=true

# Option for making github issue report
# default false (needs config)
 configCreateGithubIssue=true

# 
# CONFIG FUNCTIONS
# new tests need to be configured before they can be auto-reported
# 

# Configured test cases
test0=test-skeleton
test1=js-viewer-server-test
test2=avatar-test

# config for each test, files to read etc
function testSkeleton {
	# name used for summary
	testName=$test0
	# comment used for summary
	testComment="test test test"

	# helper var for the folder where the files are located
	logsDir=example

	# files to check, array
	files=("$logsDir/exampleLog.txt" "$logsDir/exampleOutput.out")
	
	# keywords used when checking files
	errorPattern=("Error" "Fail" "Warning")
	
	# start doing stuff
	operation
}

# config for js-viewer-server-test
function jsViewerServerTest {
	testName=$test1
	testComment="This test tries to launch local server and connect to it with the viewer app."

	logsDir=logs/jvst-output

	# files to check
	files=(`find $logsDir -maxdepth 2 | grep -i "\.out$" | sort`) 
	filesExtra=( "$logsDir/core" "$logsDir/*.js" "$logsDir/exitstatus.[sv]" )

	# keywords used when checking files
	errorPattern=("Error" "Failed" "Warning")

	operation
}

# config for avatar-test
function avatarTest {
	testName=$test2
	testComment="This test tries to connect to the server multiple times and move the avatar around, while recording traffic with tshark"

	# folder where files are located
	logsDir=logs/avatar-output

	# files to check
	files=(`find $logsDir -maxdepth 2 | grep -i "\.log$" | sort`)
	filesExtra=(`find $logsDir -maxdepth 2 | grep -i "\.pcap$" | sort`)

	# keywords used when checking files
	errorPattern=("Error" "Failed")

	operation
}

function whichTestWasRun {
# decide which test config will be used
case $1 in
	$test1)
	jsViewerServerTest 
	;;

	$test2)
	avatarTest
	;;

	*)
	echo "Error: test config not found."
	;;
esac
}

# 
# OPERATION FUNCTIONS
# no changes needed below this line
# 

# temp files
 errorOutput="errors.txt"
 tmpcnt="count.txt"
# var for error checking
 errors=false
 errorAmounts=0

function operation {
	html=$testName"_summary.html"
	echo "Running autoreport for: "$testName

	# input files and keywords
	whatWentWrong files[@] errorPattern[@]

	if $errors; then
		createSummary ${files[@]} ${filesExtra[@]}
		createArchive
		if $configUploadFile; then 
			uploadFile
		fi
		if $configCreateGithubIssue; then 
			createGithubIssue
		fi
	fi
	if $configCleanUp; then 
		cleanUp
	fi
}

function whatWentWrong {
	fileA=("${!1}")
	errorA=("${!2}")
	for (( i=0; i<${#fileA[@]}; i++))
		do for (( j=0; j<${#errorA[@]}; j++))
			do if (grep -iq ${errorA[$j]} ${fileA[$i]}); then
				errorAmounts[$j]=$((errorAmounts[$j]+`grep -ci ${errorA[$j]} ${fileA[$i]}`))
				echo "---${fileA[$i]}: " >> $errorOutput 2>&1
				grep "${errorA[$j]}" "${fileA[$i]}" >> $errorOutput
				errors=true
			fi
		done
	done

#create hit counter for summary
for((x=0; x<${#errorA[@]};x++))
	do echo "${errorA[$x]} - ${errorAmounts[$x]},"
done > $tmpcnt
countPrint=`cat $tmpcnt`
}

function createSummary {
	echo "creating report file..."
	local fileArray=("${@}")

	summaryOperations start  > $html 2>&1 
	summaryOperations desc >> $html 2>&1
	summaryOperations found >> $html 2>&1
	summaryOperations errors >> $html 2>&1 
	for (( i=0; i < ${#fileArray[@]}; i++ ))
		do summaryOperations add ${fileArray[$i]} >> $html 2>&1 
	done
	summaryOperations total ${#fileArray[@]} >> $html 2>&1 
	summaryOperations stop >> $html 2>&1 
}

function summaryOperations {
case $1 in 
	start)
	# start tags
	echo "<html><body><h1>TEST SUMMARY: $testName</h1>"
	;;

	desc)
	echo "<p>" $testComment "</p><hr />"
	;;
	
	found)
	echo "<pre>" $countPrint "</pre><hr />"
	;;

	errors)
	echo "<pre>"
	cat $errorOutput
	echo "</pre><hr /><h3>Files:</h3><ul>"
	;;

	add)
	echo "<li>File: <a href="$2">" $2 "</a></li>"
	;;

	total)
	echo "</ul><hr /><p>Total files: " $2 "</p>"
	;;

	stop)
	# ending tags
	echo "</body></html>"
	;;
esac
}

function createArchive {
	echo "Zipping..."
	time=$(date --iso=seconds)
	zipName=$testName"_"$time."zip"

	#todo what if zipping fails ?
	zipFiles ${files[@]}
	zipFiles ${filesExtra[@]}
	zipFiles $html
	# relocate already archieved files
	if ! $preserveLogs; then
		rm -r $logsDir/*
	
	else
		if $configMoveOld; then 
			moveOld
		fi
	fi
}

function zipFiles {
	local fileA=("${@}")
	for ((i=0; i<${#fileA[@]}; i++))
		do if [ -e ${fileA[$i]} ];
			then zip -q $zipName ${fileA[$i]}
		fi
	done
}

function moveOld {
	# move processed files to a subfolder old
	directory=old/$testName"_"$time

	if [ ! -d "$directory" ]
	then
		mkdir -p $directory
	fi

	mv $logsDir/* $directory
	
}

function uploadFile {
	echo "Uploading zip..."
	file=$zipName
	# needs ftp-upload installed
	ftp-upload --host $FTPHOST --user $FTPUSER --password $FTPPASSWD $file
	
	# todo confirmation on success and or error
}

function createGithubIssue {
	githubUrl="https://github.com/"
	echo "Creating issue: $githubUrl$GITHUBREPO/issues"

	url="http://github.com/api/v2/json/issues/open/$GITHUBREPO"
	errorZipLink="ftp://"$FTPHOST/$file # link to uploaded file

	issueTitle="Auto-reported: "$testName
	issueBody="
$issueBodyInfo 

Found - count:
$countPrint

Error logs for this report can be found in here: $errorZipLink
"

	curl -F "login=$GITHUBLOGIN" -F "token=$GITHUBAPITOKEN" -F "title=$issueTitle" -F "body=$issueBody" $url -s > /dev/null 2>&1

	# todo confirmation on success and or error
}

function cleanUp {
	echo "Cleaning up..."
	# remove tempfiles if they exist
	if [ -e $errorOutput ]; then
		rm $errorOutput
	fi
	if [ -e $html ]; then
		rm $html
	fi
	if [ -e $tmpcnt ]; then
		rm $tmpcnt
	fi
}


# 
# SCRIPT BODY
# 
whichTestWasRun $1
