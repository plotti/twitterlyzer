import networkx as nx
import csv
from lib import structural_holes2 as sx
import helper as hp
import sys,getopt

def main(argv):
    #Standardvalues
    partitionfile = "data/partitions/final_partitions_p100_200_0.2.csv"
    project = "584"
    to_pajek = False
    try:
      opts, args = getopt.getopt(argv,"p:s:o")
    except getopt.GetoptError:
      print 'group_bridging.py -p <project_name> -s <partitionfile> -o [if you want pajek output]'
      sys.exit(2)
    for opt, arg in opts:
        if opt in ("-p"):
            project = arg
        elif opt in ("-s"):
            partitionfile = arg
        elif opt in ("-o"):
             to_pajek = True
        else:
            print 'group_bridging.py -p <project_name> -s <partitionfile> -o [if you want pajek output]'
    
    print "##################### GROUP BRIDGING ########################"
    print "Project %s " % project
    print "Partition %s" % partitionfile
    
    edges_writer = csv.writer(open("results/%s_bridging_edges.csv" % project, "wb"))
    csv_bridging_writer = csv.writer(open('results/spss/group bridging/%s_group_bridging.csv' % project , 'wb'))
    
    csv_bridging_writer.writerow(["Name", "FF_Nodes",
                                "FF_bin_degree", "FF_bin_in_degree", "FF_bin_out_degree",
                                "FF_bin_betweeness","FF_bin_closeness","FF_bin_eigenvector",
                                "FF_bin_c_size","FF_bin_c_density","FF_bin_c_hierarchy","FF_bin_c_index",
                                "AT_bin_degree", "AT_bin_in_degree", "AT_bin_out_degree",
                                "AT_bin_betweeness", "AT_bin_closeness", "AT_bin_eigenvector",                            
                                "AT_bin_c_size","AT_bin_c_density","AT_bin_c_hierarchy","AT_bin_c_index",
                                "AT_volume_in", "AT_volume_out",
                                "RT_volume_in", "RT_volume_out"])    
    
    # Get the overall network from disk    
    FF = nx.read_edgelist('data/networks/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
    AT = nx.read_edgelist('data/networks/%s_solr_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
    RT = nx.read_edgelist('data/networks/%s_solr_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
    
    # Read in the partition
    tmp = hp.get_partition(partitionfile)
    partitions = tmp[0]
    groups = tmp[1]
    
    # Add dummy nodes if they are missing in the networks
    for partition in partitions:
            for node in partition:
                FF.add_node(node)
                AT.add_node(node)
                RT.add_node(node)
            
    #Blockmodel the networks into groups according to the partition
    P_FF = nx.blockmodel(FF,partitions)
    P_AT = nx.blockmodel(AT,partitions)
    P_RT = nx.blockmodel(RT,partitions)
    
    #Name the nodes in the network
    #TODO check: How do I know that the names really match?
    mapping = {}
    mapping_pajek = {}
    i = 0
    for group in groups:
        mapping_pajek[i] = "\"%s\"" % group # mapping for pajek
        mapping[i] = "%s" % group 
        i += 1
    
    H_FF = nx.relabel_nodes(P_FF,mapping)
    H_AT = nx.relabel_nodes(P_AT,mapping)
    H_RT = nx.relabel_nodes(P_RT,mapping)
    
    #Outpt the networks to pajek if needed
    if to_pajek:
        OUT_FF = nx.relabel_nodes(P_FF,mapping)
        OUT_AT = nx.relabel_nodes(P_AT,mapping)
        OUT_RT = nx.relabel_nodes(P_RT,mapping)
        
        #Write the blocked network out to disk
        nx.write_pajek(OUT_FF,"results/networks/%s_grouped_FF.net" % project)
        nx.write_pajek(OUT_AT,"results/networks/%s_grouped_AT.net" % project)
        nx.write_pajek(OUT_RT,"results/networks/%s_grouped_RT.net" % project)
    
    ########## Output the Edges between groups to csv ##############
    # Needed for the computation of individual bridging
    # Edges in both directions between the groups are addded up
    processed_edges = []
    for (u,v,attrib) in H_FF.edges(data=True):
        if "%s%s" %(u,v)  not in processed_edges:
            processed_edges.append("%s%s" % (u,v))            
            if H_FF.has_edge(v,u):
                processed_edges.append("%s%s" % (v,u))
                edges_writer.writerow([u,v,attrib["weight"]+H_FF[v][u]["weight"]])
            else:
                edges_writer.writerow([u,v,attrib["weight"]])
    
    ########## MEASURES ##############
    
    #Get the number of nodes in the aggregated networks
    FF_nodes = {}
    for node in H_FF.nodes(data=True):
            FF_nodes[node[0]] = node[1]["nnodes"]
    
    #TODO What about the internal densities of these groups
    
    #Get the FF network measures of the nodes
    # Works fine on binarized Data
    FF_bin_degree = nx.degree_centrality(H_FF) 
    FF_bin_in_degree = nx.in_degree_centrality(H_FF) # The attention paid towards this group
    FF_bin_out_degree = nx.out_degree_centrality(H_FF) # The attention that this group pays towards other people
    FF_bin_betweenness = nx.betweenness_centrality(H_FF) # How often is the group between other groups
    FF_bin_closeness = nx.closeness_centrality(H_FF)
    FF_bin_eigenvector = nx.eigenvector_centrality(H_FF)
    FF_bin_struc = sx.structural_holes(H_FF)
    
    # AT network measures of the nodes
    AT_bin_degree = nx.degree_centrality(H_AT)
    AT_bin_in_degree = nx.in_degree_centrality(H_AT)
    AT_bin_out_degree = nx.out_degree_centrality(H_AT)
    AT_bin_betweenness = nx.betweenness_centrality(H_AT) 
    AT_bin_closeness = nx.closeness_centrality(H_AT)
    AT_bin_eigenvector = nx.eigenvector_centrality(H_AT) 
    AT_bin_struc = sx.structural_holes(H_AT)
    
    # Dependent Variable see csv
    # TODO A measure that calculates how often Tweets travel through this group: Eventually betweeness in the RT graph
    
    #Arrange it in a list and output
    for node in FF_bin_degree.keys():
                csv_bridging_writer.writerow([node,FF_nodes[node],
                                                FF_bin_degree[node], FF_bin_in_degree[node], FF_bin_out_degree[node],
                                                FF_bin_betweenness[node],FF_bin_closeness[node],FF_bin_eigenvector[node],
                                                FF_bin_struc[node]['C-Size'],FF_bin_struc[node]['C-Density'],FF_bin_struc[node]['C-Hierarchy'],FF_bin_struc[node]['C-Index'],
                                                AT_bin_degree[node], AT_bin_in_degree[node], AT_bin_out_degree[node],
                                                AT_bin_betweenness[node], AT_bin_closeness[node], AT_bin_eigenvector[node],
                                                AT_bin_struc[node]['C-Size'],AT_bin_struc[node]['C-Density'],AT_bin_struc[node]['C-Hierarchy'],AT_bin_struc[node]['C-Index'],
                                                H_AT.in_degree(node,weight="weight"), H_AT.out_degree(node,weight="weight"),
                                                H_RT.in_degree(node,weight="weight"), H_RT.out_degree(node,weight="weight")
                                            ])        
if __name__ == "__main__":
   main(sys.argv[1:])                