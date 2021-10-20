import sys
from collections import Counter
##########
# Pos args
# 1) path to VCF file(not gzipped)
filepath = sys.argv[1]
# 2) output vcf file
outpath = sys.argv[2]
##########


with open(filepath) as f, open(outpath, 'w') as w:
    for line in f:

        # skip comment lines
        if line.startswith('#'):
            continue
        # skip not biallelic SNPs
        elif len(line.split('\t')[4].split(',')) > 1:
            continue

        else:
            spltline = line.rstrip().split('\t')
            spltline[8] = 'GT'

            # heterozyg = False
            for i, sample in enumerate(spltline[9:]):
                gt = sample.split(':')

                if '/' in gt[0]:
                    haplotype = gt[0].split('/')
                elif '|' in gt[0]:
                    haplotype = gt[0].split('|')
                else:
                    print('Unexpected separator of alleles', gt[0])

                # Записываю всех гетерозигот, в режими unphased у LDhat не должно быть проблем
                if haplotype[0] != haplotype[1]:
                #    print('Warning! There are heterozygotes in the data!')
                    # heterozyg = True
                    # break
                    spltline[i + 9] = '/'.join(haplotype)
                else:
                    spltline[i + 9] = '/'.join(haplotype)  # оставляем только один

            # Пропускаем строки с менее чем 4 данными:
            treshold = len(spltline[9:]) - 4
            counts = Counter(spltline[9:])
            if counts['./.'] <= treshold:
                w.write('\t'.join(spltline) + '\n')
