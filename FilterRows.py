#!/usr/bin/python3
import sys
import argparse

#####################################
# By default take stdin table and filter rows by different options.
# By default write result in stdout
if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    # REQUIRED - possional arguments:
    options_list = ['PLUS', 'MINUS', 'BIGGER','SMALLER']
    options_with_X = ['BIGGER','SMALLER']
    parser.add_argument('option', type=str,
                        help="""Choose option:
                                 1) PLUS - get rows with plus value in certain col
                                 2) MINUS - get rows with minus value in certain col
                                 3) BIGGER - get rows with value bigger than X in certain col
                                 4) SMALLER - get rows with value smaller than X in certain col
                                 """)

    parser.add_argument('column', type=str,
                        help="Which column use for filter, number from 1 to ...")

    # OPTIONAL
    parser.add_argument('--number', type=int,
                        help="""Specified the X for some options""")
    parser.add_argument('--format', type=str,
                        help="Choose tsv/csv/xls extension, tsv by default")
    parser.add_argument('--header', type=str,
                        help="+/-, default is +")

    args = parser.parse_args().__dict__

    # Check OPTION argument
    if args['option'] not in options_list:
        print('Not correct option')
        exit(1)

    # Check X
    if args['option'] in options_with_X:
        if not args['number']:
            print('Please specified NUMBER')
            exit(1)

    # Check FORMAT arg
    if args['format']:
        sep = args['format']
    else:
        sep = '\t'

    # Check HEADER arg
    if args['header'] and args['header'] == '-':
        header = False
    else:
        header = True

    # Run
    for line in sys.stdin:
        if header:
            sys.stdout.write(line)
            header = False
            continue
        # Get value from specified column
        # -1 need to convert column number in python index format
        value = float(line.strip().split(sep)[int(args['column']) - 1])

        if args['option'] == 'PLUS':
            if value >= 0:
                sys.stdout.write(line)
        elif args['option'] == 'MINUS':
            if value <= 0:
                sys.stdout.write(line)

        elif args['option'] == 'BIGGER':
            if value > args['number']:
                sys.stdout.write(line)
        elif args['option'] == 'SMALLER':
            if value < args['number']:
                sys.stdout.write(line)





