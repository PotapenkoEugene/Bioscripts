import sys
from collections import defaultdict

vcf = sys.argv[1]

vcfout = '.'.join(vcf.split('.')[:-1]) + 'GWAS_SUM.tsv'
traitsout = '.'.join(vcf.split('.')[:-1]) + '.GWAS.tsv'
traits_list = []

with open(vcf) as f, open(vcfout, 'w') as w:
    for line in f:

        # Header
        if line.startswith('##'):
            continue
        elif line.startswith('#C'):
            header = ['CHROM', 'POS', 'ID', 'REF', 'ALT',
                      'GWASCAT_REPORTED_GENE',
                      'GWASCAT_TRAIT(pval)', 'GWASCAT_PUBMED_ID']
            w.write('\t'.join(header) + '\n')

        # GWAS
        elif 'GWASCAT_TRAIT' in line: # or 'CLNSIGINCL' in line:
            line_splt = line.split('\t')
            base = '\t'.join(line_splt[0:5])
            ann = dict(map(lambda x: x.split('='), line_splt[7].split(';')))
            gene = ','.join(set(ann['GWASCAT_REPORTED_GENE'].split(',')))

            trait = ann['GWASCAT_TRAIT'].split(',')
            pval = ann['GWASCAT_P_VALUE'].split(',')
            [traits_list.append((el[0], el[1])) for el in zip(trait, pval)]
            trait_pval = ','.join([el[0] + '=' + el[1] for el in zip(trait, pval)])

            w.write( base + '\t' +
                     gene + '\t' +
                     trait_pval + '\t' +
                     ann['GWASCAT_PUBMED_ID'] + '\n')

with open(traitsout, 'w') as w:
    trait_combine = defaultdict(list)
    for trait, pval in traits_list:
        trait_combine[trait].append(pval)
    trait_combine_sort = sorted(trait_combine.items(), key=lambda x: len(x[1]), reverse=True)

    w.write('TRAIT\tMUTNUMBER\tPVAL\n')
    for trait, pval in trait_combine_sort:
        w.write(trait + '\t' + str(len(pval)) + '\t' + ','.join(pval) + '\n')

# ClinVar
vcfout = '.'.join(vcf.split('.')[:-1]) + 'ClinVar_SUM.tsv'


