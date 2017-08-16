#!/bin/bash

KEY=$1

#KEY="-k"
sudo mkdir -p /etc/X11/xorg.conf.d/

case $KEY in
    -k) sudo rm /etc/X11/xorg.conf.d/20*conf ;;
    -a) if [[ `lspci | grep -E "VGA|3D" | grep -i "NVIDIA"` ]]; then
            echo 'Section "Device"
   Identifier "Nvidia Card"
   Driver "nvidia"
   VendorName "NVIDIA Corporation"
   Option "NoLogo" "true"
   Option      "metamodes"  "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
EndSection' | sudo tee /etc/X11/xorg.conf.d/20-nvidia.conf
        fi
        if [[ `lspci | grep -E "VGA|3D" | grep -i "Radeon"` ]]; then
            echo 'Section "Device"
    Identifier "Radeon"
    Driver "radeon"
    Option "TearFree" "on"
EndSection' | sudo tee /etc/X11/xorg.conf.d/20-radeon.conf
        fi
        if [[ `lspci | grep -E "VGA|3D" | grep -i "intel"` ]]; then
            echo 'Section "Device"
   Identifier  "Intel Graphics"
   Driver      "intel"
   Option      "TearFree"    "true"
EndSection' | sudo tee /etc/X11/xorg.conf.d/20-radeon.conf
        fi
        ;;
     *) echo "-k - delit all config
-a - auto antitering"
        ;;
esac

exit 0
