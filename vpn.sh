#!/bin/bash

location_name="VPN"
vpn_name="VPN (Cisco IPSec) 2"

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
				echo "OK"
			fi
		fi
		;;
	off|stop)
		if change_location "Automatic" ; then
			if disconnect_vpn $vpn_name ; then
				echo "OK"
			fi
		fi
		;;
	*)
		echo "Usage: $0 {start|stop}"
		exit
		;;
esac
		
		