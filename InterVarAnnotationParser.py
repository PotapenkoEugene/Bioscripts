import sys
intervar = sys.argv[1]

mask = [1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1]

with open(intervar) as f, \
        open(intervar + '_NULL.tsv', 'w') as null, \
            open(intervar + '_UnSignif.tsv', 'w') as unsignif, \
                open(intervar + '_LikelyBenign.tsv', 'w') as likebeni:


    for line in f:
        if line.startswith('#'):
            splt_line = line.strip().split('\t')
            line_f = [r for r,b in zip(splt_line, mask) if b]
            line_f = line_f[5:9] + line_f[12:15] + line_f[9:12]
            null.write('\t'.join(line_f) + '\n')
            unsignif.write('\t'.join(line_f) + '\n')
            likebeni.write('\t'.join(line_f) + '\n')

        elif 'Pathogenic' in line or 'PVS1=1' in line:
            splt_line = line.strip().split('\t')
            line_f = [r for r, b in zip(splt_line, mask) if b]

            line_f[-2] = '  ]|[  '.join(line_f[-2].split('~'))
            line_f[8] = line_f[8].split('PVS1=')[0].split(':')[1]

            line_f = line_f[5:9] + line_f[12:15] + line_f[9:12]
            null.write('\t'.join(line_f) + '\n')

        elif 'Likely benign' in line:
            splt_line = line.strip().split('\t')
            line_f = [r for r, b in zip(splt_line, mask) if b]

            line_f[-2] = '  ]|[  '.join(line_f[-2].split('~'))
            line_f[8] = line_f[8].split('PVS1=')[0].split(':')[1]

            line_f = line_f[5:9] + line_f[12:15] + line_f[9:12]
            likebeni.write('\t'.join(line_f) + '\n')

        elif 'Uncertain significance' in line:
            splt_line = line.strip().split('\t')
            line_f = [r for r, b in zip(splt_line, mask) if b]

            line_f[-2] = '  ]|[  '.join(line_f[-2].split('~'))
            line_f[8] = line_f[8].split('PVS1=')[0].split(':')[1]

            line_f = line_f[5:9] + line_f[12:15] + line_f[9:12]
            unsignif.write('\t'.join(line_f) + '\n')

