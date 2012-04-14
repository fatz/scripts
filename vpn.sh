#!/bin/bash

location_name="VPN"
vpn_name="VPN (Cisco IPSec) 2"

function growl_notify() {
	message=$1
	kind=$2
	/usr/local/bin/growlnotify -a /System/Library/PreferencePanes/Network.prefPane -m "$message" $kind
}
function growl_success() {
	message=$1
	kind="Success"
	growl_notify "$message" $kind
}

function growl_error() {
	message=$1
	kind="Error"
	growl_notify "$message" $kind
}

function change_location() {
	location_name=$1
	scselect $location_name >/dev/null
	if [[ "$?" != 0 ]] ; then
		echo "Changing location to $location_name failed"
		return 1
	fi
}

function connect_vpn() {
	name=$1
	osascript -e "tell application \"System Events\"
	   tell current location of network preferences
	       set VPNservice to service \"$vpn_name\"
	       if exists VPNservice then connect VPNservice
	   end tell
	end tell" >/dev/null
	if [[ "$?" != 0 ]] ; then
		echo "Connecting to $vpn_name failed"
		return 1
	fi
}

function disconnect_vpn() {
	osascript -e "tell application \"System Events\"
	   tell current location of network preferences
	       set VPNservice to service \"$vpn_name\"
	       if exists VPNservice then disconnect VPNservice
	   end tell
	end tell" >/dev/null
	if [[ "$?" != 0 ]] ; then
		echo "Disconnecting from $vpn_name failed"
		return 1
	fi
}

case "$1" in
	on|start)
		if change_location $location_name ; then
			sleep 4 # waiting for location change to finish
			if connect_vpn $vpn_name ; then
				growl_success "Connected to $vpn_name"
			else
				growl_error "Cannot connect to $vpn_name"
			fi
		fi
		;;
	off|stop)
		if change_location "Automatic" ; then
			if disconnect_vpn $vpn_name ; then
				growl_success "Disconnected from $vpn_name"
			else
				growl_error "Cannot disconnect from $vpn_name"
			fi
		fi
		;;
	*)
		echo "Usage: $0 {start|stop}"
		exit
		;;
esac
		
		