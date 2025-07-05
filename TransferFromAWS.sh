#!/bin/bash
scp ./test_image evgenip@172.31.186.68:/data/bucket/evgenip
AWSPATH=$1
LOCALPATH=$2

scp -r evgenip@172.31.186.68:${AWSPATH} $LOCALPATH
