#!/bin/bash
# ----------------------
# Boot iOS simulators from terminal!
# ----------------------

bootSimulator() {
    allDevices=$(mktemp)
    trap "{ rm -f $allDevices; }" EXIT

    iosVersions=$(mktemp)
    trap "{ rm -f $iosVersions; }" EXIT

    devicesForVersion=$(mktemp)
    trap "{ rm -f $devicesForVersion; }" EXIT

    xcrun simctl list > $allDevices

    grep -E '\-\- iOS .... \-\-' $allDevices | tr -d \- > $iosVersions

    numberOfVersions=$(wc -l < $iosVersions)

    if [ $numberOfVersions -eq 1 ] ; then
        iosVersion=$(head -$choice $iosVersions | tail -1)
    else 
        echo "What iOS version do you want to run?"

        n=1
        while read line; do 
            echo $n. $line
            n=$((n+1))
        done < $iosVersions
        
        printf 'iOS version: '
        read tmp 
        iosVersion=$(head -$tmp $iosVersions | tail -1)
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
            # Append every device of the chosen OS in a file, except if it already booted
            if [ $line != $iosVersion ] && [[ $line != *"Booted"* ]] ; then
                echo $line >> $devicesForVersion
            fi
        fi
    done < $allDevices

    echo $iosVersion

    n=1
    while read line; do 
        echo $n. $line | gsed -E "s/\([A-Z0-9]{8}(-[A-Z0-9]{4}){3}-[A-Z0-9]{12}\).*//g"
        n=$((n+1))
    done < $devicesForVersion

    # Get user input
    printf 'Device number: '
    read choice

    device=$(head -$choice $devicesForVersion | tail -1)
    deviceId=$(echo $device | cut -d "(" -f2 | cut -d ")" -f1)
    deviceName=$(echo $device | cut -d "(" -f1)

    echo "⏳ Booting $deviceName..."
    xcrun simctl boot $deviceId
    open -a simulator
}