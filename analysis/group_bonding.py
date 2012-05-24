import networkx as nx
import csv

csv_writer = csv.writer(open('results/group_bonding.csv', 'wb'))

#Log 05.05 group 109, 110, 111 missing
projects1 = [4, 6, 9, 13, 17, 19, 21, 25, 27, 31, 33, 39, 44, 46, 48, 56, 62, 70, 72, 82, 86, 94, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108]
#Log 06.06 Adding more groups to the analysis
projects2 = [112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 123, 137, 141, 143, 145, 149, 153, 155, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 170, 171, 172, 174, 175, 176, 177, 178, 179, 180, 181, 187, 189, 207, 209, 211, 213, 217, 219, 221, 233, 245, 247, 251, 253, 255, 257, 259, 261, 263, 265, 271, 275, 279, 281, 285, 291, 293, 297, 303, 305, 307, 311, 315, 317, 319, 325, 327, 329, 333, 337, 339, 341, 351, 353, 355, 357, 359, 361, 365, 367, 369, 371, 373, 379, 385, 387, 389, 391, 395, 397, 399, 401, 403, 405, 407]
projects = projects1 + projects2

csv_writer.writerow(["Project", "Name", "Member_count", "FF_Nodes", "AT_Nodes", "RT_Nodes", 
"FF_density", "AT_density", "FF_avg_path_length", "AT_avg_path_length", 
"FF_clustering", "AT_clustering", "FF_reciprocity", "AT_reciprocity", "AT_avg_tie_strength", "RT_density", "RT_edges", "RT_volume"])

#Read in members count for each project
reader = csv.reader(open("results/lists_stats.csv", "rb"), delimiter=",")
temp  = {}
for row in reader:
        temp[int(row[1])] = {"name":row[0],"member_count":row[3]}

def total_edge_weight(D):
	total = 0
	for edge in D.edges(data=True):
		total += edge[2]["weight"]
	return total 
	
def average_tie_strength(D):
	return float(total_edge_weight(D))/len(D.edges())
	
def reciprocity(D):
	G=D.to_undirected() # copy 
	for (u,v) in D.edges(): 
	    if not D.has_edge(v,u): 
        	    G.remove_edge(u,v) 
        return float(len(G.edges()))/len(D.edges())
        
for project in projects:
    
    FF = nx.read_edgelist('data/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
    AT = nx.read_edgelist('data/%s_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
    RT = nx.read_edgelist('data/%s_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
    
    FF_density = nx.density(FF)
    AT_density = nx.density(AT)
    FF_transitivity = nx.transitivity(FF)
    AT_transitivity = nx.transitivity(AT)

    #In case the graph is split into multiple graphs get the biggest connected component
    FF_partition = nx.weakly_connected_components(FF)[0]
    AT_partition = nx.weakly_connected_components(AT)[0]
    FF_comp = FF.subgraph(FF_partition)
    AT_comp = AT.subgraph(AT_partition)
    
    #Measures needing a connected graph
    FF_clustering = nx.average_clustering(FF_comp.to_undirected())
    AT_clustering = nx.average_clustering(AT_comp.to_undirected())
    FF_avg_path_length = nx.average_shortest_path_length(FF_comp)
    AT_avg_path_length = nx.average_shortest_path_length(AT_comp)
    
    #Own Measures
    #Calculate the number of reciprocated ties of all ties
    FF_reciprocity = reciprocity(FF)
    AT_reciprocity = reciprocity(AT)
    AT_avg_tie_strength = average_tie_strength(AT)
    
    #Dependent Variable
    RT_density = nx.density(RT)
    RT_edges = len(RT.edges())
    RT_volume = total_edge_weight(RT)
    
    #Member Count
    project_name = temp[project]["name"]
    member_count = int(temp[project]["member_count"])
    
    print "############ Calculating Project %s ############### " % project    
    #print "FF Density %s, AT Density %s" % (FF_density,AT_density)
    #print "FF Clustering %s, AT Clustering %s" % (FF_clustering, AT_clustering)
    #print "FF avg. path length %s, AT avg. path length %s" % (FF_avg_path_length, AT_avg_path_length)
    #print "FF reciprocity %s, AT reciprocity %s" % (FF_reciprocity, AT_reciprocity)
    
    csv_writer.writerow([project, project_name, member_count, len(FF.nodes()), len(AT.nodes()), len(RT.nodes()), 
    FF_density, AT_density, FF_avg_path_length, AT_avg_path_length, FF_clustering, 
    AT_clustering, FF_reciprocity, AT_reciprocity, AT_avg_tie_strength, RT_density, RT_edges, RT_volume])
