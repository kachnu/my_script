#!/bin/bash

screen -dmS mytest bash -c 'htop; exec bash'
screen -S mytest -x -X screen -p mc bash -c 'cd / ; mc; exec bash'
exit 0
