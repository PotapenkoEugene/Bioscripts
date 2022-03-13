from Bio import SeqIO
import sys

##########################################
FA = sys.argv[1] # FASTA of proteins
DOMAINPOS = sys.argv[2] # output of ps_scan or another (name start stop ....)
OUT = sys.argv[3] # OUTPUT NAME
###########################################
with open(DOMAINPOS) as f_pos, open(OUT, 'w') as w:
    for seq in SeqIO.parse(FA, 'fasta'):
        count = 0
        for line in f_pos:
            name = line.split('\t')[0]
            start, end = map(int, line.split('\t')[1:3])
            if seq.id == name:
                count += 1
                w.write('>'+ seq.id+'_K'+str(count) + '\n' + str(seq.seq[start:end+1]) + '\n')
        f_pos.seek(0)




