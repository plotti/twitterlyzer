import networkx as nx
import csv
import helper as hp
import sys
from lib import structural_holes2 as sx
from lib import structural_holes as sx1
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
   
   csv_bridging_writer = csv.writer(open('results/spss/individual bridging/%s_individual_bridging_3.csv' % project, 'wb'))
   csv_bridging_writer.writerow(["Project", "Community", "Person_ID",
                                 "Competing_lists",
                                 "FF_bin_degree", "FF_bin_in_degree", "FF_bin_out_degree",
                                 "FF_vol_in", "FF_vol_out",
                                 "FF_groups_in", "FF_groups_out",
                                 "FF_rec",
                                 "FF_bin_betweeness", #"FF_bin_closeness", "FF_bin_pagerank",
                                  #"FF_c_size", "FF_c_density", "FF_c_hierarchy", "FF_c_index",
                                 "AT_bin_degree", "AT_bin_in_degree", "AT_bin_out_degree",
                                 "AT_vol_in", "AT_vol_out",
                                 "AT_groups_in", "AT_groups_out",
                                 "AT_rec",
                                 "AT_bin_betweeness",#, "AT_bin_closeness", "AT_bin_pagerank",
                                 # FF_c_size, FF_c_density, FF_c_hierarchy, FF_c_index,
                                 "AT_avg_tie_strength","AT_strength_centrality_in",
                                 "RT_bin_in_degree", "RT_bin_out_degree",
                                 "RT_vol_in", "RT_vol_out"])
   
   #Read in the list-listings for individuals
   listings = {}
   indiv_reader = csv.reader(open(partitionfile))
   for row in indiv_reader:        
           listings[row[0]] = {"group":row[1],"place":int(row[2]), "competing_lists": int(row[3])}
   
   # Read in the centralities of nodes in their corresponding community
   centralities = {}
   centrality_reader = csv.reader(open('results/spss/individual bonding/%s_individual_bonding.csv' % project))
   for row in centrality_reader:
      centralities[row[2]] = {"ff_in_degree":row[5]}
   
   # Read in the partition
   tmp = hp.get_partition(partitionfile)
   partitions = tmp[0]
   groups = tmp[1]
   
   # Read in the networks   
   FF_all = nx.read_edgelist('data/networks/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
   AT_all = nx.read_edgelist('data/networks/%s_solr_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
   RT_all = nx.read_edgelist('data/networks/%s_solr_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
   print "Done reading in Networks"
   
   #Determine the Maximum subset of nodes present in all Networks   
   maximum_subset = []
   for node in FF_all.nodes():
      if AT_all.has_node(node) and RT_all.has_node(node):
         maximum_subset.append(node)
   
   i = 0
   for partition in partitions:
       for node in partition:
           FF_all.add_node(node, group =  groups[i]) # Add nodes 
           AT_all.add_node(node, group =  groups[i])
           RT_all.add_node(node, group =  groups[i])
       i += 1

   i = 0
   
   #These measures are computed only once on the graph (we are making an error since the internal group structure is considered to load up those values)
   if len(maximum_subset) < 1000:
      scaling_k = len(maximum_subset)
   else:
      scaling_k = len(maximum_subset)/100
   dFF_bin_betweeness = nx.betweenness_centrality(FF_all,k=scaling_k)
   dAT_bin_betweeness = nx.betweenness_centrality(AT_all,k=scaling_k)
   #dFF_struc = sx.structural_holes(FF_all)
   
   for partition in partitions:      
      project_name = groups[i]
      
      #Determine the groups that are not in the partition
      all_other_groups = groups[:]
      group = groups[i]
      all_other_groups.remove(group)
      
      # Get all the partitions without the current partition
      partitions_without_partition = partitions[:]
      partitions_without_partition.remove(partition)
      
      #Remove the nodes that are in this partition
      remaining_nodes = [item for sublist in partitions for item in sublist] #flatlist of all nodes
      for nodes_to_be_deleted in partition:
         remaining_nodes.remove(nodes_to_be_deleted)
      
      #Create Subgraphs that contain all nodes except the ones that are in the partition
      S_FF = FF_all.subgraph(remaining_nodes)
      S_AT = AT_all.subgraph(remaining_nodes)
      S_RT = RT_all.subgraph(remaining_nodes)
      
      i += 1
      for node in partition:
         if node in maximum_subset:            
            t0 = time.time() 
            
            #Add FF nodes and edges
            S_FF.add_node(node, group = group)            
            S_FF.add_edges_from(FF_all.in_edges(node,data=True)) # in edges 
            S_FF.add_edges_from(FF_all.out_edges(node,data=True)) #out edges               
            # Delete the nodes that we again accidentally added by importing all of the node's edges
            for tmp_node in partition:
               if tmp_node != node and tmp_node in S_FF:
                  S_FF.remove_node(tmp_node)
                        
            # Add AT nodes and edges
            S_AT.add_node(node, group = group)
            S_AT.add_edges_from(AT_all.in_edges(node,data=True)) # in edges 
            S_AT.add_edges_from(AT_all.out_edges(node,data=True)) #out edges
            # Delete the nodes that we again accidentally added by importing all of the node's edges
            for tmp_node in partition:
               if tmp_node != node and tmp_node in S_AT:
                  S_AT.remove_node(tmp_node)
                  
            S_RT.add_node(node, group = group)
            S_RT.add_edges_from(RT_all.in_edges(node,data=True)) # in edges 
            S_RT.add_edges_from(RT_all.out_edges(node,data=True)) #out edges   
            # Delete the nodes that we again accidentally added by importing all of the node's edges
            for tmp_node in partition:
               if tmp_node != node and tmp_node in S_RT:
                  S_RT.remove_node(tmp_node)
                  
            print "Done creating Subgraphs"
            
            ## FF measures
            dFF_bin = nx.degree_centrality(S_FF)
            dFF_bin_in = nx.in_degree_centrality(S_FF)
            dFF_bin_out = nx.out_degree_centrality(S_FF)            
            #nx.load_centrality(S_FF,v=node, weight="weight")
            #dFF_bin_closeness = nx.closeness_centrality(S_FF,v=node)
            #dFF_bin_pagerank = nx.pagerank(S_FF, weight="weight")            
            dFF_total_in_groups = hp.filtered_group_volume(hp.incoming_group_volume(S_FF,node,all_other_groups),0)
            dFF_total_out_groups = hp.filtered_group_volume(hp.outgoing_group_volume(S_FF,node,all_other_groups),0)            
            dFF_rec = hp.individual_reciprocity(S_FF,node)   #number of reciprocated ties            
            
            ## AT Measures
            dAT_bin = nx.degree_centrality(S_AT)
            dAT_bin_in = nx.in_degree_centrality(S_AT)
            dAT_bin_out = nx.out_degree_centrality(S_AT)
            #dAT_bin_betweeness = nx.betweenness_centrality(S_AT, k=100) #nx.load_centrality(S_AT,v=node,weight="weight")
            #dAT_bin_closeness = nx.closeness_centrality(S_AT,v=node) 
            #dAT_bin_pagerank = nx.pagerank(S_AT,weight="weight")
            dAT_total_in_groups = hp.filtered_group_volume(hp.incoming_group_volume(S_AT,node,all_other_groups),0)
            dAT_total_out_groups = hp.filtered_group_volume(hp.outgoing_group_volume(S_AT,node,all_other_groups),0)
            dAT_rec = hp.individual_reciprocity(S_AT,node)   #number of @reciprocated ties
            dAT_avg_tie = hp.individual_average_tie_strength(S_AT,node)
            
            #Compute a combined measure which multiplies the strength of incoming ties times the centrality of that person
            dAT_strength_centrality = 0
            for edge in S_AT.in_edges(node,data=True):
               if edge[0] in maximum_subset:
                  dAT_strength_centrality += edge[2]["weight"]*float(centralities[edge[0]]["ff_in_degree"]) #get the centrality of the node that the tie is incoming from
            
            ############### DEPENDENT VARIABLES ###########
            
            dRT_in = nx.in_degree_centrality(S_RT) # At least once a retweets that a person has received 
            dRT_out = nx.out_degree_centrality(S_RT) # At least one retweets that a person has made            
            print "Done computing Measures"
            
            try:
               c_size = dFF_struc[node]['C-Size']
               c_dens = dFF_struc[node]['C-Density']
               c_hierarch = dFF_struc[node]['C-Hierarchy']
               c_index = dFF_struc[node]['C-Index']
            except:
               c_size = "NaN"
               c_dens = "NaN"
               c_hierarch = "NaN"
               c_index = "NaN"
               
            csv_bridging_writer.writerow([project, project_name, node, 
                                          listings[node]["competing_lists"],
                                          dFF_bin[node], dFF_bin_in[node], dFF_bin_out[node],
                                          S_FF.in_degree(node,weight="weight"), S_FF.out_degree(node,weight="weight"),
                                          dFF_total_in_groups, dFF_total_out_groups,
                                          dFF_rec[node],
                                          dFF_bin_betweeness[node],#dFF_bin_closeness[node],dFF_bin_pagerank[node],                                                                                    
                                          #c_size,c_dens,c_hierarch,c_index,                                                                                    
                                          dAT_bin[node], dAT_bin_in[node], dAT_bin_out[node],
                                          S_AT.in_degree(node,weight="weight"), S_AT.out_degree(node, weight="weight"),
                                          dAT_total_in_groups, dAT_total_out_groups,
                                          dAT_rec[node],
                                          dAT_bin_betweeness[node],#dAT_bin_closeness[node], dAT_bin_pagerank[node],                                       
                                          #dAT_struc[node]['C-Size'],dAT_struc[node]['C-Density'],dAT_struc[node]['C-Hierarchy'],dAT_struc[node]['C-Index'],                                          
                                          dAT_avg_tie[node],dAT_strength_centrality,
                                          dRT_in[node],dRT_out[node],   
                                          S_RT.in_degree(node,weight="weight"), S_RT.out_degree(node,weight="weight")
                                         ])
            t_delta = (time.time() - t0)
            print "Count: %s Node: %s Time: %s" % (i,node,t_delta)
            
            #Remove the nodes again
            S_FF.remove_node(node)
            S_AT.remove_node(node)
            S_RT.remove_node(node)
        
if __name__ == "__main__":
    main(sys.argv[1:])         