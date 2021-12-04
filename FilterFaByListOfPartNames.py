import sys
from collections import defaultdict
##################################
fasta_filepath = sys.argv[1]
partname = sys.argv[2].strip()  # names separated by comma
# for el1 OR el2 use brackets: el1, [el2,el3]
##################################

def parse_partnames(namelist):
    partnames = defaultdict(list)
    elnum = 1
    OR = False
    curel = []
    for el in namelist:

        if el not in [',', '[', ']']:
            curel.append(el)

        elif el == ',' and not OR:
            partnames[elnum].append(''.join(curel))
            elnum += 1
            curel = []

        elif el == ',' and OR:
            partnames[elnum].append(''.join(curel))
            curel = []

        elif el == '[':
            OR = True

        elif el == ']':
            OR = False
    partnames[elnum].append(''.join(curel))

    return partnames

namedict = parse_partnames(partname)

outpartnames = '_'.join(sum([i for i in namedict.values()], []))
outfile = '.'.join(fasta_filepath.split('.')[:-1]) + '_' + outpartnames + '.fa'

with open(fasta_filepath) as fasta_file, \
     open(outfile, 'w') as w:

    block = True
    print(f'INFO:\tSearch fasta records containing this stings:\n{partname}')

    for line in fasta_file:
        if line.startswith('>'):

            print(f'INFO:\tSearch in {line}')
            print(namedict)
            matches = len([True for i in namedict if [True for j in namedict[i] if j in line]])
            print(matches)
            check = sum([True for i in namedict if [True for j in namedict[i] if j in line]]) == len(namedict)

            if check:
                print(f'INFO:\tSuccess')
                w.write(line)
                block = False
            else:
                block = True

        else:
            if not block:
                w.write(line)

