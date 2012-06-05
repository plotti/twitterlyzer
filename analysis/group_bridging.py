import networkx as nx
import csv
from itertools import groupby
from lib import structural_holes as sx

#csv_bonding_writer = csv.writer(open('results/group_bonding.csv', 'wb'))
csv_bridging_writer = csv.write(open('results/group_bridging.csv' 'wb'))
csv_bridging_writer.writerow(["Project ID", "Name", "FF_Nodes",
"FF_betweeness"])

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

#Get the internal densities of the networks
#FF_density = [node[1]["density"] for node in P_FF.nodes(data=True)]
#AT_density = [node[1]["density"] for node in P_AT(data=True)]
#RT_density = [node[1]["density"] for node in P_RT(data=True)]

#Get the betweeness measures of the nodes
FF_betweeness = nx.betweeness_centrality(H_FF)
FF_closeness = nx.closeness_centrality(H_FF)
FF_degree_centrality = nx.degree_centrality(H_FF)
FF_eigenvector = nx.eigenvector_centrality(H_FF)

#Compute the Structural Holes for the Actors
FF_ego_density =sx.ego_density(H_FF,H_FF.nodes()[0]


output = []

#Arrange it in a list
for i in range(len(FF_density)):
	output.append([i,FF_density[i]])
#	output.append([i,FF_density[i],AT_density[i],RT_density[i]])

#Write the output to a csv file
for row in output:
	csv_bonding_writer.writerow([row[0], row[1]])
#	csv_writer.writerow([row[0], row[1], row[2], row[3]])

