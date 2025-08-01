#!/usr/bin/python3
import glob
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import sys

# Work in current directory and save output here
filename=sys.argv[1]
figwidth=int(sys.argv[2])
figheight=int(sys.argv[3])

def LDhat_x_y(df):
    x = df[3]
    y = df[5]
    return x, y

def colors_from_values(values, palette_name):
    # normalize the values to range [0, 1]
    normalized = (values - min(values)) / (max(values) - min(values))
    # convert to indices
    indices = np.round(normalized * (len(values) - 1)).astype(np.int32)
    # use the indices to get the colors
    palette = sns.color_palette(palette_name, len(values))
    return np.array(palette).take(indices, axis=0)

if __name__ == "__main__":
    table = pd.read_csv(filename,
                          sep='\t',
                          header=None) 
                
    table[5] = table[5].fillna(0)


    chrom_name = table.iloc[0, 0].split('.')[1]
    x, y = LDhat_x_y(table)
    fig, ax0 = plt.subplots(figsize=(figwidth, figheight), ncols=1, nrows=1)
    sns.barplot(x=x, y=y, palette=colors_from_values(y, "winter"))
    plt.xticks(rotation='vertical', size=7)
    plt.savefig(filename + '.png')
    # Paired_r, brg_r, cool_r, !!!!hsv!!!!, winter!!!!!!!!!!!!!!!!!!,

