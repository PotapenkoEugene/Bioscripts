#!/bin/bash

MIGALPATH=$1
LOCALPATH=$2

scp -r $LOCALPATH potapgene@172.16.11.55:${MIGALPATH}
