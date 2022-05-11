import sys
import re

gffpath = sys.argv[1]
outgffpath = sys.argv[2]

with open(gffpath) as f, open(outgffpath, 'w') as w:

    for line in f:

        # Save in variable chrom name
        if 'chromosome=' in line:
            pattern = 'chromosome=([A-Za-z0-9]+);'
            chrom = re.search(pattern, line).group(1)
            w.write(line)

        # Change chrom name and save lines
        else:
            # Split line in list
            spltline = line.split('\t')
            spltline[0] = chrom
            w.write('\t'.join(spltline))



