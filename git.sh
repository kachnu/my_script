#!/bin/bash
git add .
git commit -m `date|sed "s/ /_/g"`
git push
read x
exit 0
