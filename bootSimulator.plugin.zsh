#!/bin/bash
# ----------------------
# Boot iOS simulators from terminal!
# ----------------------

bootSimulator() {
    allDevicesFile=$TMPDIR"simlist.txt"
    trap "rm $allDevicesFile" EXIT

    iosVersionsFile=$TMPDIR"iosVersions.txt"
    trap "rm $iosVersionsFile" EXIT

    devicesForVersionFile=$TMPDIR"tmpDevices.txt"
    trap "rm $devicesForVersionFile" EXIT

    xcrun simctl list > $allDevicesFile

    grep -E '\-\- iOS .... \-\-' $allDevicesFile | tr -d \- > $iosVersionsFile

    numberOfVersions=$(wc -l < $iosVersionsFile)

    if [ $numberOfVersions -eq 1 ] ; then
        cat $iosVersionsFile
        iosVersion=$(head -$choice $iosVersionsFile | tail -1)
    else 
        echo "What iOS version do you want to run?"

        n=1
        while read line; do 
            echo $n. $line
            n=$((n+1))
        done < $iosVersionsFile
        
        printf 'iOS version: '
        read tmp 
        iosVersion=$(head -$tmp $iosVersionsFile | tail -1)
    fi
    iosVersion="--$iosVersion--"

    isChosenVersion=0
    while read line; do
        # If the next line contains '--' a different apple OS list started, we quit out
        if [[ $line == *--* ]] && [ $line != $iosVersion ] ; then 
            isChosenVersion=0
        fi

        # If we reached the iOS version selected, add the line to the file
        if [ $line = $iosVersion ] || [ $isChosenVersion -eq 1 ] ; then
            isChosenVersion=1
            if [ $line != $iosVersion ] ; then
                echo $line >> $devicesForVersionFile
            fi
        fi
    done < $allDevicesFile

    echo $iosVersion

    n=1
    while read line; do 
        echo $n. $line
        n=$((n+1))
    done < $devicesForVersionFile

    # Get user input
    printf 'Device number: '
    read choice

    device=$(head -$choice $devicesForVersionFile | tail -1)
    deviceId=$(echo $device | cut -d "(" -f2 | cut -d ")" -f1)
    deviceName=$(echo $device | cut -d "(" -f1)

    echo "⏳ Booting $deviceName..."
    xcrun simctl boot $deviceId
    open -a simulator
}