import networkx as nx
import csv
import helper as hp
import sys
import sys,getopt

def main(argv):
    #Standardvalues
    partitionfile = "data/partitions/final_partitions_p100_200_0.2.csv"
    project = "584"
    to_pajek = False
    try:
      opts, args = getopt.getopt(argv,"p:s:o")
    except getopt.GetoptError:
      print 'group_bonding.py -p <project_name> -s <partitionfile> -o [if you want pajek output]'
      sys.exit(2)
    for opt, arg in opts:
        if opt in ("-p"):
            project = arg
        elif opt in ("-s"):
            partitionfile = arg
        elif opt in ("-o"):
             to_pajek = True
        else:
            print 'group_bonding.py -p <project_name> -s <partitionfile> -o [if you want pajek output]'
    
    print "##################### GROUP BONDING ########################"
    print "Project %s " % project
    print "Partition %s" % partitionfile
    
    csv_writer = csv.writer(open('results/spss/group bonding/%s_group_bonding.csv' % project, 'wb'))
    
    csv_writer.writerow(["Project", "Name", "Member_count",
                        "FF_Nodes", "AT_Nodes", "RT_Nodes", 
                        "FF_bin_density", "AT_density",
                        "FF_bin_avg_path_length", "AT_bin_avg_path_length", 
                        "FF_bin_clustering", "AT_bin_clustering",
                        "FF_reciprocity", "AT_reciprocity",
                        "FF_bin_transitivity", "AT_bin_transitivity",                    
                        "RT_density", "RT_total_volume"])
    
    #Read in members count for each project
    reader = csv.reader(open("results/stats/%s_lists_stats.csv" % project, "rb"), delimiter=",")
    temp  = {}
    reader.next() # Skip first row
    for row in reader:        
            temp[row[0]] = {"name":row[0],"member_count":int(row[3])}
    
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
            FF_all.add_node(node, group =  groups[i])
            AT_all.add_node(node, group =  groups[i])
            RT_all.add_node(node, group =  groups[i])
        i += 1
        
    #Write out to pajek for gephi visualization
    if to_pajek:
        nx.write_pajek(FF_all,"results/networks/%s_FF.net" % project)
        nx.write_pajek(AT_all,"results/networks/%s_AT.net" % project)
        nx.write_pajek(RT_all,"results/networks/%s_RT.net" % project)
    
    i = 0    
    for partition in partitions:
    
        project_name = groups[i]    
        # Add up total members 
        member_count = 0    
        member_count = int(temp[project_name]["member_count"])
        
        print "############ Calculating Project %s ############### " % project_name
    
        # Generate a subgraph according to the partition
        FF = FF_all.subgraph(partition)
        AT = AT_all.subgraph(partition)
        RT = RT_all.subgraph(partition)
        
        #Additional Info for each project    
        FF.name = "FF_%s " % project_name
        AT.name = "AT_%s " % project_name
        RT.name = "RT_%s " % project_name
    
        ############### Compute Group measures ################
    
        #Measures FF
        FF_bin_density = nx.density(FF)    
        FF_bin_transitivity = nx.transitivity(FF)            
        FF_reciprocity = hp.reciprocity(FF) # Calculate the number of reciprocated ties of all ties
        
        # Measures that need  a connected graph
        # In case the graph is split into multiple graphs get the biggest connected component    
        FF_partition = nx.weakly_connected_components(FF)[0]    
        FF_comp = FF.subgraph(FF_partition)    
        FF_bin_avg_path_length = nx.average_shortest_path_length(FF_comp)
        FF_bin_clustering = nx.average_clustering(FF_comp.to_undirected(),count_zeros=False) # Networks with a lot of mutual trust have a high clustering coefficient. # Star networks with a single broadcast node and passive listeners have a low clustering coefficient.    
        
        # Measures AT
        #AT_density = nx.density(AT) # deprecated since it treats the network as binarized and we lose all the interaction information
        AT_density = hp.average_tie_strength(AT)
        AT_bin_transitivity = nx.transitivity(AT)
        AT_reciprocity = hp.reciprocity(AT)
        #AT_avg_volume = hp.average_tie_strength(AT)
        
        AT_partition = nx.weakly_connected_components(AT)[0]
        AT_comp = AT.subgraph(AT_partition)
        AT_bin_avg_path_length = nx.average_shortest_path_length(AT_comp)
        AT_bin_clustering = nx.average_clustering(AT_comp.to_undirected())
            
        # Dependent Variable
        #RT_density = nx.density(RT) # Danger this works on the binarized graph! # TODO I need a weighted density for RT
        RT_density = hp.average_tie_strength(RT) 
        RT_total_volume = hp.total_edge_weight(RT)
    
        ############### Output ################
    
        csv_writer.writerow([project, project_name, member_count,
                             len(FF.nodes()), len(AT.nodes()), len(RT.nodes()), 
                            FF_bin_density, AT_density,
                            FF_bin_avg_path_length, AT_bin_avg_path_length,
                            FF_bin_clustering, AT_bin_clustering,
                            FF_reciprocity, AT_reciprocity,
                            FF_bin_transitivity, AT_bin_transitivity,                        
                            RT_density, RT_total_volume])
        i += 1
        
if __name__ == "__main__":
   main(sys.argv[1:])