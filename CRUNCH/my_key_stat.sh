#!/bin/bash

KEY_INFO=`xset q| sed "s/ //g"`
NL=""
CL=""

ELSE="		"

if [[ `echo "$KEY_INFO"| grep "CapsLock:on"` ]]; then CL="CapsLock"; else CL=$ELSE; fi
if [[ `echo "$KEY_INFO"| grep "NumLock:on"` ]]; then NL="NumLock"; else NL=$ELSE; fi

echo -e "$CL		$NL"

exit 0
