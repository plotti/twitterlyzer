import networkx as nx
import csv
import helper as hp
import sys
import sys,getopt
partitionfile = "data/partitions/final_partitions_p100_200_0.2.csv"
project = "584"
tmp = hp.get_partition(partitionfile)
partitions = tmp[0]
groups = tmp[1]
FF_all = nx.read_edgelist('data/networks/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
AT_all = nx.read_edgelist('data/networks/%s_solr_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
RT_all = nx.read_edgelist('data/networks/%s_solr_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())

#Read in the network as a dict
def nonull(stream):
    for line in stream:
        yield line.replace('\x00', '')

f = open("data/solr_584_at_connections.csv", "rb")
at_edges = csv.reader(nonull(f), delimiter=",") 
at_net = {}      
for row in at_edges:
    if not at_net.has_key(row[0]):
        at_net[row[0]] = {row[1]: []}
    if not at_net[row[0]].has_key(row[1]):
        at_net[row[0]] = dict(at_net[row[0]].items() + {row[1]: []}.items())
    at_net[row[0]][row[1]].append(row[3])

    
def in_at(person):
    out = []
    for key in at_net.keys():
        if at_net[key].has_key(person):
            out.append([at_net[key][person],key])
    return out

def volume(mentions):
    total = 0
    for r in mentions:
        total += len(r[0])
    return total

def out_at(person):
    out = []
    for key in at_net[person]:
        out.append([at_net[person][key],key])
    return out