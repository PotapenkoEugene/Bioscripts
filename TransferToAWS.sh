#!/bin/bash
# test git
AWSPATH=$1
LOCALPATH=$2

scp -r $LOCALPATH evgenip@172.31.186.68:${AWSPATH}
