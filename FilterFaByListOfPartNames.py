import sys

##################################
partname = sys.argv[1]
fasta_filepath = sys.argv[2]
##################################

outfile = '.'.join(fasta_filepath.split('.')[:-1]) + '_' + partname + '.fa'

with open(fasta_filepath) as fasta_file, \
     open(outfile, 'w') as w:

    block = True
    print(f'INFO:\tSearch fasta records containing this stings:\n{partname}')

    for line in fasta_file:
        if line.startswith('>'):

            print(f'INFO:\tSearch in {line}')
            check = partname.strip() in line

            if check:
                print(f'INFO:\tSuccess')
                w.write(line)
                block = False
            else:
                block = True

        else:
            if not block:
                w.write(line)

