#!/usr/bin/python3
import sys
import argparse

#####################################
# By default take stdin table and filter rows by different options. By default write
# result in stdout
if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    # REQUIRED - possional arguments:
    parser.add_argument('option', type=str,
                        help="""Choose option:
                                 1) PLUS - get rows with plus value in certain col
                                 2) MINUS - get rows with minus value in certain col
                                 """)
    parser.add_argument('column', type=str,
                        help="Which column use for filter, number from 1 to ...")

    # OPTIONAL
    parser.add_argument('--format', type=str,
                        help="Choose tsv/csv/xls extension, tsv by default")
    parser.add_argument('--header', type=str,
                        help="+/-, default is +")

    args = parser.parse_args().__dict__

    if args['option'] not in ['PLUS', 'MINUS']:
        print('Not correct option')
        exit(1)

    if args['format']:
        sep = args['format']
    else:
        sep = '\t'

    if args['header'] and args['header'] == '-':
        header = False
    else:
        header = True

    for line in sys.stdin:
        if header:
            sys.stdout.write(line)
            header = False
            continue
        col = float(line.rstrip().split(sep)[int(args['column']) - 1]) # переводим в индекс
        if args['option'] == 'PLUS':
            if col >= 0:
                sys.stdout.write(line)
        elif args['option'] == 'MINUS':
            if col <= 0:
                sys.stdout.write(line)




