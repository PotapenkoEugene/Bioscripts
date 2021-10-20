#!/usr/bin/python3

# rename each locus tag with BASE(from current locus_tag name - all before '_')
# and COUNT (порядок)
### One pos arg
# 1) Gbk or gbff file
# 2) desired BASENAME of locus
###
import sys
from collections import defaultdict
path = sys.argv[1]
exp_path = '.'.join(path.split('.')[:-1]) + '.RenamedLocus.gbk'
new_locus_base = sys.argv[2]

with open(path) as f, open(exp_path, 'w') as w:
    locuses = defaultdict(str)
    for line in f:

        if line.strip().startswith('/locus_tag='):
            locus_base = line.strip().split('=')[1].strip('"').split('_')[0]
            w.write(line.replace(locus_base, new_locus_base))

        elif line.strip().startswith('/protein_id'):
            locus_base = line.strip().split(':')[-1].rstrip('\"').split('_')[0]
            w.write(line.replace(locus_base, new_locus_base))

        else:
            w.write(line)

