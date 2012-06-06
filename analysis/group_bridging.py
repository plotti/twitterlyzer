import networkx as nx
import csv
from itertools import groupby
from lib import structural_holes2 as sx

#csv_bonding_writer = csv.writer(open('results/group_bonding.csv', 'wb'))
csv_bridging_writer = csv.writer(open('results/group_bridging.csv', 'wb'))
csv_bridging_writer.writerow(["Name", "FF_Nodes",
"FF_betweeness","FF_closeness","FF_degree","FF_eigenvector",
"FF_c_size","FF_c_density","FF_c_hierarchy","FF_c_index"])

def uniq(seq): 
   # order preserving
   checked = []
   for e in seq:
       if e not in checked:
           checked.append(e)
   return checked

# Get the overall network from disk
project = "all"
FF = nx.read_edgelist('data/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
#AT = nx.read_edgelist('data/%s_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
#RT = nx.read_edgelist('data/%s_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())

#Get the partition from a partition file 
reader = csv.reader(open("data/partitions_memberships.csv", "rb"), delimiter=",")
temp  = []
partition = []
for row in reader:
	temp.append([row[0],row[1]])

#Sort the list according to category
temp = sorted(temp, key=lambda x: x[1])
groups = uniq(map(lambda x: x[1],temp))

for key, group in groupby(temp, lambda x: x[1]):
	g = []
	for thing in group:
		g.append(thing[0])	
	partition.append(g)

#Blockmodel the networks into groups according to the partition
P_FF = nx.blockmodel(FF,partition)
#P_AT = nx.blockmodel(AT,partition)
#P_RT = nx.blockmodel(RT,partition)

#Name the nodes in the network
#How do I know that the names match?
mapping = {}
i = 0
for group in groups:
	mapping[i] = "\"%s\"" % group
	i += 1

H_FF = nx.relabel_nodes(P_FF,mapping)
#H_AT = nx.relabel_nodes(P_AT,mapping)
#H_RT = nx.relabel_nodes(P_RT,mapping)

#Write the blocked network out to disk
nx.write_pajek(H_FF,"results/networks/%s_grouped_FF.net" % project)
#nx.write_pajek(P_AT,"results/%s_grouped_AT.net" % project)
#nx.write_pajek(P_RT,"results/%s_grouped_RT.net" % project)

########## MEASURES ##############

#Get the number of nodes in the aggregated networks
FF_nodes = {}
for node in H_FF.nodes(data=True):
	FF_nodes[node[0]] = node[1]["nnodes"]

#Get the betweeness measures of the nodes
FF_betweenness = nx.betweenness_centrality(H_FF)
FF_closeness = nx.closeness_centrality(H_FF)
FF_degree = nx.degree_centrality(H_FF)
FF_eigenvector = nx.eigenvector_centrality(H_FF)

#Compute the Structural Holes for the Actors
FF_struc = sx.structural_holes(H_FF)

#Arrange it in a list
for node in FF_betweenness.keys():
	csv_bridging_writer.writerow([node,FF_nodes[node],
	FF_betweenness[node],FF_closeness[node],FF_degree[node],FF_eigenvector[node],
	FF_struc[node]['C-Size'],FF_struc[node]['C-Density'],FF_struc[node]['C-Hierarchy'],FF_struc[node]['C-Index']])
