import sys
from collections import defaultdict

# Paths
supercluster_file_path = sys.argv[1]
cluster_file_path = sys.argv[2]
classification_file_path = sys.argv[3]
samplename = sys.argv[4]

repoutpath = '.'.join(supercluster_file_path.split('.')[:-1]) + '_RepeatSummary.tsv'

# Create dicts
repcount = defaultdict(int)

# Run on Super cluster output file of RepeatExplorer2
with open(supercluster_file_path) as f:
    for line in f:
        if line.startswith('-'):
            continue

        line_splt = line.split('\t')
        if line_splt[0].isnumeric():
            # Count each Super cluster:
            repcount[line_splt[2].strip('\"')] += int(line_splt[1])

with open(classification_file_path) as f:
    classif = [i.rstrip('\n').replace('/', '_').split('\t') for i in f.readlines()]

# open CLUSTER TABLE for total read number:
with open(cluster_file_path) as f:
    commentlines = []
    for line in f:
        if line.startswith('\"Number_'):
            commentlines.append('#' + line)
        if line.strip('\"').startswith('Number_of_analyzed_reads'):
            totalreadnum = int(line.strip('\"').split('\t')[1])

with open(repoutpath, 'w') as w:
    # Save comments
    [w.write(line) for line in commentlines]
    # Save header
    w.write('\t'.join(['#Class', 'Order', 'Superfamily', 'Family',
                       'Subfamily1', 'Subamily2', 'Subfamily3',
                       'Proportion', 'TotalReadNum', 'SampleName']) + '\n')
    # Save annotations:
    for k, v in repcount.items():
        annotated = False
        last_annot_lvl = (0, None)

        for cl in classif:

            # find on what level of annotation
            annot_lvl = [i for i, el in enumerate(cl) if el == k]
            # change level of annotation if annotated deeper
            if annot_lvl:
                if annot_lvl[0] > last_annot_lvl[0]:
                    last_annot_lvl = (annot_lvl[0], cl)
                annotated = True

        if annotated:

            lvl = last_annot_lvl[0]
            cl = last_annot_lvl[1]

            res = cl[:lvl+1] + ['NA'] * (7-lvl-1)
            w.write('\t'.join(res + [str(v / totalreadnum)] + [str(totalreadnum)] + [samplename]) + '\n')

        # If not annotated on last level - manually configure:
        if not annotated:
            w.write('\t'.join([k] * 7 + [str(v / totalreadnum)] + [str(totalreadnum)] + [samplename]) + '\n')