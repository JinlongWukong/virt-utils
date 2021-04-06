#!/bin/bash

set -ue

# This will create few linux vm

usage () {
	echo "usage: ${0##*/}: [--cpu <cpu number>] [--memory <memory size>] [--bridge <bridge>] [--prefix <prefix>] [--number <vm number>] "
}

ARGS=$(getopt \
	-o c:m:b:p:n: \
	--long help,cpu:,memory:,bridge:,prefix:,number: -n ${0##*/} \
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
		-c|--cpu)
			cpu_number="$2"
			shift 2
			;;
		-m|--memory)
			memory_size="$2"
			shift 2
			;;
		-b|--bridge)
			bridge="$2"
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


# set default value
: ${cpu_number:=2}
: ${memory_size:=2048}
: ${bridge:=virbr0}
: ${number:=1}

# loop work
for(( i=1;i<=$number;i++))
do
  if [ ! -f "$prefix-$i.img" -o ! -f "$prefix-$i.iso" ]; then
    echo -e "ERROR: $prefix-$i.img or $prefix-$i.iso not found"
    exit 1
  fi

  virt-install --import --cpu host \
--name "$prefix-$i" \
--memory "$memory_size" \
--vcpus "$cpu_number" \
--disk "$prefix-$i.img",format=qcow2,bus=virtio \
--disk "$prefix-$i.iso",device=cdrom \
--network bridge="$bridge",model=virtio \
--os-type=linux \
--graphics spice --noautoconsole
done