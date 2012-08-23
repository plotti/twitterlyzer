import networkx as nx
import csv
import helper as hp
import sys
from lib import structural_holes2 as sx
import sys,getopt
import time

G = hp.create_example_network()
partitions = hp.create_example_partitions()
groups = hp.create_groups()
project = "test"
csv_bridging_writer = csv.writer(open('results/spss/individual bridging/%s_individual_bridging_2.csv' % project, 'wb'))
csv_bridging_writer.writerow(["Project", "Project-Name", "Node",
                  "G_degree", "G_in_degree", "G_out_degree",
                  "G_volume_in", "G_volume_out",
                  "G_total_in_groups", "G_total_out_groups"])
                  
i = 0
for partition in partitions:
    for node in partition:
        G.add_node(node, group =  groups[i])
    i += 1
    
i = 0
for partition in partitions:
    project_name = groups[i]
    all_other_groups = groups[:]
    group = groups[i]
    all_other_groups.remove(group)
    i += 1
    for node in partition:
            t0 = time.time()
            temp = partition[:] #create a copy
            temp.remove(node)
            
            remaining_nodes = [item for sublist in partitions for item in sublist]
            for temp_node in temp:      
               remaining_nodes.remove(temp_node)
            
            # Make temporary copies of the networks that contain all but the nodes from the group
            S_G = G.subgraph(remaining_nodes)
            
            dG_bin = nx.degree_centrality(S_G)
            dG_bin_in = nx.in_degree_centrality(S_G)
            dG_bin_out = nx.out_degree_centrality(S_G)
            dG_bin_betweeness = nx.betweenness_centrality(S_G, k=10)
            dG_bin_pagerank = nx.pagerank(S_G, weight="weight")
            
            dG_in_group_volume = hp.incoming_group_volume(S_G,node, all_other_groups)
            dG_total_group_in_volume = hp.filtered_group_volume(dG_in_group_volume,0)
            
            dG_out_group_volume = hp.outgoing_group_volume(S_G,node, all_other_groups)
            dG_total_group_out_volume = hp.filtered_group_volume(dG_out_group_volume,0)
            
            csv_bridging_writer.writerow([project, project_name, node,                               
                              dG_bin[node], dG_bin_in[node], dG_bin_out[node],
                              S_G.in_degree(node,weight="weight"), S_G.out_degree(node,weight="weight"),
                              dG_total_group_in_volume, dG_total_group_out_volume])