#!/usr/bin/python3

import pandas as pd
import numpy as np
import argparse

################
# convert FPKM to TPM
################

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    # REQUIRED - positional arguments:
    parser.add_argument('file', type=str,
                        help="""Specified output table of featureCounts tool""")

    args = parser.parse_args().__dict__

    filename = args['file']
    if not filename:
        print('You need to specified FPKM table')
        exit(1)

    # On the out we need TPM
    OUTFILE = '.'.join(filename.split('.')[:-1]) + 'TPM.tsv'
