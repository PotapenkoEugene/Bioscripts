#!/bin/bash

MIGALPATH=$1
LOCALPATH=$2

scp -o IdentitiesOnly=yes -i ~/.ssh/id_rsa -r $LOCALPATH potapgene@172.16.11.55:${MIGALPATH}
