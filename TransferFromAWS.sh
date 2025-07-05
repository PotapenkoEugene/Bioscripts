#!/bin/bash
AWSPATH=$1
LOCALPATH=$2

scp -r evgenip@172.31.186.68:${AWSPATH} $LOCALPATH
