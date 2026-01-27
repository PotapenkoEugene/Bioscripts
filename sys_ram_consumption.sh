#!/bin/bash

ps -eo user,rss --no-headers | \
awk '{mem[$1]+=$2} END {for (u in mem) printf "%-10s %8.2f GB\n", u, mem[u]/1024/1024}' | \
sort -nr -k2

