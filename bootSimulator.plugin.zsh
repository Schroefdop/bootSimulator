#!/bin/bash
# ----------------------
# Boot iOS simulators from terminal!
# ----------------------

bootSimulator() {
    #
    # Create temporary files which will be deleted when script terminates
    #
    allDevices=$(mktemp)
    trap "{ rm -f $allDevices; }" EXIT

    iosVersions=$(mktemp)
    trap "{ rm -f $iosVersions; }" EXIT

    devicesForVersion=$(mktemp)
    trap "{ rm -f $devicesForVersion; }" EXIT

    #
    # Write all the devices to the file
    #
    xcrun simctl list >$allDevices

    #
    # Only get iOS versions
    #
    grep -E '\-\- iOS .... \-\-' $allDevices | tr -d \- >$iosVersions

    numberOfVersions=$(wc -l <$iosVersions)

    #
    # If only one version is found, show available devices immediatly
    # Else let the user choose which iOS version they want to boot
    #
    if [ $numberOfVersions -eq 1 ]; then
        iosVersion=$(cat $iosVersions)
    else
        echo "What iOS version do you want to run?"

        #
        # Echo the iOS versions and prepend numbers
        #
        n=1
        while read line; do
            echo $n. $line
            n=$((n + 1))
        done <$iosVersions

        #
        # Read user choice and set chosen iOS version
        #
        printf 'iOS version: '
        read tmp
        iosVersion=$(head -$tmp $iosVersions | tail -1)
    fi
    iosVersion="--$iosVersion--"

    #
    # Loop all the devices and only write devices for chosen iOS version to file
    #
    isChosenVersion=0
    while read line; do
        #
        # If the next line contains '--' a different iOS version list started, we quit out
        #
        if [[ $line == *--* ]] && [ $line != $iosVersion ]; then
            isChosenVersion=0
        fi

        #
        # If we reached the iOS version selected, write the devices to a file
        #
        if [ $line = $iosVersion ] || [ $isChosenVersion -eq 1 ]; then
            isChosenVersion=1

            #
            # Write every device of the chosen iOS version to a file, except if it is already booted
            #
            if [ $line != $iosVersion ] && [[ $line != *"Booted"* ]]; then
                echo $line >>$devicesForVersion
            fi
        fi
    done <$allDevices

    echo $iosVersion

    #
    # Echo all the available devices prepended with a number to choose from
    # Cuts     iPad (5th generation) (5751E2BF-4C80-45CF-84AD-0512265217FC) (Shutdown)
    # To       iPad (5th generation)
    #
    n=1
    while read line; do
        echo $n. $line | sed -E "s/\([A-Z0-9]{8}(-[A-Z0-9]{4}){3}-[A-Z0-9]{12}\).*//g"
        n=$((n + 1))
    done <$devicesForVersion

    #
    # Read user input
    #
    printf 'Device number: '
    read choice

    #
    # Get all device details
    # Extract the id of the device
    # Extract the name of the device
    #
    device=$(head -$choice $devicesForVersion | tail -1)
    deviceId=$(echo $device | grep -oE '[A-Z0-9]{8}(-[A-Z0-9]{4}){3}-[A-Z0-9]{12}')
    deviceName=$(echo $device | cut -d "(" -f1)

    echo "⏳ Booting $deviceName..."
    xcrun simctl boot $deviceId
    open -a simulator
}
