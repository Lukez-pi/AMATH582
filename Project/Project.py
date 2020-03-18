# -*- coding: utf-8 -*-
"""
Created on Tue Feb 25 15:45:39 2020

@author: lukez
"""

import bz2
import numpy as np
import pandas as pd
import requests
import plotly.graph_objs as go
import vcf
# =============================================================================
# import vcf
# import umap
# import seaborn as sns
# import pysam
# import matplotlib.pyplot as plt
# =============================================================================

from sklearn.preprocessing import OneHotEncoder, LabelEncoder
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE


def read_vcf(file_name):
    vcf_reader = vcf.Reader(filename=file_name)
    df = pd.DataFrame(index=vcf_reader.samples)
    for variant in vcf_reader:
        df[variant.ID] = [call.gt_type if call.gt_type is not None else 3 for call in variant.samples]
    
    return df

df = read_vcf("Kidd.55AISNP.1kG.vcf")
dfaim = pd.read_csv("Kidd_55_AISNPs.txt", sep='\t')