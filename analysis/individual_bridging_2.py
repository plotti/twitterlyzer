import networkx as nx
import csv
import helper as hp
import sys
from lib import structural_holes2 as sx
import sys,getopt
import time

def main(argv):
   #Standardvalues
   partitionfile = "data/partitions/final_partitions_p100_200_0.2.csv"
   project = "584"
   to_pajek = False
   try:
     opts, args = getopt.getopt(argv,"p:s:o")
   except getopt.GetoptError:
     print 'individual_bridging_2.py -p <project_name> -s <partitionfile> '
     sys.exit(2)
   for opt, arg in opts:
       if opt in ("-p"):
           project = arg
       elif opt in ("-s"):
           partitionfile = arg
       else:
         print 'individual_bridging_2.py -p <project_name> -s <partitionfile> '
   
   print "##################### INDIVIDUAL BRIDGING 2 (Working on whole network) ########################"
   print "Project %s " % project
   print "Partition %s" % partitionfile
   
   csv_bridging_writer = csv.writer(open('results/spss/individual bridging/%s_individual_bridging_2.csv' % project, 'wb'))
   csv_bridging_writer.writerow(["Project", "Community", "Person_ID",
                                 "Competing_lists",
                                 "FF_bin_degree", "FF_bin_in_degree", "FF_bin_out_degree",
                                 "FF_vol_in", "FF_vol_out"
                                 "FF_bin_betweeness", "FF_bin_closeness", "FF_bin_pagerank",                                 
                                 "AT_bin_degree", "AT_bin_in_degree", "AT_bin_out_degree",
                                 "AT_vol_in", "AT_vol_out"                                 
                                 "AT_bin_betweeness", "AT_bin_closeness", "AT_bin_pagerank",
                                 "RT_bin_in_degree", "RT_bin_out_degree",
                                 "RT_vol_in", "RT_vol_out"])
   
   #Read in the list-listings for individuals
   listings = {}
   indiv_reader = csv.reader(open(partitionfile))
   for row in indiv_reader:        
           listings[row[0]] = {"group":row[1],"place":int(row[2]), "competing_lists": int(row[3])}
       
   # Read in the partition
   tmp = hp.get_partition(partitionfile)
   partitions = tmp[0]
   groups = tmp[1]
   
   # Read in the networks   
   FF_all = nx.read_edgelist('data/networks/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
   AT_all = nx.read_edgelist('data/networks/%s_solr_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
   RT_all = nx.read_edgelist('data/networks/%s_solr_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
      
   i = 0
   for partition in partitions:
       for node in partition:
           FF_all.add_node(node, group =  groups[i]) # Add nodes 
           AT_all.add_node(node, group =  groups[i])
           RT_all.add_node(node, group =  groups[i])
       i += 1

   #Determine the Maximum subset of nodes present in all Networks   
   maximum_subset = []
   for node in FF_all.nodes():
      if AT_all.has_node(node) and RT_all.has_node(node):
         maximum_subset.append(node)
      else:
         print node

   i = 0
   for partition in partitions:      
      project_name = groups[i]
      all_other_groups = groups[:]
      group = groups[i]
      all_other_groups.remove(group)
      i += 1
      for node in partition:
         if node in maximum_subset:
            
            t0 = time.time()
            temp = partition[:] #create a copy
            temp.remove(node)
            
            #S_FF = FF_all.copy()
            #S_AT = AT_all.copy()
            #S_RT = RT_all.copy()
            #
            #S_FF.remove_nodes_from(temp)
            #S_AT.remove_nodes_from(temp)
            #S_RT.remove_nodes_from(temp)
            
            remaining_nodes = [item for sublist in partitions for item in sublist]
            for temp_node in temp:      
               remaining_nodes.remove(temp_node)
            
            # Make temporary copies of the networks that contain all but the nodes from the group
            S_FF = FF_all.subgraph(remaining_nodes)
            S_AT = AT_all.subgraph(remaining_nodes)
            S_RT = RT_all.subgraph(remaining_nodes)
            
            ## FF measures
            dFF_bin = nx.degree_centrality(S_FF)
            dFF_bin_in = nx.in_degree_centrality(S_FF)
            dFF_bin_out = nx.out_degree_centrality(S_FF)
            dFF_bin_betweeness = nx.betweenness_centrality(S_FF, k=100) #nx.load_centrality(S_FF,v=node, weight="weight")
            #dFF_bin_closeness = nx.closeness_centrality(S_FF,v=node)
            dFF_bin_pagerank = nx.pagerank(S_FF, weight="weight")
            
            dFF_in_group_volume = hp.incoming_group_volume(S_FF,all_other_groups)
            dFF_out_group_volume = hp.outgoing_group_volume(S_FF,all_other_groups)
            
            ## AT Measures
            dAT_bin = nx.degree_centrality(S_AT)
            dAT_bin_in = nx.in_degree_centrality(S_AT)
            dAT_bin_out = nx.out_degree_centrality(S_AT)
            dAT_bin_betweeness = nx.betweenness_centrality(S_AT, k=100) #nx.load_centrality(S_AT,v=node,weight="weight")
            #dAT_bin_closeness = nx.closeness_centrality(S_AT,v=node) 
            dAT_bin_pagerank = nx.pagerank(S_AT,weight="weight")
            
            ############### DEPENDENT VARIABLES ###########
            
            dRT_in = nx.in_degree_centrality(S_RT) # At least once a retweets that a person has received 
            dRT_out = nx.out_degree_centrality(S_RT) # At least one retweets that a person has made
            
            csv_bridging_writer.writerow([project, project_name, node, 
                                          listings[node]["competing_lists"],
                                          dFF_bin[node], dFF_bin_in[node], dFF_bin_out[node],
                                          S_FF.in_degree(node,weight="weight"), S_FF.out_degree(node,weight="weight"),
                                          #dFF_bin_betweeness[node],dFF_bin_closeness[node],dFF_bin_pagerank[node],
                                          #dFF_struc[node]['C-Size'],dFF_struc[node]['C-Density'],dFF_struc[node]['C-Hierarchy'],dFF_struc[node]['C-Index'],                                       
                                          dAT_bin[node], dAT_bin_in[node], dAT_bin_out[node],
                                          S_AT.in_degree(node,weight="weight"), S_AT.out_degree(node, weight="weight"),
                                          #dAT_bin_betweeness[node],dAT_bin_closeness[node],dAT_bin_pagerank[node],                                       
                                          #dAT_struc[node]['C-Size'],dAT_struc[node]['C-Density'],dAT_struc[node]['C-Hierarchy'],dAT_struc[node]['C-Index'],
                                          dRT_in[node],dRT_out[node],   
                                          S_RT.in_degree(node,weight="weight"), S_RT.out_degree(node,weight="weight")
                                         ])
            t_delta = (time.time() - t0)
            print "Count: %s Node: %s " % (i,node,t_delta)
        
if __name__ == "__main__":
    main(sys.argv[1:])         