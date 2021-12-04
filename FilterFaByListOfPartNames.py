import sys

##################################
fasta_filepath = sys.argv[1]
partname = sys.argv[2].strip().split(',')  # names separated by comma
##################################

outfile = '.'.join(fasta_filepath.split('.')[:-1]) + '_' + '-'.join(partname) + '.fa'

with open(fasta_filepath) as fasta_file, \
     open(outfile, 'w') as w:

    block = True
    print(f'INFO:\tSearch fasta records containing this stings:\n{partname}')

    for line in fasta_file:
        if line.startswith('>'):

            print(f'INFO:\tSearch in {line}')
            check = sum([1 for i in partname if i in line]) == len(partname)

            if check:
                print(f'INFO:\tSuccess')
                w.write(line)
                block = False
            else:
                block = True

        else:
            if not block:
                w.write(line)

