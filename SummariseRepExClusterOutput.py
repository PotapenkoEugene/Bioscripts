import sys
from collections import defaultdict

cluster_file_path = sys.argv[1]
typeoutpath = '.'.join(cluster_file_path.split('.')[:-1]) + '_TypeSummary.tsv'
familyoutpath = '.'.join(cluster_file_path.split('.')[:-1]) + '_FamilySummary.tsv'

typecount = defaultdict(int)
familycount = defaultdict(int)

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
                    family = annot[4].strip('\"')
                    familycount[family] += readnum


    # Get proportion
    typecountproportion = {k:str(round(v/totalreadnum, 6)) for k, v in typecount.items()}
    familycountproportion = {k: str(round(v / totalreadnum, 6)) for k, v in familycount.items()}

    with open(typeoutpath, 'w') as typeW, open(familyoutpath, 'w') as familyW:
        typeW.write('Type\tProportion\n')
        familyW.write('Family\tProportion\n')
        [typeW.write('\t'.join(i) + '\n') for i in typecountproportion.items()]
        [familyW.write('\t'.join(i) + '\n') for i in familycountproportion.items()]
