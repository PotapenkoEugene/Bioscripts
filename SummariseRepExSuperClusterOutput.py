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
# Load classification file
with open(classification_file_path) as f:
    classif = [i.rstrip('\n').replace('/', '_').split() for i in f.readlines()]

# Count read number on each SuperCluster (output file of RepeatExplorer2)
with open(supercluster_file_path) as f:
    for line in f:
        if line.startswith('-'):
            continue

        line_splt = line.split('\t')
        if line_splt[0].isnumeric():
            # Count each Super cluster:
            repcount[line_splt[2].strip('\"')] += int(line_splt[1])

# open CLUSTER TABLE for total read number:
with open(cluster_file_path) as f:
    commentlines = []
    for line in f:
        if line.startswith('\"Number_'):
            commentlines.append('#' + line)
        if line.strip('\"').startswith('Number_of_analyzed_reads'):
            totalreadnum = int(line.strip('\"').split('\t')[1])

# Calculate and write out file
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

        # case one it's the lates annotation level
        for cl in classif:

            if k == cl[-1]:
                annotated = True
                cl_na = cl + ['NA'] * ( 7 - len(cl) )
                record = (cl_na, v)
                break

        if not annotated:
            # case two it's the first annotation level
            for cl in classif:

                if k == cl[0]:
                    annotated = True
                    cl_na = [cl[0]] + ['NA']*6
                    record = (cl_na, v)
                    break

        if not annotated:

            # case three it's the middle annotation level
            for cl in classif:

                if k in cl and k != cl[0] and k != cl[-1]:
                    annotated = True
                    cl_na = cl[:cl.index(k) + 1] + ['NA'] * (7 - len(cl[:cl.index(k) + 1]))
                    record = (cl_na, v)
                    break

        if not annotated:

            # case four - name not in TE classification file (not TE)
            record = ([k]*7, v)

        w.write('\t'.join(record[0]) + '\t' + '\t'.join([str(v / totalreadnum),
                                                         str(totalreadnum),
                                                         samplename]) + '\n')
