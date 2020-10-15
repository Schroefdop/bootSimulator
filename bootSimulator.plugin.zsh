#!/bin/bash
# ----------------------
# Boot iOS simulators from terminal!
# ----------------------

_INPUT=

bootSimulator() {
    #
    # Create temporary files which will be deleted when script terminates
    #
    xcodeVersions=$(mktemp)
    trap "{ rm -f $xcodeVersions; }" EXIT

    allDevices=$(mktemp)
    trap "{ rm -f $allDevices; }" EXIT

    iosVersions=$(mktemp)
    trap "{ rm -f $iosVersions; }" EXIT

    devicesForVersion=$(mktemp)
    trap "{ rm -f $devicesForVersion; }" EXIT

    #
    # Which xcode?
    #
    find /Applications -iname "xcode*.app" -maxdepth 1 >$xcodeVersions

    if [ $xcodeVersions ] >1; then
        echo "Multiple Xcode applications found!"
        echo
        echo "Current selected Xcode tools:"
        /usr/bin/xcodebuild -version
        echo

        printf "Would you like to switch tools? [y/n] "
        read tmp

        case $tmp in
        [Yy]*)
            n=1
            while read line; do
                # Remove "/Applications/" prefix
                line=${line##*/}
                # Remove ".app" suffix
                line=${line%.app}
                echo $n. $line
                n=$((n + 1))
            done <$xcodeVersions

            _validateInput 'Xcode version: '

            xcodeVersion=$(head -$_INPUT $xcodeVersions | tail -1)

            echo "Switching Xcode command-line to target version..."
            sudo xcode-select --switch $xcodeVersion/Contents/Developer
            ;;
        *) ;;
        esac
    fi

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

    echo
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

        _validateInput 'iOS version: '

        iosVersion=$(head -$_INPUT $iosVersions | tail -1)
    fi
    iosVersion="--$iosVersion--"

    #
    # Loop all the devices and only write devices for chosen iOS version to file
    #

    echo
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

    echo
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

    _validateInput 'Device number: '

    #
    # Get all device details
    # Extract the id of the device
    # Extract the name of the device
    #
    device=$(head -$_INPUT $devicesForVersion | tail -1)
    deviceId=$(echo $device | grep -oE '[A-Z0-9]{8}(-[A-Z0-9]{4}){3}-[A-Z0-9]{12}')
    deviceName=$(echo $device | sed -E "s/\([A-Z0-9]{8}(-[A-Z0-9]{4}){3}-[A-Z0-9]{12}\).*//g") # Cut id and booted status

    echo "⏳ Booting $deviceName..."
    xcrun simctl boot $deviceId
    open -a simulator
}

_validateInput() {
    local NOCOLOR='\033[0m'
    local RED='\033[0;31m'

    while true; do
        #
        # Read user input
        #
        printf $1
        read tmp

        #
        # If input is not an integer or if input is out of range, throw an error
        # Ask for input again
        #
        if [[ ! $tmp =~ ^[0-9]+$ ]]; then
            echo "${RED}Invalid input${NOCOLOR}"
        elif [[ "$tmp" -lt "1" ]] || [[ "$tmp" -gt $((n - 1)) ]]; then
            echo "${RED}Input out of range ${NOCOLOR}"
        else
            _INPUT=$tmp
            break
        fi
    done
}
