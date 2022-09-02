#!/usr/bin/env python
# coding: utf-8

# # Download Allen V1 connectome
# ### With minimal dependencies
# 
# SONATA, reads and writes hdf5 files.
# 
# ## Step 1
# Download [this whole drop box directory](https://www.dropbox.com/sh/w5u31m3hq6u2x5m/AABGlA4w3k72vWmNndkyDbxZa/GLIF%20Network/network?dl=0&subfolder_nav_tracking=1). 
# If you can find the wget syntax for this, I would be greatful for that.
# Place the contents of that directory, in the same directory as this notebook.
# ## Step 2
# Pip install sonata and hdf5, as I am going to assume you don't already have those packages.
# ## Step 3. 
# * Arguably the data is already in it's ideal format for reading and writing graphs (big data/hdf5 no brainer).
# 
# * We are going to move the needle backwards, and transform the network into networkx, this will facilitate a transformation to Julia JLD files.

import glob
import pprint
import numpy as np
import pandas as pd
import h5dict
from sonata.circuit import File
import pandas as pd
import tqdm
import networkx as nx
import matplotlib.pyplot as plt


# ## Reading SONATA Network files


netv1 = File(data_files=['v1_nodes.h5', 
                       'v1_v1_edges.h5',
                       'lgn_v1_edges.h5',
                       'bkg_v1_edges.h5',
                       'lgn_nodes.h5',
                       'bkg_nodes.h5',
                      ], 
           data_type_files=['v1_node_types.csv',
                            'v1_v1_edge_types.csv',
                            'bkg_node_types.csv',
                           ])



v1_edges = netv1.edges
print('Edge populations in file: {}'.format(v1_edges.population_names))
for key in v1_edges.population_names:
    exec("g"+str(key)+str(" = nx.Graph()"))
    exec("this_name="+str("g")+str(key))
    temp = {}
    for edge in tqdm.tqdm(netv1.edges[key]):        
        if hasattr(edge,"plastic"):
            temp["plastic"] = True
        else:
            temp["plastic"] = False 
        if hasattr(edge,"delay"):
            temp["delay"] = edge.delay
        else:
            temp["delay"] = False

        if hasattr(edge,"nsyns"):
            temp["nsyns"] = edge.nsyns
        else:
            temp["nsyns"] = 1.0
        if hasattr(edge,"syn_weight"): 
            this_name.add_edge(str(edge.source_node_id),str(edge.target_node_id),weight=edge.syn_weight)        
        else:
            this_name.add_edge(str(edge.source_node_id),str(edge.target_node_id),weight=0.0)
        for k,v in temp.items():
            this_name.edges[str(edge.source_node_id),str(edge.target_node_id)][k] = v 
    v1_v1_dict = h5dict.File(str("AllenV1Murine")+str(key)+str(".hdf5"), "w") 
    filters = {"compression": "lzf"}
    v1_v1_dict["network",filters] = v1_v1_dict
    v1_v1_dict.close()
    test_dict = h5dict.File(str("AllenV1Murine")+str(key)+str(".hdf5"), "r")    
    test_dict.tree_view(print_types=True)
    G = test_dict["network"]
    assert hasattr(G,"edges")
    v1_v1_dict.close()



