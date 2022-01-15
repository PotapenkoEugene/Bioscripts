import sys
from collections import defaultdict, Counter

path = '/home/gene/Orthonectida/Projects/WTK/data/Filtred_Fa/V_Corymbosum/tandem_all_MatchDataset_DomainName_V_corymbosum_RLK-Pelle_DLSV.SeqCharReplace.aln.fa'
outpath = '/home/gene/Orthonectida/Projects/WTK/data/Filtred_Fa/V_Corymbosum/tandem_all_MatchDataset_DomainName_V_corymbosum_RLK-Pelle_DLSV.SeqCharReplace_DifferenceFromMostOccured.tsv'

classification = {"R": 'Charge+',
                  "H": 'Charge+',
                  "K": 'Charge+',
                  "D": 'Charge-',
                  "E": 'Charge-',
                  "S": 'Uncharge',
                  "T": 'Uncharge',
                  "N": 'Uncharge',
                  "Q": 'Uncharge',
                  "C": 'SpecialCases',
                  "U": 'SpecialCases',
                  "G": 'SpecialCases',
                  "P": 'SpecialCases',
                  'A': 'Hydrophobic',
                  'I': 'Hydrophobic',
                  'L': 'Hydrophobic',
                  'M': 'Hydrophobic',
                  'F': 'Hydrophobic',
                  'W': 'Hydrophobic',
                  'Y': 'Hydrophobic',
                  'V': 'Hydrophobic',
                  '-': 'None'}

with open(path) as f:

    seqposdict = defaultdict(list)
    seqnamedict = defaultdict(str)
    seqnames = []
    seq = ''
    for line in f:
        if line.startswith('>'):

            if seq:
                for pos, letter in enumerate(seq):
                    seqposdict[pos + 1].append(letter)

                seqnamedict[seqname] = seq

            seqname = line.strip('>').split()[0]
            seqnames.append(seqname)
            seq = ''
            continue

        if line.strip():
            seq += line.strip()

    # add seq info of last sample
    for pos, letter in enumerate(seq):
        seqposdict[pos + 1].append(letter)

    reference = defaultdict(list)

    [reference[i].append(sorted(Counter(seqposdict[i]).items(), key=lambda x: x[1], reverse = True)[0][0]) for i in seqposdict]

    refseq = ''.join([i[1][0] for i in sorted(reference.items(), key=lambda x: x[0])])

    seqpenaltydict = defaultdict(int)
    for name, seq in seqnamedict.items():
        seqpenaltydict[name] = 0

        # simple implementation == or != reference metric
        for aa, refaa in zip(seq, refseq):
            if aa != refaa:

                # Penalize on 0.25 if sinonymous change and for 1 in other cases
                if classification[aa] == classification[refaa]:
                    seqpenaltydict[name] += 0.25
                else:
                    seqpenaltydict[name] += 1

    res_sorted = sorted(seqpenaltydict.items(), key = lambda x: x[1])

    with open(outpath, 'w') as w:
        [w.write(i[0] + '\t' + str(i[1]) + '\n') for i in res_sorted]

