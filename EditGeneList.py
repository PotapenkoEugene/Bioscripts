#!/usr/bin/python3
import sys
import argparse

# By default take stdin table and edit list by different options. By default write
# result in stdout
if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    # REQUIRED - possional arguments:
    parser.add_argument('option', type=str,
                        help="""Choose option:
                                 1) up - get all gene names UP
                                 2) down - get all gene names DOWN
                                 3) standard - get all in standard format (first UP)
                                 """)
    args = parser.parse_args().__dict__
    option = args['option']
    if option not in ['up', 'down', 'standard']:
        print('Not correct option')
        exit(1)

    # Prepare standard genelist
    with open('/home/gene/Tools/MY_SCRIPTS/data/Mouse_basic_genes.txt') as f:
        genelist = [i.rstrip() for i in f]

    for line in sys.stdin:
        if option == 'up':
            sys.stdout.write(line.upper())
        elif option == 'down':
            sys.stdout.write((line.lower()))
        elif option == 'standard':
            gene = [i for i in genelist if i.upper() == line.rstrip().upper()]
            if gene:
                sys.stdout.write(gene[0] + '\n')
            else:
                pass
                # ЛИСТ НЕПОЛНЫЙ НАДО СКАЧАТЬ НОРМАЛЬНЫЙ МНЕ ЛЕНЬ