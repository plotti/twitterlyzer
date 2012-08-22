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

def read_in_net(edges_file):
    net_hash = {}
    for row in edges_file:
        if not net_hash.has_key(row[0]):
            net_hash[row[0]] = {row[1]: []}
        if not net_hash[row[0]].has_key(row[1]):
            net_hash[row[0]] = dict(net_hash[row[0]].items() + {row[1]: []}.items())
        net_hash[row[0]][row[1]].append(row[3])
    return net_hash

f1 = open("data/solr_584_at_connections.csv", "rb")
f2 = open("data/584_rt_connections.csv","rb")
at_edges = csv.reader(nonull(f1), delimiter=",") 
rt_edges = csv.reader(nonull(f2), delimiter=",")
at_net = read_in_net(at_edges)
rt_net = read_in_net(rt_edges)
    
def in_at(person):
    out = []
    for key in at_net.keys():
        if at_net[key].has_key(person):
            out.append([at_net[key][person],key])
    return out

def in_rt(person):
    out = []
    for key in rt_net.keys():
        if rt_net[key].has_key(person):
            out.append([rt_net[key][person],key])
    return out

def out_at(person):
    out = []
    for key in at_net[person]:
        out.append([at_net[person][key],key])
    return out

def out_rt(person):
    out = []
    for key in rt_net[person]:
        out.append([rt_net[person][key],key])
    return out

def volume(mentions):
    total = 0
    for r in mentions:
        total += len(r[0])
    return total