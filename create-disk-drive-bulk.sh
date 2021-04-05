#!/bin/bash

set -ue

# This will generate boot disk images

usage () {
	echo "usage: ${0##*/}: [--copy <orign cloud image>] [--size <disk size>] [--prefix <prefix>] [--number <number>] "
}

ARGS=$(getopt \
	-o c:s:p:n: \
	--long help,copy:,size:,prefix:,number: -n ${0##*/} \
	-- "$@")

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
		-c|--copy)
			copy_from="$2"
			shift 2
			;;
		-s|--size)
			disk_size="$2"
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

! [[ "$prefix" ]] && echo -e "ERROR: -p, prefix must be given" && exit 1
! [[ "$copy_from" ]] && echo -e "ERROR: -c, copy must be given" && exit 1

# set default value of number is 1
: ${number:=1}

# loop work
for(( i=1;i<=$number;i++))
do
  if [ -f "$prefix-$i.img" ]; then
    echo -e "WARNING: $prefix-$i.img already existed, skip"
    continue
  fi
  cp "$copy_from" "$prefix-$i.img"
  echo -e "$prefix-$i.img" created
  [[ "$disk_size" ]] && qemu-img resize "$prefix-$i.img" "$disk_size"
done