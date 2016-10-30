#!/bin/bash

PROGNAME=${0##*/}
PROGVERSION="13.1.1 2016/05/03"
LOGFILE="/var/log/antix2usb.log"


# TODO: bootloader: arg -b : accept in functions: syslinux|sys, extlinux|ext
# TODO: doc, man page?

# ==================================== VARIABLES ===================================================

# BOOT_MODE="extlinux"
# PERSIST=""              # values: "none", "root"=>rootfs, "home"=>homefs, "both"=>rootfs and homefs
# SQUASFS_NAME=""         # default: linuxfs TODO: hard coded or find  -size +10M (the sidux way)
# USB_MOUNTPOINT=""
# ISO_MOUNTPOINT=""
# DEVICE=""               # /dev/sdx
# PARTITION1=""           # /dev/sdx1, first partition in device
# PARTITION2=""           # /dev/sdx1, 2nd partition in device
# LABEL="antiX"           # if "antiX", partitions will be labeled antiXlive and antiXdata
#                           if not defined in the command line, defaults to DIST_NAME
# CHEATCODES=""           # example: "lang=fr mean lean"
# ISO_SIZE=""             # to check against PARTITION_SIZE (iso size or du of the mounted iso)
# ANTIX_VERSION="M11"     # M11, M8.5; maybe we will support only version >= M11
# PARTITION_SIZE="1024"   # -s parameter, default "full" ** "0" or "full" means: full device **
# PARTITION_FS="ext2"     # fat32 (syslinux), else (isolinux, grub) ext2-3-4(?)
# ISO_FILENAME=""         # full path
# ISO_BASENAME=""
# DIST_NAME=""            # ISO_BASENAME, extension stripped
# SCRIPT_NAME=""          # argv[0], antix2usb, for logs, info
# PROGVERSION=""          # this script version number, version date
# LOGFILE=""              # /var/log/antix2usb.log
# DEBUG=""                # true when "on"
# VERBOSE=""              # true when "on"
# QUIET=""                # true when "on"
# NOCOPY=""               # debugging the script, don't spend time copying the linuxfs file
# ISO_FILE_SIZE="0"
# HOMEFS_SIZE=""
# ROOTFS_SIZE=""

# ==================================== FUNCTIONS ===================================================
#
# main
#
# get_options             # set parameters from comman line args
# check_options           # validity check
#   check_device          # is $DEVICE a valid device?
# check_tools             # syslinux or extlinux or grub available ? if not ask for apt-get install
# check_size              # ISO vs. first partition size
# prepare_partitions      # ...fdisk.distrib, label, boot flag
# mount_partition         # mount usb device
# mount_iso               # mount -o loop iso
# copy_files              # vmlinuz, initrd.gz, linuxfs
#
# bootloader_cfg          # switch on INSTALL_MODE value
#    syslinux_cfg         # write syslinux.cfg
#    extlinux_cfg         # write extlinux.cfg
#    grub_cfg             # write menu
#
# bootloader_install      # switch on INSTALL_MODE value
#    syslinux_install     # run syslinux
#    extlinux_install     # run extlinux
#    grub_install         # run grub-install
#
# error
# assert retval err_msg # check retur value of last command $?
#                              on error prints err_msg and exits 1
#
# info                    # on stdout, displayed on the GUI
# confirm                 # continue ?
# trace                   # on LOGFILE
# usage
#
# ==================================================================================================





# ==================================== LOG ETC =====================================================

# init_log
# args: logfile
init_log()
{
    local logfile=$1
    if [ -f $logfile ]; then
		local sz=$(wc -l $logfile)
		local maxsz=1000
		sz=${sz%% *} # line count
		if [ "$sz" -gt "$maxsz" ]; then
			tail -n $maxsz $logfile > /tmp/tmp.log
			mv /tmp/tmp.log $logfile
		fi
    fi
    # header
    printf -v line '%.0s=' {1..80} # separator
    echo $line >> $logfile
    now=$(date +%Y/%m/%d\ %H:%M:%S)
    echo "$PROGNAME version $PROGVERSION" >> $logfile
    echo "Started $now" >> $logfile
    echo >> $logfile
}

# error: prints message and exits
# args: $1 : error code
#       $2 : message
error()
{
    local exitval="$1"
    shift
    echo "Error: ${exitval} - ${@}" >> $LOGFILE
    echo "Error: $@"
    exit ${exitval}
}

# check return value of last command $?
# args : $1 : numerical value, true: 0, false: !0
#        $2 : error message, printed on error
# on error ($1 != 0), prints message and exits
assert()
{
    if [ ! "$1" ]; then
        error $@
        return 1 # never reached: error exits
    fi
    return 0 # ok
}

# prints message on stdout, writes in logfile, displayed on the GUI
# arg: message
info()    
{
    echo "Info: $1" >> $LOGFILE
    echo "$1"
}

# continue ?
# arg: message
# exits when answer is n, no
confirm()
{
    # if started from gui, don't ask for confirmation
    if [ "$QUIET" = "on" ]; then
        return 0
    fi
    echo -e $1
    read -n 1 -p "Continue? (y/n) " rsp
    echo
    case $rsp in
        "y" | "Y" ) return 0;;
                * ) echo "Exiting" ; exit 1;;
    esac
}

# when debug mode is on, prints the message on stdout
# log in LOGFILE
# arg: message
debug()         
{
    if [ "$DEBUG" == "on" ]; then
        echo "Debug: $1"
    fi
    echo "Debug: $1" >> $LOGFILE
}

# on LOGFILE ? 
trace()         
{
    echo
}

#usage
usage()
{
  cat << EOF
Usage: $PROGNAME [options] iso-file device [cheatcodes]
Installs antiX iso-file on the USB device
Options:
EOF
  cat <<EOF | column -s\& -t
        -h, --help & show this output
        -v, --version & show version information
        -d, --debug & toggle debug mode
        -q, --quiet & toggle quiet mode
        -f, --format=FORMAT & file system: ext2|ext4|fat32
        -s, --size=SIZE & size of the first partition
                        & (defaults to full device)
        -b, --bootloader=grub|iso|ext & boot mode
        -p, --persistence=MODE & set persistence: root|home|both
        --rootfssz=ROOTFS_SIZE & size of the persistent root fs
        --homefssz=HOMEFS_SIZE & size of the persistent home fs
        -l, --label=LABEL & label, default antiX
        -L, --list-devices & prints a list of USB devices and exits
EOF
}

# ==================================== SETTING CHECKING PARAMETERS =================================

# set parameters from comman line args
# args: options
get_options()
{
    echo "Command line: $PROGNAME $*" >> $LOGFILE
    SHORTOPTS="hvdqf:s:b:p:l:Lx"
    LONGOPTS="help,version,debug,quiet,format:,size:,boot:,persist:,\
label:,list-devices,rootfssz:,homefssz:"

    ARGS=$(getopt -s bash --options=$SHORTOPTS  \
      --longoptions=$LONGOPTS --name $PROGNAME -- "$@")
    
    if [ "$?" -ne "0" ]; then
        msg="Error parsing command line args"
        echo $msg >> $LOGFILE
        echo $msg
        exit 1
    fi

    eval set -- "$ARGS"

    while true; do
        case $1 in
          -h|--help)
              usage
              exit 0
              ;;
          -v|--version)
              echo "version: $PROGNAME $PROGVERSION"
              exit 0
              ;;
          -d|--debug)
              #echo "==== debug"
              DEBUG="on"
              ;;
          -q|--quiet)
              #echo "version: $PROGNAME $PROGVERSION"
              QUIET="on"
              ;;
          -x)
              echo "*** Debugging: linuxfs file will not be copied ***"
              NO_COPY="yes"
              ;;
          -f|--format)
              shift
              #echo "==== format: $1"
              PARTITION_FS="$1"
              ;;
          -s|--size)
              shift
              #echo "==== size: $1"
              PARTITION_SIZE="$1" # defaults to "full"
              ;;
          -b|--boot)
              shift
              #echo "==== boot: $1"
              BOOT_MODE="$1"
              ;;
          -p|--persist)
              shift
              #echo "==== persist: $1"
              PERSIST="$1"
              ;;
          -l|--label)
              shift
              #echo "==== label: $1"
              LABEL="$1"
              ;;
          -L|--list-devices)
              list_usb_devices
              exit 0
              LABEL="$1"
              ;;
          --rootfssz)
              shift
              ROOTFS_SIZE="$1"
              ;;
          --homefssz)
              shift
              HOMEFS_SIZE="$1"
              ;;
          --)
              shift
              break
              ;;
          *)
              shift
              break
             ;;
        esac
        shift
    done
    if [ $# -lt 2 ]; then
        echo "==== Missing parameters: iso and/or device."
        usage
        exit 1
    fi
    # remaining args
    #echo "==== iso: [$1]"
    ISO_FILENAME="$1"
    #echo "==== device: [$2]"
    DEVICE="$2"
    shift 2
    #echo "==== cheatcodes: [$@]"
    CHEATCODES="$@"
}

# validity check
check_options()       
{
    # access to iso file
    if [ -z "$ISO_FILENAME" ] || [ ! -r "$ISO_FILENAME" ]; then
        error 1 "Cannot access iso file: \"$ISO_FILENAME\""
    fi

    # set DIST_NAME
    ISO_BASENAME=$(basename ${ISO_FILENAME})
    DIST_NAME=$(basename ${ISO_FILENAME} .iso) # not used

    # is device a plugged usb device?
    check_device
    assert $? "Device $DEVICE is not a valid USB device"

    # persitence option valid
    if [ -n "$PERSIST" ] && [ "$PERSIST" != "home" ] && [ "$PERSIST" != "root" ] && [ "$PERSIST" != "both" ]; then
        error 1 "Invalid -p|--persist option \"$PERSIST\": should be \"root\" or \"home\" or \"both\""
    fi
    
    # assign partition names: PARTITION1 PARTITION2
    PARTITION1="${DEVICE}1"
    PARTITION2="${DEVICE}2"

    # fs defaults to ext2
    if [ -z "$PARTITION_FS" ]; then
        PART1_FS="ext2"
    fi
    # is fs when given in the command line a valid fs format?
    if [ "$PARTITION_FS" != "ext2" ] && [ "$PARTITION_FS" != "ext4" ] && [ "$PARTITION_FS" != "fat32" ]; then
        error 1 "Invalid --format option: should be ext2, ext4 or fat32"
    fi

    # default bootloader
    if [ -z "$BOOT_MODE" ]; then
        BOOT_MODE="extlinux"
    fi
    
    if [ "$BOOT_MODE" == "syslinux" ] && [ "$PARTITION_FS" != "fat32" ]; then
        error 1 "Cannot install syslinux bootloader on a $PARTITION_FS partition"
    elif [ "$BOOT_MODE" == "extlinux" ] && [ "$PARTITION_FS" == "fat32" ]; then
        error 1 "Cannot install extlinux bootloader on a $PARTITION_FS partition"
    fi

    # default label
    if [ -z "$LABEL" ]; then
        LABEL="antiX"
    fi

    if [ "$DEBUG" == "on" ]; then
    cat >> $LOGFILE << EOF
Debug: after check_options:
    iso: $ISO_FILENAME
    device: $DEVICE
    partition size: $PARTITION_SIZE
    partition fs: $PARTITION_FS
    label: $LABEL
    bootloader: $BOOT_MODE
    persist: $PERSIST
    cheatcodes: $CHEATCODES
EOF

    fi
}

valid_label()
{
    local label="$1"
    # label may contain only these characters
    case "$label" in
        *[!A-Za-z0-9-_]*)
            error 1 "Invalid label, allowed characters are: A-Z a-z 0-9 - _"
        ;;
    esac
    if [ ${#label} -gt 16 ]; then
        error 1 "Invalid label: length exceeds 16 characters"
    fi
    return 0
}


#  Bash automatically trims by assigning to variables and by passing arguments.
trim()
{
    echo $1
}

# list USB devices
# prints device, model, size and returns
list_usb_devices()
{
    local list=""
    local id=""
    local dev=""
    # get disk-ids of USB devices
    list=$(ls /dev/disk/by-id/usb-* 2> /dev/null | grep -v '\-part[0-9]')
    #echo $list
    if [ "$list" == "" ]; then
        echo "No USB device found"
        return 1
    fi
    echo "Device    Model                       Size"
    echo "----------------------------------------------"
    for id in $list; do
        device=$(readlink -f $id)
        # get sdx (deletes /dev/ from front of device)
        dev=${device#/*/} 
        vendor=$(cat /sys/block/$dev/device/vendor)
        vendor=$(trim "$vendor") # strip white spaces
        model=$(cat /sys/block/$dev/device/model)
        model=$(trim "$model")
        info_str="$vendor $model"
        info_str=$(trim "$info_str")
        size=$(cat /sys/block/$dev/size) # 512 bytes sectors
        size=$(( $size * 512 / 1000000 ))
        printf "%s  %-25s  %5d MB\n" "$device" "$info_str" "$size"
    done
    return 0
}

# is the device name a valid USB device
# arg: DEVICE
# assigns DEVICE_INFO (vendor model) and DEVICE_SIZE (MB) 
check_device()
{
    local device="$DEVICE"
    local list=""
    local id=""
    local dev=""
    # get disk-ids of USB devices
    list=$(ls /dev/disk/by-id/usb-* 2> /dev/null | grep -v '\-part[0-9]')
    #echo $list
    for id in $list; do
        dev=$(readlink -f $id)
        # echo "=> $id => $dev"
        if [ "$dev" == "$device" ]; then
            # ok, DEVICE matches a USB device like /dev/sdx

            # store id, a full path like:
            # /dev/disk/by-id/usb-_USB_DISK_2.0_07821AB60F14-0:0
            # needed for grub device.map
            DEVICE_ID="$id"
            
            device=${device#/*/} # get sdx (deletes /dev/ from front of device)
            vendor=$(cat /sys/block/$device/device/vendor)
            vendor=$(trim "$vendor") # strip white spaces
            model=$(cat /sys/block/$device/device/model)
            #echo "model: \"$model\""
            model=$(trim "$model")
            info_str="$vendor $model"
            info_str=$(trim "$info_str")
            size=$(cat /sys/block/$device/size) # 512 bytes sectors
            size=$(( $size * 512 / 1000000 ))
            DEVICE_INFO=$info_str
            DEVICE_SIZE=$size
            debug "USB device $device: \"$info_str\", size: $size MB"
            # ok, device is a USB device
            return 0 
        fi
    done
    # no device detected, or wrong name
    error 1 "Cannot access USB device $device. Sorry"
}

# list USB devices
list_usb_devices()
{
    local list=""
    local id=""
    local dev=""
    # get disk-ids of USB devices
    list=$(ls /dev/disk/by-id/usb-* 2> /dev/null | grep -v '\-part[0-9]')
    #echo $list
    if [ "$list" == "" ]; then
        echo "No USB device found"
        return 1
    fi
    echo "Device    Model                       Size"
    echo "----------------------------------------------"
    for id in $list; do
        device=$(readlink -f $id)
        # get sdx (deletes /dev/ from front of device)
        dev=${device#/*/} 
        vendor=$(cat /sys/block/$dev/device/vendor)
        vendor=$(trim "$vendor") # strip white spaces
        model=$(cat /sys/block/$dev/device/model)
        model=$(trim "$model")
        info_str="$vendor $model"
        info_str=$(trim "$info_str")
        size=$(cat /sys/block/$dev/size) # 512 bytes sectors
        size=$(( $size * 512 / 1000000 ))
        printf "%s  %-25s  %5d MB\n" "$device" "$info_str" "$size"
    done
    return 0
}

# syslinux or extlinux or grub available ? if not ask for apt-get install
check_tools()
{
    case "$BOOT_MODE" in
        sys* )
            debug "Checking syslinux"
            SYSLINUX=$(type -P syslinux)
            SYSLINUX=$(type -P syslinux)
            if [ "$?" -ne "0" ]; then
                confirm "syslinux appears not installed. Should I install it?"
                apt-get install syslinux
                # success ?
                SYSLINUX=$(type -P syslinux)
                if [ "$?" -ne "0" ]; then
                    error "$?" "Failed to install syslinux"
                fi
            fi
            debug "syslinux ok"
            ;;
        ext*) 
            debug "Checking extlinux"
            EXTLINUX=$(type -P extlinux)
            if [ "$?" -ne "0" ]; then
                confirm "extlinux appears not installed. Should I install it?"
                apt-get install extlinux
                # success ?
                EXTLINUX=$(type -P extlinux)
                if [ "$?" -ne "0" ]; then
                    error "$?" "Failed to install extlinux"
                fi
            fi
            debug "extlinux ok"
            ;;
        grub*)
            debug "TODO: check grub version?"
            return
            ;;
        * )
            echo "Invalid boot mode: \"$BOOT_MODE\". Exiting"
            exit 1;;
    esac
}

# check_size()
# args: file_path
#       partition_size
# if the file system and the boatloader stuff does not fit in the given partition size
# then exit 1
# TODO: update this: add the homefs and/or rootfs sizes when persistence enable
#       see the python gui script
check_size() 
{
    local iso_file=$ISO_FILENAME
    local part_size=$PARTITION_SIZE
    if [ $part_size == "0" ] || [ $part_size == "full" ]; then
        debug "TODO: check_size: check size when using full device"
        return 0
    fi
    # size of iso, bytes
    iso_sz=`ls -l ${iso_file} | awk '{print $5}' `
    # size of iso MB, and required place (estimated)
    debug "TODO: estimation of required size, for squafs, ratio?...."
    let iso_sz_mb=iso_sz/1000000
    let req_sz_mb=iso_sz_mb+10

    #echo "check_size() iso size: $iso_sz bytes, required: $req_sz_mb MB, part. size: $part_size MB"
    if [ $req_sz_mb -gt $part_size ]; then
        error 1 "ISO file doesn't fit in partition"
        exit 1
    fi
}

test_write_speed()
#  arg: usb mount point
{
    local test_file="$1"/test_write_speed.tmp

    # dd 10 MB of data to the USB device in a tmp file
    # The 'time' bash builtin command does not give an easy to parse output...
    # Temporary change locale to get a dot as decimal separator (see regexp)
    line=$(LANG=C dd count=10 bs=1M if=/dev/zero of="$test_file" oflag=sync 2>&1 | tail -1)

    # Output sample:
    #10485760 bytes (10 MB) copied, 0.810747 s, 12.9 MB/s
    # Match the decimal number preceding 'MB/s' in this line
    [[ $line =~ ([0-9]*.[0-9]*)\ MB\/s ]] && speed=${BASH_REMATCH[1]}

    if [ -n "$speed" ]; then
        echo "Estimated write speed: $speed MB/s"
    fi
    rm $test_file
}

# ==================================== CORE FUNCTIONS ==============================================

refresh_block_devices()
{
    if which udevadm > /dev/null; then
        udevadm trigger --subsystem-match=block
        udevadm settle --timeout=30
    elif which udevtrigger > /dev/null; then
        udevtrigger --subsystem-match=block
        udevsettle --timeout=30
    fi
}

# prepare_partition $DEVICE $PARTITION_FS $SIZE $LABEL
# ...fdisk.distrib, label, boot flag
# erase partition table, then
# prepare ** one ** bootable partition
#     using either full device when SIZE is 0
#     or the given size
prepare_partition()
{
    local device=$DEVICE
    local partition1=$PARTITION1
    local partition2=$PARTITION2
    local fs=$PARTITION_FS
    local size=$PARTITION_SIZE
    local label1=${LABEL}live
    local label2=${LABEL}data

    valid_label "$label1"

    debug "prepare_partition DIST_NAME: ${DIST_NAME} label1: $label1 label2: $label2"

    # is the device mounted
    vols=`mount | awk '/^\/dev\/sd/ { print $1 }' `
    for vol in ${vols}; do
        if [ $vol = $partition1 ]; then 
            debug "TODO: $vol appears to be mounted: propose to umount?"
            error 2 "$vol appears to be mounted! Unmount it, and retry. Exiting."
            exit 1
        fi
    done

    local ev
    local is_bootable
    local part_id
    local mkfs_part1
    local part_type

    case "$fs" in
        fat32)
            info "Preparing bootable fat32 partition on device $device"
            mkfs_part1="mkfs.vfat -n $label1"
            part_type=b
            ;;
        ext2)
            info "Preparing bootable ext2 partition on device $device"
            mkfs_part1="mkfs.ext2 -q -m 1 -L $label1"
            mkfs_part2="mkfs.ext2 -q -m 1 -L $label2"
            part_type=83
            ;;
        ext4)
            info "Preparing bootable ext4 partition on device $device"
            mkfs_part1="mkfs.ext4 -q -m 1 -L $label1"
            mkfs_part2="mkfs.ext4 -q -m 1 -L $label2"
            part_type=83
            ;;
        *)
            error 1 "Invalid file system type: \"$fs\"."
            usage
            exit 1
            ;;
    esac

    info "USB device: $device Model: $DEVICE_INFO Size: $DEVICE_SIZE MB"
    confirm "Ready to format $device. This will erase all data on the device."

    # clear the partition table
    info "Clearing partition table"
    dd if=/dev/zero of=$device bs=1M count=16 2> /dev/null
    assert $? "Failed to zero $device"
    
    # create partition1
    # new, primary, part number, first cylinder: default (1), 
    # last cylinder: default (full size), type: ${part_type},
    # bootable
    #
    info "Creating bootable partition fs: ${fs}"
    debug "Running fdisk.distrib..."
    echo "----------------" >> $LOGFILE
    
    # fdisk.distrib commands:
    #    [n] : new
    #    [p] : primary
    #    [1] : partition number
    #    [] : fist cylinder: default 1
    #    [+384M] : size (empty: full device)
    #    [t] : set partition system id
    #    [Hex code] : partition type
    #    [a] : set bootable flag
    #    [1] : partition number
    #    [p] :  print the partition table
    #    [w] :  write table to disk and exit

    if [ "$size" == "0" ] || [ "$size" == "full" ]; then
        the_size="" # enter an empty string to allocate the full device size to this partition
    else
        the_size="+${size}M"
    fi
    
    fdisk.distrib "$device" > /dev/null 2>&1 >> $LOGFILE \
<<EOF
n
p
1

${the_size}
t
${part_type}
a
1
p
w
EOF

    ev="$?"
    if [ "$ev" -ne 0 ] || [ ! -b "$partition1" ]; then
            error 1 "Failed to create partition $partition on device: $device"
    fi

    echo "----------------" >> $LOGFILE
    debug "fdisk.distrib done."

    # update table of devices for the kernel
    refresh_block_devices

    info "Creating file system on $partition1, please wait..."

    $mkfs_part1 "$partition1" 2>&1 >> $LOGFILE
    assert $? "Failed to format $partition1"

    info "Prepared bootable partition: $partition1 label: $label1"

}
# end prepare_partition


# mount first partition of usb device
# mkdir boot directory on mounted partition
mount_partition()
{
        local partition1="$PARTITION1"
        local usb_mountpoint="$USB_MOUNTPOINT"
        info "Mounting $partition1 on temporary mount point"
        
        mkdir -p "$usb_mountpoint"
        mount -o rw "$partition1" "$usb_mountpoint"
        assert "$?" "Failed to mount $partition1 on $usb_mountpoint"

        debug "Usb device mount point ready: $usb_mountpoint"
        
        mkdir $usb_mountpoint/boot
        assert "$?" "Cannot create boot directory on $usb_mountpoint"
        
        info "USB device mount point ready"
}

# mount -o loop iso
mount_iso()
{
        local iso_file="$ISO_FILENAME"
        local iso_mountpoint="$ISO_MOUNTPOINT"
        
        mkdir -p $iso_mountpoint
        info "Mounting $iso_file on temporary mount point"
        
        mount -t iso9660 -o loop,ro "${iso_file}" "${iso_mountpoint}"
        assert "$?" "Failed to mount $iso_file on $iso_mountpoint"

        debug "Iso file mount point ready: $iso_mountpoint"
        info "Iso file mount point ready"
}


umount_and_exit()
{
        local partition1="$PARTITION1"
        local usb_mountpoint="$USB_MOUNTPOINT"
        local iso_file="$ISO_BASENAME"
        local iso_mountpoint="$ISO_MOUNTPOINT"

        info "Unmounting $partition1 (please wait...)"

        umount -l "$partition1" 2>&1 >> $LOGFILE
        [ "$?" == 0 ] || echo "Failed to umount $partition1" >> $LOGFILE
        rmdir "$usb_mountpoint" 2>&1 >> $LOGFILE
        [ "$?" == 0 ] || "Failed to remove USB mount point: $usb_mountpoint" >> $LOGFILE

        umount "$iso_mountpoint" 2>&1 >> $LOGFILE 
        [ "$?" == 0 ] || "Failed to umount $iso_file" >> $LOGFILE
        rmdir "$iso_mountpoint" 2>&1 >> $LOGFILE 
        [ "$?" == 0 ] || "Failed to remove ISO mount point: $iso_mountpoint" >> $LOGFILE

        info "Mount points removed."

        if [ "$STATUS" == "ok" ]; then
            # called at end of process
            info "Process completed."
        else
            # called on interrupt or error
            info "Process failed"
        fi
}

# copy vmlinuz, initrd.gz, linuxfs
# define NO_COPY for debug: saves time not copying the antiX compressed fs
# also useful if using usb device to boot frugal ntfs hard drive partition.
#NO_COPY="yes" 

copy_files()
{
    local iso_mountpoint="$ISO_MOUNTPOINT"
    local usb_mountpoint="$USB_MOUNTPOINT"
    local boot_mode="$BOOT_MODE"
    local partition1="$PARTITION1"
    local partition2="$PARTITION2"

    if [ -z "$usb_mountpoint" ]; then
        error 1 "USB mount point undefined"
    fi

    # Get iso size in MB
    ISO_FILE_SIZE=$(ls -l --block-size=MB ${iso_mountpoint}/antiX/linuxfs | awk '{print $5}')

    # Copy compressed antiX file system
    mkdir ${usb_mountpoint}/antiX
    assert "$?" "Failed to create directory ${usb_mountpoint}/antiX"

    if [ "$NO_COPY"  == "yes" ]; then
        echo "*** Debugging: Warning: antiX linuxfs is not copied ***"
        echo "*** Debugging: Remove the -x option! ***"
    else
        info "Copying antiX compressed file system (${ISO_FILE_SIZE}) to the mounted device"
        # Write an estimation of write speed...
        test_write_speed "${usb_mountpoint}"
        info "This will take a few minutes, relax..."
        cp -aR $VERBOSE "${iso_mountpoint}/antiX" "${usb_mountpoint}"
        
        assert "$?" "Failed to cp ${iso_mountpoint}/antiX" "${usb_mountpoint}"
    fi
    
    info "Files copied to mounted device"
    
    info "Copying files to boot directory"
    
    # Copy initrd.gz vmlinuz to mounted USB /antiX
    for i in initrd.gz vmlinuz; do
        info "... ${i}"
        cp $VERBOSE ${iso_mountpoint}/antiX/${i} ${usb_mountpoint}/antiX
        assert "$?" "Failed to copy file ${iso_mountpoint}/boot/${i} to ${usb_mountpoint}/antiX"
    done

    # More stuff ?
    for i in cdrom.ico version; do
        if [ -e ${iso_mountpoint}/${i} ] ; then
            info "... ${i}"
            cp $VERBOSE ${iso_mountpoint}/${i} ${usb_mountpoint}                
            assert "$?" "Failed to copy file ${iso_mountpoint}/${i} to ${usb_mountpoint}"
        fi
    done
    
    # Copy memtest
    for i in memtest; do
        info "... ${i}"
        cp $VERBOSE ${iso_mountpoint}/boot/${i}* ${usb_mountpoint}/boot
        assert "$?" "Failed to copy file ${iso_mountpoint}/boot/${i} to ${usb_mountpoint}/boot"
    done

    debug "in copy_files: boot mode: \"$boot_mode\""
    
    
    debug "in copy files: CHEATCODES: $CHEATCODES"
    
    # Copy and edit the configuration files
    #case "$boot_mode" in
        #ext*)
            #extlinux_cfg ;;
        #sys*)
            #syslinux_cfg ;;
        #grub)
            #grub_cfg ;;
        #*)
           # error 1 "Invalid boot mode" ;;
    #esac
    info "Copy completed"
    return 0
}

#Make persistence files
persist_make()
{
# Make persistence and save to tmp.antix_usb...

    local iso_mountpoint="$ISO_MOUNTPOINT"
    local usb_mountpoint="$USB_MOUNTPOINT"
    local boot_mode="$BOOT_MODE"
    local partition1="$PARTITION1"
    local partition2="$PARTITION2"

    if [ -z "$usb_mountpoint" ]; then
        error 1 "USB mount point undefined"
    fi

    PRF=rootfs
    PHF=homefs

    echo -n "Do you want to set up live persistence? [y|N]"
    read INPUT
    if [ "$INPUT" = "y" ]; then
        # cd into tmp dir
        cd $usb_mountpoint/antiX
        # Choose fs
        echo -n "You can set up $PRF and/or $PHF "
        echo ""
        echo -n "Do you want to set up $PRF ? [y|N]"
        read INPUT
        if [ "$INPUT" = "y" ]
        then
            echo "Set up $PRF"
            echo -n "Type in file size. Make sure you have enough space. Just press Enter for default 512 (MB) "
            read CFS
            if [[ "$CFS" == "" ]]
                then CFS=512
            fi
            # check here that there is enough space. If ok continue else warn.
            echo -n "Type in file type: ext2, ext4 or ext4. Just press Enter for recommended default ext2 "
            read FS
            if [[ "$FS" == "" ]]
                then FS=ext2
            fi
            dd if=/dev/zero of=$PRF bs=1M count=0 seek=$CFS
            mkfs.$FS -q -m 0 -O ^has_journal -F $PRF
        else
            echo "$PRF not set up"
        fi
        echo -n "Do you want to set up $PHF ? [y|N]"
        read INPUT
        if [ "$INPUT" = "y" ]
        then
            echo "Set up $PHF"
            echo -n "Type in file size. Just press Enter for default 128 (MB)"
            read CFS
            if [[ "$CFS" == "" ]]
            then CFS=128
            fi
            # check here that there is enough space. If ok continue else warn.
            echo -n "Type in file type: ext2, ext4 or ext4. Just press Enter for recommended default ext2 "
            read FS
            if [[ "$FS" == "" ]]
                then FS=ext2
            fi
            dd if=/dev/zero of=$PHF bs=1M count=0 seek=$CFS
            mkfs.$FS -q -m 0 -O ^has_journal -F $PHF
        else
            echo "$PHF not set up"
        fi

        echo -n "Finished."
        echo "File(s) have been saved to $usb_mountpoint/antiX "
        echo ""
        cd ..
    else
        echo "No persistence set up."
    fi
}

# Make persistence files
# non-interactive version, uses -p PERSIST parameter
# and default sizes for homefs and rootfs files
persist_make_silent()
{
# Make persistence and save to tmp.antix_usb...

    local iso_mountpoint="$ISO_MOUNTPOINT"
    local usb_mountpoint="$USB_MOUNTPOINT"
    local boot_mode="$BOOT_MODE"
    local partition1="$PARTITION1"
    local partition2="$PARTITION2"
    local persist_root="false"
    local persist_home="false"

    if [ -z "$usb_mountpoint" ]; then
        error 1 "USB mount point undefined"
    fi
    
    #echo "PERSIST=$PERSIST"
    
    if [ "$PERSIST" = "home" ]; then
        persist_home="true"
    fi
    if [ "$PERSIST" = "root" ]; then
        persist_root="true"
    fi
    if [ "$PERSIST" = "both" ]; then
        persist_root="true"
        persist_home="true"
    fi
    
    PRF=rootfs  # Persistent Root File name
    PHF=homefs  # Persistent Home File name

    cd $usb_mountpoint/antiX
    FS="$PARTITION_FS"

    if [ "$persist_root" = "true" ]; then
        if [ -n "$ROOTFS_SIZE" ]; then
            CFS="$ROOTFS_SIZE"
        else
            CFS=512
        fi
        info "Preparing root persistence (size $CFS MB)..."
        dd if=/dev/zero of=$PRF bs=1M count=0 seek=$CFS
        mkfs.$FS -q -m 0 -O ^has_journal -F $PRF
    fi
    if [ "$persist_home" = "true" ]; then
        if [ -n "$HOMEFS_SIZE" ]; then
            CFS="$HOMEFS_SIZE"
        else
            CFS=512
        fi
        info "Preparing home persistence (size $CFS MB)..."
        dd if=/dev/zero of=$PHF bs=1M count=0 seek=$CFS
        mkfs.$FS -q -m 0 -O ^has_journal -F $PHF
    fi
    cd ..
}

# switch on INSTALL_MODE value
bootloader_cfg()   
{
local boot_mode="$BOOT_MODE"
    case "$boot_mode" in
    ext*)
        debug "Calling extlinux_cfg"
        extlinux_cfg ;;
    sys*)
        debug "Calling syslinux_cfg"
        syslinux_cfg ;;
    *)
        error 1 "Invalid boot mode" ;;
    esac

}

# write syslinux.cfg
syslinux_cfg()    
{
    local iso_mountpoint="$ISO_MOUNTPOINT"
    local usb_mountpoint="$USB_MOUNTPOINT"
    local boot_mode="$BOOT_MODE"
    # Copy syslinux cfg files
    info "Copying syslinux config files from iso"
    cp -R $VERBOSE ${iso_mountpoint}/boot/syslinux ${usb_mountpoint}/boot

    # Rename isolinux directory and isolinux.cfg
    #mv ${usb_mountpoint}/boot/isolinux ${usb_mountpoint}/boot/syslinux
    #mv ${usb_mountpoint}/boot/syslinux/isolinux.cfg ${usb_mountpoint}/boot/syslinux/syslinux.cfg
    #touch ${usb_mountpoint}/boot/syslinux/gfxsave.on 
    #echo 1 > ${usb_mountpoint}/boot/syslinux/gfxsave.on

    # Copy grub cfg files for UEFI
    info "Copying grub directory and EFI files from iso"
    cp -R $VERBOSE ${iso_mountpoint}/boot/grub ${usb_mountpoint}/boot
    cp -R $VERBOSE ${iso_mountpoint}/efi ${usb_mountpoint}

    assert "$?" "Failed to copy grub configuaration in ${usb_mountpoint}/boot/grub"

    if [ -n "$CHEATCODES" ]; then
        # add cheatcodes to each kernel line (not to "kernel /boot/memtest ..."
        # warning: sed command s in double quotes for $CHEATCODES evaluation

        sed "s/linux.*vmlinuz.*/& ${CHEATCODES}/" ${iso_mountpoint}/boot/grub/grub.cfg > \
                                          ${usb_mountpoint}/boot/grub/grub.cfg
        # end sed
    fi
}

# configure for extlinux: write extlinux.cfg
# use gfxboot
extlinux_cfg()    
{
    local iso_mountpoint="$ISO_MOUNTPOINT"
    local usb_mountpoint="$USB_MOUNTPOINT"
    local boot_mode="$BOOT_MODE"
    # Copy syslinux cfg files
    info "Copying syslinux directory and config files from iso and configuring for extlinux"
    cp -R $VERBOSE ${iso_mountpoint}/boot/syslinux ${usb_mountpoint}/boot
    
    # Copy grub cfg files for UEFI (useful for setting up EUFI boot by hand)
    info "Copying grub directory and EFI files from iso"
    cp -R $VERBOSE ${iso_mountpoint}/boot/grub ${usb_mountpoint}/boot
    cp -R $VERBOSE ${iso_mountpoint}/efi ${usb_mountpoint}

    ## Rename syslinux directory and syslinux.cfg
    mv ${usb_mountpoint}/boot/syslinux ${usb_mountpoint}/boot/extlinux
    mv ${usb_mountpoint}/boot/extlinux/syslinux.cfg ${usb_mountpoint}/boot/extlinux/extlinux.conf
    #touch ${usb_mountpoint}/boot/extlinux/gfxsave.on 
    #echo 1 > ${usb_mountpoint}/boot/extlinux/gfxsave.on
    if [ -n "$CHEATCODES" ]; then
        # Add cheat codes, like lang=fr mirror=fr to the lines starting with append
        sed "s/APPEND.*/& ${CHEATCODES}/" ${iso_mountpoint}/boot/syslinux/syslinux.cfg > \
                                              ${usb_mountpoint}/boot/extlinux/extlinux.conf
    fi
}

# switch on INSTALL_MODE value
bootloader_install()   
{
    local boot_mode="$BOOT_MODE"
    case "$boot_mode" in
    ext*)
        debug "Calling extlinux_install"
        extlinux_install ;;
    sys*)
        debug "Calling syslinux_install"
        syslinux_install ;;
    *)
        error 1 "Invalid boot mode" ;;
    esac
}

# run syslinux
syslinux_install()
{
        local partition1="$PARTITION1"
        
        SYSLINUX=$(type -P syslinux)

        # syslinux /dev/sdc1
        # Important : You should exexecute syslinux /dev/sdx1 
        # each time syslinux.cfg is modified, in order to have
        # configuration settings taken into account. 
        #
        syslinux $partition1
        assert "$?" "Installation of boot loader syslinux failed."

        # Install MBR
        dd bs=440 conv=notrunc count=1 if=/usr/lib/syslinux/mbr/mbr.bin of=$DEVICE
        assert "$?" "Installation of master boot record failed."

        info "syslinux successfully installed to $partition1"
        return 0
}


# run extlinux
extlinux_install()    
{
        local partition1="$PARTITION1"
        local usb_mountpoint="$USB_MOUNTPOINT"
        local device_id="$DEVICE_ID"
        
        EXTLINUX=$(type -P extlinux)

        debug "Installing extlinux"
        extlinux --install ${usb_mountpoint}/boot/extlinux > /dev/null 2>&1 >> $LOGFILE
        assert "$?" "Installation of boot loader extlinux failed."

        # Install MBR
        debug "Installing MBR"
        dd bs=440 conv=notrunc count=1 if=/usr/lib/syslinux/mbr/mbr.bin of=$DEVICE > /dev/null 2>&1 >> $LOGFILE
        assert "$?" "Installation of master boot record failed."

        info "extlinux successfully installed to $partition1"
        return 0
}


# return value of main, used by function umount_and_exit set bu trap on exit or interrupt
STATUS=""

# main
main()
{
    init_log $LOGFILE
    get_options $*
    check_options
    check_tools
    check_size
    prepare_partition
    mount_partition
    mount_iso
    trap "{ [ -d "$USB_MOUNTDIR" ] && umount_and_exit; }" SIGINT SIGTERM EXIT
    copy_files
    if [ "$QUIET" = "on" ]; then
        # Set up persistence files according to command line options
        # with default file names and location and size
        persist_make_silent
    else
        persist_make
    fi
    bootloader_cfg
    bootloader_install
    
    # Variable used in umount_and_exit
    STATUS="ok"
    
}

# ==================================== PROGRAM =====================================================

# Initialise defaults

BOOT_MODE="extlinux"
PERSIST=""          # values: "" empty string: false, "home", "full"
SQUASFS_NAME="linuxfs"     # default: antiX TODO: hard coded or find  -size +10M (the sidux way)
USB_MOUNTPOINT=""
ISO_MOUNTPOINT=""
DEVICE=""           # /dev/sdx
PARTITION1=""       # /dev/sdx1, the fist partition
PARTITION2=""       # /dev/sdx1, the 2nd partition
LABEL=""            # empty: will default to antiX
CHEATCODES=""       # example: "lang=fr mean lean"
ISO_SIZE=""         # to check against PARTITION_SIZE (iso size or du of the mounted iso)
ANTIX_VERSION="13" # M11, M8.5; maybe we will support only version >= M11
PARTITION_SIZE="full"   # default: full device, set by -s parameter
PARTITION_FS="ext4"     # fat32 (syslinux), else (isolinux, grub) ext2-3-(4?)
ISO_FILENAME=""     # full path
ISO_BASENAME=""
DIST_NAME=""        # ISO_BASENAME, extension stripped
SCRIPT_NAME=""      # argv[0], antix2usb, for logs, info
DEBUG=""            # true when "on"
VERBOSE=""          # true when "on"
QUIET=""            # true when "on"
NOCOPY=""           # debugging the script, don't loose time copying the linuxfs file
HOMEFS_SIZE=""
ROOTFS_SIZE=""

USB_MOUNTPOINT="/tmp/antix_usb"
ISO_MOUNTPOINT="/tmp/antix_iso"

# We need root privileges
if [ $(id -u) != 0 ]; then 
    echo "You need to be root to run this script."
    exit 1
fi

# Run
main $*
