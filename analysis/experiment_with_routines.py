import networkx as nx
import csv
import helper as hp

csv_writer_gbon = csv.writer(open('results/test_group_bonding.csv', 'wb'))
csv_writer_ibon = csv.writer(open('results/test_individual_bonding.csv', 'wb'))
THRESHOLD = 0.01
csv_writer_gbon.writerow(["Project",
                    "FF_Nodes",
                    "FF_density", 
                    "FF_avg_path_length", 
                    "FF_clustering", 
                    "FF_reciprocity", 
                    "FF_transitivity",
                    "FF_avg_tie_strength"])

csv_writer_ibon.writerow(["Node",
                    "FF_bin_degree",
                    "FF_bin_in_degree", 
                    "FF_bin_out_degree", 
                    "FF_closeness",
                    "FF_pagerank",
                    "FF_reciprocity",                     
                    "FF_avg_tie_strength",
                    "FF_involume",
                    "FF_outvolume"])

G_all = hp.create_example_network()
#hp.draw_graph(G_all)

#Output for pajek
mapping = {}
i = 0
for node in G_all.nodes():
    mapping[node] = "\"%s\"" % node            
G_all_renamed = nx.relabel_nodes(G_all,mapping)
nx.write_pajek(G_all_renamed,"results/networks/test.net")

partitions = hp.create_example_partitions()
names = ["a","b","c","d"]

i = 0
for partition in partitions:
    for node in partition:
        G_all.add_node(node, group =  names[i])        
    i += 1

i = 0
for partition in partitions:
        
    # Subgraph
    FF = G_all.subgraph(partition)
    
    #Name it and Draw it
    FF.name = "FF_%s " % names[i]
    hp.draw_graph(FF)
    
    for node in partition:
        FF.add_node(node)
        
    ################# Group  Bonding measures ################
    
    FF_bin = hp.to_binary(FF)
    # Density
    # Density is computed on binarized matrix
    FF_bin_density = nx.density(FF)    
    # Transitivity
    FF_bin_transitivity = nx.transitivity(FF)    
    # Reciprocity
    FF_reciprocity = hp.reciprocity(FF)    
    # Weakly connected components
    # FF_partition = nx.weakly_connected_components(FF)[0]
    # FF_comp = FF.subgraph(FF_partition)    
    # Clustering
    FF_clustering = nx.average_clustering(FF.to_undirected(reciprocal=True))
    # To undirected only keeps edges that are reciprocal
    # Average path length
    FF_avg_path_length = nx.average_shortest_path_length(FF)
    # Avg Tie strength
    FF_avg_volume = hp.average_tie_strength(FF)
    
    # TODO:
    # What about network centralization ?
    
    # Test the output of NetworkX against UCINET
    if names[i] == "a":
        print "######################## GROUP MEASURES TEST #####################"
        
        # Test for BINARY
        if nx.density(FF) == nx.density(FF_bin): print "NOTICE: Group Density is BINARY"
        if nx.transitivity(FF) == nx.transitivity(FF_bin): print "NOTICE: Group Transitivity is BINARY"
        if hp.reciprocity(FF) == hp.reciprocity(FF_bin): print "NOTICE: Group Reciprocity is BINARY"
        if nx.average_clustering(FF.to_undirected()) == nx.average_clustering(FF_bin.to_undirected()): print "NOTICE: Average Clustering is BINARY and UNDIRECTED"
        if nx.average_shortest_path_length(FF) == nx.average_shortest_path_length(FF_bin): print "NOTICE: Group Average path length is is BINARY"
        if hp.average_tie_strength(FF) == hp.average_tie_strength(FF_bin): print "NOTICE: Group Average tie strength path is is BINARY"

            
    ################# Individual Bonding measures ################
    
    #dFF_degree = FF.degree("a1")
    dFF = nx.degree_centrality(FF) # Binarized undirected
    dFF_in = nx.in_degree_centrality(FF)  #People that follow me in the network binarized 
    dFF_out = nx.out_degree_centrality(FF) #People that I follow in the network binarized 
    dFF_closeness = nx.closeness_centrality(FF) # Non-directed and binarized
    #dFF_pagerank = nx.pagerank(FF)
    dFF_eigenvector = nx.eigenvector_centrality(FF.to_undirected()) # Undirected and binarized
    dFF_rec = hp.individual_reciprocity(FF) # Individual Reciprocity
    dFF_avg_tie = hp.individual_average_tie_strength(FF) # Individual average tie strength        
    dFF_in_volume = hp.individual_in_volume(FF) #compute the volume of all incoming ties
    dFF_out_volume = hp.individual_out_volume(FF) #compute the volume of all outgoing ties
    
    # Test the output of NetworkX against UCINET
    if names[i]  == "a":
        print "######################## INDIVIDUAL MEASURES TEST of BINARY #####################"
        a2 = "a2"
        if nx.degree_centrality(FF) == nx.degree_centrality(FF_bin): print "NOTICE: Degree centrality is BINARY"
        if nx.in_degree_centrality(FF) == nx.in_degree_centrality(FF_bin): print "NOTICE: in_degree_centrality is BINARY"
        if nx.out_degree_centrality(FF) == nx.out_degree_centrality(FF_bin): print "NOTICE: out_degree_centrality is BINARY"
        if nx.closeness_centrality(FF) == nx.closeness_centrality(FF_bin): print "NOTICE: closeness_centrality is BINARY"
        # Eigenvector Centrality makes problems upon converging
        #if nx.eigenvector_centrality(FF) == nx.eigenvector_centrality(FF_bin): print "NOTICE: eigenvector_centrality is BINARY"
        if hp.individual_reciprocity(FF) == hp.individual_reciprocity(FF_bin): print "NOTICE: individual_reciprocity is BINARY"
        if hp.individual_average_tie_strength(FF) == hp.individual_average_tie_strength(FF_bin): print "NOTICE: individual_average_tie_strength is BINARY"
        # The in_out volumes are computed in regard to a given group D
        if hp.individual_in_volume(FF,"d") == hp.individual_in_volume(FF_bin,"d"): print "NOTICE: individual_in_volume is BINARY"
        if hp.individual_out_volume(FF,"d") == hp.individual_out_volume(FF_bin,"d"): print "NOTICE: individual_out_volume is BINARY"
        
        
    ######## Output #############
    
    csv_writer_gbon.writerow([names[i],
                        len(FF.nodes()),
                        FF_bin_density, 
                        FF_avg_path_length, 
                        FF_clustering, 
                        FF_reciprocity,
                        FF_bin_transitivity,
                        FF_avg_volume])
    
    for node in dFF.keys():
        csv_writer_ibon.writerow([node,
                             dFF[node], dFF_in[node], dFF_out[node],
                             dFF_closeness[node],#dFF_eigenvector[node],
                             dFF_rec[node], dFF_avg_tie[node],
                             dFF_in_volume[node], dFF_out_volume[node]
                             ])
    i += 1