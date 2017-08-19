#!/bin/bash

KEY=$1

#KEY="-k"
if ! [[ -d /etc/X11/xorg.conf.d ]]; then
    sudo mkdir -p /etc/X11/xorg.conf.d/
fi

rm_20conf () {
if [[ `ls /etc/X11/xorg.conf.d/20*` ]]; then
    echo remove all files 20\*
    sudo rm /etc/X11/xorg.conf.d/20*conf 
fi
}

mk_20_nvidia () {
echo make 20-nvidia.conf
echo 'Section "Device"
   Identifier "Nvidia Card"
   Driver "nvidia"
   VendorName "NVIDIA Corporation"
   Option "NoLogo" "true"
   Option      "metamodes"  "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
EndSection' | sudo tee /etc/X11/xorg.conf.d/20-nvidia.conf
}

mk_20_radeon () {
echo make 20-radeon.conf
echo 'Section "Device"
    Identifier "Radeon"
    Driver "radeon"
    Option "TearFree" "on"
EndSection' | sudo tee /etc/X11/xorg.conf.d/20-radeon.conf
}

mk_20_intel () {
echo make 20-intel.conf
echo 'Section "Device"
   Identifier  "Intel Graphics"
   Driver      "intel"
   Option      "TearFree"    "true"
EndSection' | sudo tee /etc/X11/xorg.conf.d/20-intel.conf
}

case $KEY in
    -d) rm_20conf;;
    -a) if [[ `lspci | grep -E "VGA|3D" | grep -i "NVIDIA"` ]]; then rm_20conf; mk_20_nvidia; fi
        if [[ `lspci | grep -E "VGA|3D" | grep -i "Radeon"` ]]; then rm_20conf; mk_20_radeon; fi
        if [[ `lspci | grep -E "VGA|3D" | grep -i "intel"` ]]; then rm_20conf; mk_20_intel; fi
        ;;
    -i) rm_20conf; mk_20_intel;;
    -n) rm_20conf; mk_20_nvidia;;
    -r) rm_20conf; mk_20_radeon;;
     *) echo "-d - delete all config
-a - auto antitering
-i - intel
-n - nvidia
-r - radeon"
        ;;
esac

exit 0
