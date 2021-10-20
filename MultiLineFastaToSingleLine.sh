 
#!/bin/bash

MULTILINEFASTA=$1

sed ':a;N;/^>/M!s/\n//;ta;P;D' < $MULTILINEFASTA
