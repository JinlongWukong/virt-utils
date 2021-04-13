#!/bin/bash

# This will generate a openstack-style config drive image suitable for
# use with cloud-init.  You may optionally pass in an ssh public key
# (using the -k/--ssh-key option) and a user-data blob (using the
# -u/--user-data option).

usage () {
	echo "usage: ${0##*/}: [--ssh-key <pubkey>] [--vendor-data <file>] [--user-data <file>] [--prefix <prefix>] [--number <number>] "
}

ARGS=$(getopt \
	-o k:u:v:p:n: \
	--long help,ssh-key:,user-data:,vendor-data:,prefix:,number: -n ${0##*/} \
	-- "$@")

saveARGS="$@"

if [ $? -ne 0 ]; then
	usage >&2
	exit 2
fi

eval set -- "$ARGS"

while :; do
	case "$1" in
		--help)
			usage
			exit 0
			;;
		-k|--ssh-key)
			ssh_key="$2"
			shift 2
			;;
		-u|--user-data)
			user_data="$2"
			shift 2
			;;
		-v|--vendor-data)
			vendor_data="$2"
			shift 2
			;;
		-p|--prefix)
			prefix="$2"
			shift 2
			;;
		-n|--number)
			number="$2"
			shift 2
			;;
		--)	shift
			break
			;;
	esac
done

BASEDIR=$(dirname $0)
# it's a wrapper of create-config-drive for bulk creatation, so create-config-drive.sh must existed
if [ ! -f "$BASEDIR/create-config-drive.sh" ]; then
  echo -e "ERROR: create-config-drive.sh not found!"
  exit 1
fi

if ! [ "$prefix" ]; then
  echo -e "ERROR: -p, prefix must be given"
	exit 1
fi

# set default value of number is 1
: ${number:=1}

# remove -p xxx -n xx  from args to give right args to create-config-drive.sh
inARGS=$(echo "$saveARGS" | sed 's/-p [[:graph:]]*//g;s/-n [[:digit:]]*//g;s/--prefix [[:graph:]]*//g;s/--number [[:digit:]]*//g;')

# loop work
for(( i=1;i<=$number;i++))
do
  if [ -f "$prefix-$i.iso" ]; then
    echo -e "WARNING: $prefix-$i.iso already existed, skip"
    continue
  fi
  "$BASEDIR/create-config-drive.sh" $inARGS -h $prefix-$i $prefix-$i.iso
done