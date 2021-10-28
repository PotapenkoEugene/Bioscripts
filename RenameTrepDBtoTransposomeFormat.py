
import sys

fi = sys.argv[1]
fileout = '.'.join(fi.split('.')[:-1]) + '_reheader.fasta'


# VIRIDAPLANTAE3.0:
#>CACTA-TPase__REXdb_ID14781#Class_II/Subclass_1/TIR/EnSpm_CACTA:CACTA-TPase

#>RSX_Bgt_Yho_consensus-1 Blumeria graminis_tritici; Retrotransposon, non-LTR (SINE), unknown; consensus sequence; KEY=2821;

with open(fi) as f, open(fileout, 'w') as w:
    for line in f:
        if line.startswith('>'):
            #name = line.split(';')[0].split()[0] + '_K' + line.split(';')[-2].split('=')[1]  # JUST NAME VERSION
            name = line.split()[0]
            phylogen= '/'.join([i.strip() for i in line.split(';')[1].split(',')])
            w.write(name + '#' + phylogen + '\n')                                              
        else: 
            w.write(line)
