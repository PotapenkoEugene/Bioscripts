import sys
from collections import defaultdict

# Paths
cluster_file_path = sys.argv[1]
typeoutpath = '.'.join(cluster_file_path.split('.')[:-1]) + '_TypeSummary.tsv'
familyoutpath = '.'.join(cluster_file_path.split('.')[:-1]) + '_FamilySummary.tsv'
subfamilypath = '.'.join(cluster_file_path.split('.')[:-1]) + '_SubfamilySummary.tsv'

# Create dicts
typecount = defaultdict(int)
familycount = defaultdict(int)
subfamilycount = defaultdict(int)

# Run on cluster output file of RepeatExplorer2
with open(cluster_file_path) as f:
    for line in f:

        line_splt = line.split('\t')

        if line_splt[0].strip('\"') == 'Number_of_analyzed_reads':
            totalreadnum = int(line_splt[1])

        if line_splt[0].isdigit():

            readnum = int(line_splt[2])
            annot = line_splt[4].split('/')

            # skip if not annotated
            if len(annot) == 1:
                continue

            if len(annot) >= 3:

                # count types
                type = annot[2].strip('\"')
                typecount[type] += readnum

                if 'mobile_element' in annot:

                    # count families
                    family = annot[4].strip('\"')
                    familycount[family] += readnum

                    # count subfamilies
                    if len(annot) == 3:
                        subfamily = 'unknown'
                    else:
                        subfamily = annot[5].strip('\"')
                    subfamilycount[family + '_' + subfamily] += readnum


    # Get proportion
    typecountproportion = {k:str(round(v/totalreadnum, 6)) for k, v in typecount.items()}
    familycountproportion = {k: str(round(v / totalreadnum, 6)) for k, v in familycount.items()}
    subfamilycountproportion = {k: str(round(v / totalreadnum, 6)) for k, v in subfamilycount.items()}

    with open(typeoutpath, 'w') as typeW, \
            open(familyoutpath, 'w') as familyW, \
            open(subfamilypath, 'w') as subfamilyW:

        # Write headers
        typeW.write('Type\tProportion\n')
        familyW.write('Family\tProportion\n')
        subfamilyW.write('Subfamily\tProportion\n')

        # Write tables
        [typeW.write('\t'.join(i) + '\n') for i in typecountproportion.items()]
        [familyW.write('\t'.join(i) + '\n') for i in familycountproportion.items()]
        [subfamilyW.write('\t'.join(i) + '\n') for i in subfamilycountproportion.items()]