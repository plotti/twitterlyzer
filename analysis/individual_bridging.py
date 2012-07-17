import networkx as nx
import csv
import helper as hp
import sys
from lib import structural_holes2 as sx
import sys,getopt

def main(argv):
   #Standardvalues
   partitionfile = "data/partitions/final_partitions_p100_200_0.2.csv"
   project = "584"
   to_pajek = False
   try:
     opts, args = getopt.getopt(argv,"p:s:o")
   except getopt.GetoptError:
     print 'individual_bridging.py -p <project_name> -s <partitionfile> -o [if you want pajek output]'
     sys.exit(2)
   for opt, arg in opts:
       if opt in ("-p"):
           project = arg
       elif opt in ("-s"):
           partitionfile = arg
       elif opt in ("-o"):
            to_pajek = True
       else:
         print 'individual_bridging.py -p <project_name> -s <partitionfile> -o [if you want pajek output]'
   
   print "##################### INDIVIDUAL BRIDGING ########################"
   print "Project %s " % project
   print "Partition %s" % partitionfile
   
   csv_bridging_writer = csv.writer(open('results/spss/individual bridging/%s_individual_bridging.csv' % project, 'wb'))   
   csv_bridging_writer.writerow(["Name", "Group1", "Group2", "Number_between_ties",
                                 "Competing_lists",
                                 "FF_bin_degree", "FF_bin_in_degree", "FF_bin_out_degree",
                                 "FF_bin_betweeness",
                                 #"FF_c_size","FF_c_density","FF_c_hierarchy","FF_c_index",
                                 "FF_own_group_in_volume", "FF_other_group_in_volume",
                                 "FF_own_group_out_volume", "FF_other_group_out_volume",
                                 "AT_bin_degree", "AT_bin_in_degree", "AT_bin_out_degree",
                                 "AT_bin_betweeness",
                                 "AT_volume_in", "AT_volume_out",
                                 #"AT_c_size","AT_c_density","AT_c_hierarchy","AT_c_index",
                                 "AT_own_group_in_volume", "AT_other_group_in_volume",
                                 "AT_own_group_out_volume", "AT_other_group_out_volume",
                                 "RT_total_volume_in", "RT_total_volume_out",
                                 "RT_own_group_in_volume", "RT_other_group_in_volume",
                                 "RT_own_group_out_volume", "RT_other_group_out_volume"])
   
   #Read in the list-listings for individuals
   listings = {}
   indiv_reader = csv.reader(open(partitionfile))
   for row in indiv_reader:        
           listings[row[0]] = {"group":row[1],"place":int(row[2]), "competing_lists": int(row[3])}
   
   #Read in the edges between the groups and sort them
   GROUPS = 80 # 80x200 ~ 16000 individuals for analysis 
   reader = csv.reader(open("results/%s_bridging_edges.csv" % project, "rb"), delimiter=",")
   edges  = []
   for row in reader:
           edges.append({"group1":row[0],"group2":row[1], "count":float(row[2])})
   edges_sorted = sorted(edges, key=lambda k: k["count"])
   distance_between_samples = int(float(len(edges_sorted)) / GROUPS)
   if distance_between_samples == 0: distance_between_samples = 1 #Minimal Distance
   iterator = 0
   
   # Read in the partition
   tmp = hp.get_partition(partitionfile)
   partitions = tmp[0]
   groups = tmp[1]
   
   # Read in the networks   
   FF_all = nx.read_edgelist('data/networks/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
   AT_all = nx.read_edgelist('data/networks/%s_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
   RT_all = nx.read_edgelist('data/networks/%s_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
   
   i = 0
   for partition in partitions:
       for node in partition:
           FF_all.add_node(node, group =  groups[i]) # Add nodes 
           AT_all.add_node(node, group =  groups[i])
           RT_all.add_node(node, group =  groups[i])
       i += 1
   
   while iterator < len(edges_sorted):
      
      #Genereate a subgraph consisting out of two partitions
      # Problem: With n= 2(pairs of 2)  and k = 200 (~number of groups) we can generate 200 ^ 200 /2 combinations. How to generate the two pairs?   
      # Solution 1: By Random
      # Solution 2: Based on the ordered tie strength between groups from the group bridging step
      # e.g. [10,9,8,7,6,5,0]  take every xth element to create set with this size [10,8,6,0]
      # TODO Bin same edges with same weight into the same category and then select a grop by random
      selected_edge = edges_sorted[iterator]
      group1 = selected_edge["group1"]
      group2 = selected_edge["group2"]
      index1 = groups.index(group1)
      index2 = groups.index(group2)   
      print "%s : %s with %s of strength %s" % (iterator, group1, group2, selected_edge["count"])
         
      # Create Subgraphs
      S_FF = FF_all.subgraph(partitions[index1]+partitions[index2])
      S_FF.name = "%s_%s" % (group1, group2)
      S_AT = AT_all.subgraph(partitions[index1]+partitions[index2])
      S_AT.name = "%s_%s" % (group1, group2)
      S_RT = RT_all.subgraph(partitions[index1]+partitions[index2])
      S_RT.name = "%s_%s" % (group1, group2)   
      iterator += distance_between_samples # Make equidistant steps in with the iterator
   
      #Optional Output to pajek   
      if to_pajek:
         print "Generating pajek output for %s %s" % (groups[index1], groups[index2])
         #Relabel for pajek
         def mapping(x):
                 return "\"%s\"" % x   
         H_FF = nx.relabel_nodes(S_FF,mapping)
         H_AT = nx.relabel_nodes(S_AT,mapping)
         H_RT = nx.relabel_nodes(S_RT,mapping)   
         #Write it to disk
         nx.write_pajek(H_FF,"results/networks/pairs/%s_%s_%s_pair_FF.net" % (project, groups[index1], groups[index2]))
         nx.write_pajek(H_AT,"results/networks/pairs/%s_%s_%s_pair_AT.net" % (project, groups[index1], groups[index2]))
         nx.write_pajek(H_RT,"results/networks/pairs/%s_%s_%s_pair_RT.net" % (project, groups[index1], groups[index2]))
      
      ################ MEASURES ################
      
      ## FF measures
      dFF_bin = nx.degree_centrality(S_FF)
      dFF_bin_in = nx.in_degree_centrality(S_FF)
      dFF_bin_out = nx.out_degree_centrality(S_FF)
      dFF_bin_betweeness = nx.betweenness_centrality(S_FF)
      # Structural Holes has problems, probably with nonconnected networks (eventually compte bigest component first)
      # dFF_struc = sx.structural_holes(S_FF)
      # Which one is own group which one is other ?
      dFF_group1_vol_in = hp.individual_in_volume(S_FF,group1)
      dFF_group2_vol_in = hp.individual_in_volume(S_FF,group2)
      dFF_group1_vol_out = hp.individual_out_volume(S_FF,group1)
      dFF_group2_vol_out = hp.individual_out_volume(S_FF,group2)   
      
      ## AT Measures
      dAT_bin = nx.degree_centrality(S_AT)
      dAT_bin_in = nx.in_degree_centrality(S_AT)
      dAT_bin_out = nx.out_degree_centrality(S_AT)
      dAT_bin_betweeness = nx.betweenness_centrality(S_AT)
      # Why can here the structural holes not be computed?
      #dAT_struc = sx.structural_holes(S_AT)
      dAT_group1_vol_in = hp.individual_in_volume(S_AT,group1)
      dAT_group2_vol_in = hp.individual_in_volume(S_AT,group2)
      dAT_group1_vol_out = hp.individual_out_volume(S_AT,group1)
      dAT_group2_vol_out = hp.individual_out_volume(S_AT,group2)        
      
      ############### DEPENDENT VARIABLES ###########
      
      dRT_group1_vol_in = hp.individual_in_volume(S_RT,group1)
      dRT_group2_vol_in = hp.individual_in_volume(S_RT,group2)
      dRT_group1_vol_out = hp.individual_out_volume(S_RT,group1)
      dRT_group2_vol_out = hp.individual_out_volume(S_RT,group2)
      
      ############ OUTPUT ###########################
      #Arrange it in a list and output
      for node in dFF_bin.keys():
         # Depending if the node is in partition 1 or two the definition of "own" and "other" changes.
         if node in partitions[index1]:
            #FF
            FF_own_group_in_volume = dFF_group1_vol_in[node]
            FF_own_group_out_volume = dFF_group1_vol_out[node]
            FF_other_group_in_volume = dFF_group2_vol_in[node]         
            FF_other_group_out_volume = dFF_group2_vol_out[node]
            #AT
            AT_own_group_in_volume = dAT_group1_vol_in[node]
            AT_own_group_out_volume = dAT_group1_vol_out[node]
            AT_other_group_in_volume = dAT_group2_vol_in[node]         
            AT_other_group_out_volume = dAT_group2_vol_out[node]
            #RT
            RT_own_group_in_volume = dRT_group1_vol_in[node]
            RT_own_group_out_volume = dRT_group1_vol_out[node]
            RT_other_group_in_volume = dRT_group2_vol_in[node]         
            RT_other_group_out_volume = dRT_group2_vol_out[node]
         else:
            FF_own_group_in_volume = dFF_group2_vol_in[node]
            FF_own_group_out_volume = dFF_group2_vol_out[node]
            FF_other_group_in_volume = dFF_group1_vol_in[node]         
            FF_other_group_out_volume = dFF_group1_vol_out[node]
            #AT
            AT_own_group_in_volume = dAT_group2_vol_in[node]
            AT_own_group_out_volume = dAT_group2_vol_out[node]
            AT_other_group_in_volume = dAT_group1_vol_in[node]         
            AT_other_group_out_volume = dAT_group1_vol_out[node]
            #RT
            RT_own_group_in_volume = dRT_group2_vol_in[node]
            RT_own_group_out_volume = dRT_group2_vol_out[node]
            RT_other_group_in_volume = dRT_group1_vol_in[node]         
            RT_other_group_out_volume = dRT_group1_vol_out[node]
            
         csv_bridging_writer.writerow([node, group1, group2,selected_edge["count"],
                                       listings[node]["competing_lists"],
                                       dFF_bin[node], dFF_bin_in[node], dFF_bin_out[node],
                                       dFF_bin_betweeness[node],
                                       #dFF_struc[node]['C-Size'],dFF_struc[node]['C-Density'],dFF_struc[node]['C-Hierarchy'],dFF_struc[node]['C-Index'],
                                       FF_own_group_in_volume, FF_other_group_in_volume,
                                       FF_own_group_out_volume, FF_other_group_out_volume,
                                       dAT_bin[node], dAT_bin_in[node], dAT_bin_out[node],
                                       dAT_bin_betweeness[node],
                                       S_AT.in_degree(node,weight="weight"), S_AT.out_degree(node,weight="weight"),
                                       #dAT_struc[node]['C-Size'],dAT_struc[node]['C-Density'],dAT_struc[node]['C-Hierarchy'],dAT_struc[node]['C-Index'],
                                       AT_own_group_in_volume, AT_other_group_in_volume,
                                       AT_own_group_out_volume, AT_other_group_out_volume,
                                       S_RT.in_degree(node,weight="weight"), S_RT.out_degree(node,weight="weight"),
                                       RT_own_group_in_volume, RT_other_group_in_volume,
                                       RT_own_group_out_volume, RT_other_group_out_volume,
                                      ])
if __name__ == "__main__":
   main(sys.argv[1:])