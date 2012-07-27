import networkx as nx   
import csv
import numpy as np
import scipy.stats as sp
import helper as hp
import sys,getopt

def main(argv):
    #Standardvalues
    partitionfile = "data/partitions/final_partitions_p100_200_0.2.csv"
    project = "584"
    try:
      opts, args = getopt.getopt(argv,"p:s:")
    except getopt.GetoptError:
      print 'individual_bonding.py -p <project_name> -s <partitionfile>'
      sys.exit(2)
    for opt, arg in opts:
        if opt in ("-p"):
            project = arg
        elif opt in ("-s"):
            partitionfile = arg
        else:
            print 'individual_bonding.py -p <project_name> -s <partitionfile>'
    
    print "##################### INDIVIDUAL BONDING ########################"
    print "Project %s " % project
    print "Partition %s" % partitionfile
    
    csv_writer = csv.writer(open('results/spss/individual bonding/%s_individual_bonding.csv' % project, 'wb'))    
    csv_writer.writerow(["Project", "Community", "Person_ID",
                         "Place_on_list",
                         "FF_bin_deg","FF_bin_in_deg","FF_bin_out_deg",
                         "FF_vol_in", "FF_vol_out",
                         "FF_bin_close","FF_bin_page","FF_rec",
                         "AT_bin_deg","AT_bin_in_deg","AT_bin_out_deg",
                         "AT_bin_close","AT_bin_page","AT_rec","AT_avg",
                         "AT_vol_in", "AT_vol_out",                     
                         "RT_bin_deg_in", "RT_bin_deg_out",
                         "RT_vol_in","RT_vol_out",
                         "RT_global_vol_in", "RT_global_vol_out"])
    
    #Read in the list-listings for individuals
    listings = {}
    indiv_reader = csv.reader(open(partitionfile))
    i = 0
    for row in indiv_reader:
            i+= 1
            listings[row[0]] = {"group":row[1],"place":i, "competing_lists": int(row[3])}
            if i == 101: #Some of the original places have shifted because of the regrouping
                i = 0
            
    #Read in Networks    
    FF_all = nx.read_edgelist('data/networks/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
    AT_all = nx.read_edgelist('data/networks/%s_solr_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
    RT_all = nx.read_edgelist('data/networks/%s_solr_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
    
    # Read in the partitions
    tmp = hp.get_partition(partitionfile)
    partitions = tmp[0]
    groups = tmp[1]
    
    # Add missing nodes
    maximum_subset = []
    for node in FF_all.nodes():
        if AT_all.has_node(node) and RT_all.has_node(node):
            maximum_subset.append(node)
        else:
            print node
    print "Maximum Subset of nodes %s" % len(maximum_subset)
    
    #i = 0
    #for partition in partitions:
    #    for node in partition:
    #        FF_all.add_node(node, group =  groups[i])
    #        AT_all.add_node(node, group =  groups[i])
    #        RT_all.add_node(node, group =  groups[i])
    #    i += 1
        
    i = 0
    
    for partition in partitions:
        
        project_name = groups[i]
        print "############ Calculating Project %s ############### " % project_name
        # Generate a subgraph according to the partition
        FF = FF_all.subgraph(partition)
        AT = AT_all.subgraph(partition)
        RT = RT_all.subgraph(partition)
        
        #Additional Info for each project    
        FF.name = "FF_%s " % project_name
        AT.name = "AT_%s " % project_name
        RT.name = "RT_%s " % project_name
    
        ############### Compute Individual measures ################
    
        #Compute FF Centralities
        # Works fine on binary data
        dFF_bin = nx.degree_centrality(FF)
        dFF_bin_in = nx.in_degree_centrality(FF)  #People that follow me in the network
        dFF_bin_out = nx.out_degree_centrality(FF) #People that I follow in the network
        dFF_bin_closeness = nx.closeness_centrality(FF) 
        dFF_bin_pagerank = nx.pagerank(FF)        
        
        #Compute AT Centralities
        # Centralities are problematic on weighted data, since we are losing all the information    
        dAT_bin = nx.degree_centrality(AT) # binary
        dAT_bin_in = nx.in_degree_centrality(AT) #binary
        dAT_bin_out = nx.out_degree_centrality(AT) #binary
        dAT_bin_closeness = nx.closeness_centrality(AT) #binary
        #dAT_eigenvector = nx.eigenvector_centrality(AT.to_undirected()) #fails to converge too often what to do?
        dAT_bin_pagerank = nx.pagerank(AT)
        
        # Tie strengths
        dAT_avg_tie = hp.individual_average_tie_strength(AT)
        dAT_rec = hp.individual_reciprocity(AT)    
        dFF_rec = hp.individual_reciprocity(FF)
            
        #Dependent Variable see csv below        
        # Deprecated since in networkx centrality works only on binary edges
        dRT_in = nx.in_degree_centrality(RT) # At least once a retweets that a person has received 
        dRT_out = nx.out_degree_centrality(RT) # At least one retweets that a person has made
        
        ############### Output ################
        for node in dFF_bin.keys():
            if node in maximum_subset:
                csv_writer.writerow([project, project_name, node,
                                     listings[node]["place"],
                                     dFF_bin[node], dFF_bin_in[node], dFF_bin_out[node],
                                     FF.in_degree(node,weight="weight"), FF.out_degree(node,weight="weight"),
                                     dFF_bin_closeness[node],dFF_bin_pagerank[node],
                                     dFF_rec[node],
                                     dAT_bin[node], dAT_bin_in[node], dAT_bin_out[node],
                                     dAT_bin_closeness[node],dAT_bin_pagerank[node],
                                     dAT_rec[node],dAT_avg_tie[node],
                                     dRT_in[node],dRT_out[node],
                                     AT.in_degree(node,weight="weight"), AT.out_degree(node, weight="weight"),
                                     RT.in_degree(node,weight="weight"), RT.out_degree(node, weight="weight"),
                                     RT_all.in_degree(node,weight="weight"), RT_all.out_degree(node, weight="weight")
                                     ])
    
        i += 1
        
if __name__ == "__main__":
    main(sys.argv[1:])