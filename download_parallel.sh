#!/bin/bash

# required **lftp**

CONNECTIONS=$1 # number of connections
LINK=$2 # link - work with ftp http https

lftp -c "pget -c -n $CONNECTIONS $LINK"
