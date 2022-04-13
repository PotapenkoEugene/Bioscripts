#!/bin/bash

HIVEPATH=$1
LOCALPATH=$2

scp -r $LOCALPATH ssapielki@hive01.haifa.ac.il:${HIVEPATH}
