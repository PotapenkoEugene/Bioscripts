import sys
from collections import defaultdict

###########################
ANNOT = sys.argv[1]       #
DB = sys.argv[2]          #
READNUMBER = int(sys.argv[3])  #
###########################


# Make dict with association with seq name and TE family
decryption = defaultdict(list)
with open(DB) as f:
    for line in f:
        if line.startswith('>'):
            seqname = line.lstrip('>').split()[0]
            # species = [' '.join(line.split(';')[0].split()[1:])]
            family = [i.strip() for i in line.split(';')[1].split(',') ]
            decryption[seqname] = family

# Now we need to count amount of TEs on different levels
counter1 = {k[0]:0 for k in decryption.values()}
counter2 = {' / '.join(k[0:2]):0 for k in decryption.values()}
counter3 = {' / '.join(k[0:3]):0 for k in decryption.values()}


with open(ANNOT) as f:
    for line in f:
        seqname, amount = line.split()[0], int(line.split()[1])

        family = decryption[seqname]
        counter1[family[0]] += amount
        counter2[' / '.join(family[0:2])] += amount
        counter3[' / '.join(family[0:3])] += amount


# Save results
outname = '.'.join(ANNOT.split('.')[:-1])
with open(ANNOT + 'FAMILYSUM.txt', 'w') as w:
    [w.write(x[0] + '\t' + str(x[1] / READNUMBER) + '\n') for x in counter1.items()]
    w.write('_'*50 + '\n'*2)
    [w.write(x[0] +'\t'+ str(x[1] / READNUMBER) + '\n') for x in counter2.items()]
    w.write('_' * 50 + '\n' * 2)
    [w.write(x[0] + '\t' + str(x[1] / READNUMBER) + '\n') for x in counter3.items()]