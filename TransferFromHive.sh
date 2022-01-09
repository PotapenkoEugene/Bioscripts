#!/bin/bash

HIVEPATH=$1
LOCALPATH=$2

scp ssapielki@hive01.haifa.ac.il:${HIVEPATH} $LOCALPATH
