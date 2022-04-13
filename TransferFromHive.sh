#!/bin/bash

HIVEPATH=$1
LOCALPATH=$2

scp -r ssapielki@hive01.haifa.ac.il:${HIVEPATH} $LOCALPATH
