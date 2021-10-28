import sys
from collections import defaultdict

# Paths
cluster_file_path = sys.argv[1]
repoutpath = '.'.join(cluster_file_path.split('.')[:-1]) + '_RepeatSummary.tsv'

# Create dicts
repcount = defaultdict(int)

# Run on cluster output file of RepeatExplorer2
with open(cluster_file_path) as f:
    for line in f:

        line_splt = line.split('\t')

        if line_splt[0].strip('\"') == 'Number_of_analyzed_reads':
            totalreadnum = int(line_splt[1])

        if line_splt[0].isdigit():

            readnum = int(line_splt[2])
            annot = line_splt[4].split('/')

# ['"All', 'repeat', 'mobile_element', 'Class_II', 'Subclass_1', 'TIR', 'EnSpm_CACTA"']

            # Start annotating on each level
            if len(annot) == 1:
                repcount['Unclassified'] += readnum

            # we don't see samples with 2
            elif len(annot) == 2:
                repcount['/'.join(annot[:1]).strip('\"')] += readnum

            elif len(annot) == 3:
                repcount['/'.join(annot[:2]).strip('\"')] += readnum

            elif len(annot) == 4:
                repcount['/'.join(annot[:3]).strip('\"')] += readnum

            elif len(annot) == 5:
                repcount['/'.join(annot[:4]).strip('\"')] += readnum

            elif len(annot) > 5:
                repcount['/'.join(annot[:5]).strip('\"')] += readnum


    # Get proportion
    repcountproportion = {k:str(round(v/totalreadnum, 6)) for k, v in repcount.items()}

    with open(repoutpath, 'w') as repW:

        # Write headers
#        repW.write('Annotation\tProportion\n')

        # Write tables
        [repW.write('\t'.join(i) + '\t' + str(totalreadnum) + '\n' ) for i in repcountproportion.items()]
