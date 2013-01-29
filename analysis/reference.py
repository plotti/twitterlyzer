import os
import csv
import helper as hp
import networkx as nx

#Example Networks from Literature

OC = nx.read_pajek("results/networks/reference/OClinks_w.net")
OC.name = "Opsahl"
FR = nx.read_pajek("results/networks/reference/Freemans_EIES-3_n32.net")
FR.name = "Freeman"
CP = nx.read_pajek("results/networks/reference/Cross_Parker-Consulting_info.net")
CP.name = "Cross_Parker"


networks = [OC,FR,CP]

def create_dummy_partition(network):
    csv_writer = csv.writer(open('data/partitions/%s_partition.csv' % network.name, 'wb'))
    i = 0
    for node in network.nodes():
        i+=1
        csv_writer.writerow([node,"a",i,1])

def create_dummy_stats(network):
    csv_writer = csv.writer(open("results/stats/%s_lists_stats.csv" % network.name, "wb"))
    csv_writer.writerow(["Community name","Based on Projects","# lists,Total unique members on all lists"])
    csv_writer.writerow(["a","a",10,10])
    
############## Group Bonding ##############

for network in networks:
    create_dummy_partition(network)
    create_dummy_stats(network)
    nx.write_weighted_edgelist(network, "data/networks/%s_FF.edgelist" % network.name)
    nx.write_weighted_edgelist(network, "data/networks/%s_solr_AT.edgelist" % network.name)
    nx.write_weighted_edgelist(network, "data/networks/%s_solr_RT.edgelist" % network.name)
    partition = "data/partitions/%s_partition.csv" % network.name
    project = network.name
    cmd = 'python group_bonding.py -p %s -s %s' % (project, partition)
    os.system(cmd)    
    