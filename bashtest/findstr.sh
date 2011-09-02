#!/bin/bash

source config.sh

cd $rexbinDir
find . -type f -name "naaliLog*.log" -exec grep -l "Removing the old entity" {} \; -print | while read str
do
mkdir $avatarOutputDir/errorlog$1
mv "$str" $avatarOutputDir/errorlog$1
done
