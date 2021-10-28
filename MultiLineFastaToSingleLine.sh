 
#!/bin/bash

MULTILINEFASTA=${1:-/dev/stdin}

sed ':a;N;/^>/M!s/\n//;ta;P;D' < $MULTILINEFASTA
