#!/mnt/data/eugene/Tools/miniconda3/bin/python3
import sys

fi = sys.argv[1]
fileout = '.'.join(fi.split('.')[:-1]) + '_reheader.fasta'


# VIRIDAPLANTAE3.0:
#>CACTA-TPase__REXdb_ID14781#Class_II/Subclass_1/TIR/EnSpm_CACTA:CACTA-TPase

# Custom db format for RepEx2
#'>reapeatname#class/subclass'

# TREP db format
#>RSX_Bgt_Yho_consensus-1 Blumeria graminis_tritici; Retrotransposon, non-LTR (SINE), unknown; consensus sequence; KEY=2821;
#>DTX_Hvul_XI_AF521177-4 Hordeum vulgare; DNA-transposon, TIR, unknown; NULL; KEY=180;

with open(fi) as f, open(fileout, 'w') as w:
    for line in f:
        if line.startswith('>'):
            name = line.split()[0]
            
            clas = line.split(';')[1].split(',')[0].strip()
            if clas == 'Retrotransposon':
                clas = 'Class_I'
            elif clas == 'DNA-transposon':
                clas = 'Class_II'

            subclas = '_'.join(line.split(';')[1].split(',')[1].strip().split())

            w.write(name + '#' + '/'.join([clas, subclas]) + '\n')                                              
        else: 
            w.write(line)
