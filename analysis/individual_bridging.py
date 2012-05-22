import networkx as nx
import csv
from itertools import groupby

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

#Get the partition from a partition file
reader = csv.reader(open("data/partitions.csv", "rb"), delimiter=",")
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

#Genereate a subgraph consisting out of two partitions
#With n= 2(pairs of 2)  and k = 200 (~number of groups) we can generate 19900 combinations
p1 = 100
p2 = 12
S_FF = FF.subgraph(partition[p1]+partition[p2])


#Relabel for pajek
def mapping(x):
	return "\"%s\"" % x

H_FF = nx.relabel_nodes(S_FF,mapping)

#Write it to disk
nx.write_pajek(H_FF,"results/networks/%s_%s_%s_pair_FF.net" % (project, groups[p1], groups[p2]))

#TODO: Calculate betweeness for actors 
#TODO: Correlate betweeness against information
#a) received from own group
#b) received from other group
#c) sent to own group 
#d) sent to other group
