#!/usr/bin/python3
import sys

### Three pos arg
# 1) path to gbk file
# 2) desired new name in "x" or 'x'
###

path = sys.argv[1]
exp_path = ''.join(path.split('.')[:-1]) + '.renamed.gbk'

new_name = sys.argv[2].strip('\'').strip('\"')

with open(path) as f, open(exp_path, 'w') as w:
    for line in f:
        if line.strip().startswith('ORGANISM'):
            old_name = ' '.join(line.strip().split()[1:])
    f.seek(0)
    for line in f:
        w.write(line.replace(old_name, new_name))