#!/bin/bash
###########################################################
# Veritas Storage Info                                    #
# Created: Ottó Király                                    #
# Last modification: 2024.12.04                           #
###########################################################
VERSION=1.0020;
IMPORTED=0; ALL=0 HELP=0; FLAG=1;
for arg in $@; do
	case $arg in
		[hH][eE][lL][pP]) HELP=1;;
		[aA][lL][lL]) ALL=1; FLAG=0;;
		*) echo 'Invalid argument! '$arg;
	esac;
done;

# Script informations
if (( $HELP )); then 
	echo -e 'Version: '$VERSION'\nUsage:\t vxstorageinfo [<parameter>]\n\n   Available parameter:\n';
	echo -e '\tall\t- Print all information about the DiskGroup';
	exit;
fi

function device_info { 
	#$dm $DG_NAME $IMPORTED
	LUN=$(vxdmpadm list dmpnode dmpnodename=$1 | grep -i scsi | cut -d':' -f2); 
	DEV=$(vxdmpadm list dmpnode dmpnodename=$1 | grep -i '^path' | cut -d'=' -f2 | cut -d' ' -f2); 
	SIZE=$(vxdisk -o size -o alldgs list -u G | grep -i $dm | awk 'BEGIN {FS=" "}{print $2}'); 
	echo -e $dm' - '$LUN' - '$SIZE' - '$DEV; 
}

# Listing the reachable disks
for DGs in `vxdisk -e -o alldgs list | awk 'BEGIN {FS=" "}{print $4}' | egrep -iv "GROUP|LVM" | sort | uniq`; do 
	DG_NAME=$(echo $DGs | sed -e 's/[\(\)]//g')
	# If the device unconfigured or LVM
	if [[ $DG_NAME == '-' ]]; then 
		if (( $(vxdisk -e -o alldgs list | grep -iw '-' | grep -iv LVM -c) )); then 
			echo -e '\nUnconfigured '; 
			for dm in `vxdisk -e -o alldgs list | grep -iw '-' | grep -iv LVM | grep -iv '(' | cut -d' ' -f1`; do 
				device_info $dm $DG_NAME
			done;
		fi;	
		if (( $(vxdisk -e -o alldgs list | grep -iw '-' | grep -i LVM -c) )); then 
			echo -e '\nLVM '; 
			for dm in `vxdisk -e -o alldgs list | grep -iw '-' | grep -i LVM | grep -iv '(' | cut -d' ' -f1`; do 
				device_info $dm $DG_NAME
			done;
		fi;	
	else 
		echo -en '\n'$DG_NAME' ';
		if (( $(echo $DGs | grep -i "(" -c) )); then echo -e '(deported)'; IMPORTED=0; else echo -e '(imported)'; IMPORTED=1; fi
		for dm in `vxdisk -e -o alldgs list | grep -iw $DG_NAME | cut -d' ' -f1`; do 
			device_info $dm $DG_NAME
		done;
	fi;	
	
	# Print DM, Plex and Volume information
	if (( $ALL && $IMPORTED)); then vxprint -dpv -g $DG_NAME -u G | egrep -i "^dm|^v|^pl"; fi;	
	echo -e '';
done
