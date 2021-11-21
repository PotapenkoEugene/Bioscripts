import sys

##################################
partnames_filepath = sys.argv[1]
fasta_filepath = sys.argv[2]
##################################

outfile = '.'.join(fasta_filepath.split('.')[:-1]) + '_' +\
          '.'.join(partnames_filepath.split('.')[:-1]) + '.fa'

with open(partnames_filepath) as partnames_file, \
     open(fasta_filepath) as fasta_file, \
     open(outfile, 'w') as w:

    block = True
    names = partnames_file.readlines()

    for line in fasta_file:
        if line.startswith('>'):

            check = [line for name in names if name.strip() and name.strip() in line]
            if check:
                w.write(line)
                block = False
            else:
                block = True

        else:
            if not block:
                w.write(line)

