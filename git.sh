#!/bin/bash
git add .&&git commit -m `date|sed "s/ /_/g"`&&git push
echo "
Push Enter to exit!"
read x
exit 0
