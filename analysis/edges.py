import networkx as nx
import math as math
import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict
import csv
import helper as hp

#Partitionfile
partitionfile = "data/partitions/final_partitions_p100_200_0.2.csv"
project = "584"

#Read in Networks    
FF_all = nx.read_edgelist('data/networks/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
AT_all = nx.read_edgelist('data/networks/%s_solr_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
RT_all = nx.read_edgelist('data/networks/%s_solr_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())

#Output
#bridging_csv_writer = csv.writer(open('results/spss/edges/%sbridging_edges.csv' % project, 'wb'))
#bonding_csv_writer = csv.writer(open('results/spss/edges/%sbonding_edges.csv' % project, 'wb'))
bridging_csv_writer = csv.writer(open('results/spss/edges/%sreverse_bridging_edges.csv' % project, 'wb')) #reverse
bonding_csv_writer = csv.writer(open('results/spss/edges/%sreverse_bonding_edges.csv' % project, 'wb')) #reverse

    
# Read in the partitions
tmp = hp.get_partition(partitionfile)
partitions = tmp[0]
groups = tmp[1]

ff_bridging_edges = defaultdict(dict)
ff_bonding_edges = defaultdict(dict)
at_bridging_edges = defaultdict(dict)
at_bonding_edges = defaultdict(dict)
rt_bridging_edges = defaultdict(list)
rt_bonding_edges = defaultdict(list)

i = 0
for partition in partitions:
    i += 1
    print i
    ################ FF Edges ######################
    
    #Collect the FF edges between groups
    for edge in nx.edge_boundary(FF_all, partition):
        if FF_all.has_edge(edge[1],edge[0]):
            ff_bridging_edges[edge[0]][edge[1]] = "recip"            
        else:
            ff_bridging_edges[edge[0]][edge[1]] = "non_recip"
    
    #Collect the FF edges inside the group
    for edge in FF_all.subgraph(partition).edges():
        if FF_all.has_edge(edge[1],edge[0]):
            ff_bonding_edges[edge[0]][edge[1]] = "recip"              
        else:
            ff_bonding_edges[edge[0]][edge[1]] = "non_recip"              
    
    ################ AT Edges ######################
    # TODO its missing the reciprocated edges that have a weight > 1
    # Idea 1: We might simply add up the incoming and outgoing edges to a total weight
    
    #Collect the AT edges that are between groups
    for edge in nx.edge_boundary(AT_all, partition):
        if AT_all.has_edge(edge[1],edge[0]):
            if AT_all.get_edge_data(*edge)["weight"] == 1:
                at_bridging_edges[edge[0]][edge[1]] = "recip"                  
        else:
            at_bridging_edges[edge[0]][edge[1]] = AT_all.get_edge_data(*edge)["weight"]
    
    #Collect the AT edges that are inside the group
    for edge in AT_all.subgraph(partition).edges():
        if AT_all.has_edge(edge[1],edge[0]):
            if AT_all.get_edge_data(*edge)["weight"] == 1:
                at_bonding_edges[edge[0]][edge[1]] = "recip"
        else:
            at_bonding_edges[edge[0]][edge[1]] = AT_all.get_edge_data(*edge)["weight"]            
    
    
    ################ RT Edges ######################
    
    #Collect the RT edges between groups:
    for edge in nx.edge_boundary(RT_all, partition):                
        rt_bridging_edges[RT_all.get_edge_data(*edge)["weight"]].append((edge[0],edge[1]))
        
    #Collect the RT edges inside group
    for edge in RT_all.subgraph(partition).edges():      
        rt_bonding_edges[RT_all.get_edge_data(*edge)["weight"]].append((edge[0],edge[1]))

##################BONDING: Influence of AT strengths on bonding retweets ##############################

bonding_flow = defaultdict(dict)
for rt_strength,retweets in rt_bonding_edges.iteritems():             
        for retweet in retweets:
            try:
                #value = at_bonding_edges[retweet[0]][retweet[1]] #Same direction
                value = at_bonding_edges[retweet[1]][retweet[0]] # Reverse 
                if bonding_flow.has_key(value):
                    bonding_flow[value] += rt_strength
                else:
                    bonding_flow[value] = rt_strength
                #del at_bonding_edges[retweet[0]][retweet[1]] # delete that entry same direction
                del at_bonding_edges[retweet[1]][retweet[0]] # delete that entry reverse
            except:
                ""

bonding_no_flow = {}
for k,v1 in at_bonding_edges.iteritems():
        for k,value in v1.iteritems():
            if bonding_no_flow.has_key(value):
                bonding_no_flow[value] += 1
            else:
                bonding_no_flow[value] = 0
                
##################BRIDGING: Influence of AT strenghts on bridging retweets ##############################

bridging_flow = {}
for rt_strength,retweets in rt_bridging_edges.iteritems():             
        for retweet in retweets:
            try:
                #value = at_bridging_edges[retweet[0]][retweet[1]] #Same direction
                value = at_bridging_edges[retweet[1]][retweet[0]] #reverse
                if bridging_flow.has_key(value):
                    bridging_flow[value] += rt_strength
                else:
                    bridging_flow[value] = rt_strength
                #del at_bridging_edges[retweet[0]][retweet[1]] # delete that entry same direction
                del at_bridging_edges[retweet[1]][retweet[0]] # delete that entry reverse
            except:
                ""
                
bridging_no_flow = {}
for k,v1 in at_bridging_edges.iteritems():
        for k,value in v1.iteritems():
            if bridging_no_flow.has_key(value):
                bridging_no_flow[value] += 1
            else:
                bridging_no_flow[value] = 0


# CSV Output
bridging_csv_writer.writerow(["bridging_at_strength","bridging_retweets", "bridging_no_retweets", "bridging_retweets/no_retweets"])
bonding_csv_writer.writerow(["bonding_at_strength","bonding_retweets", "bonding_no_retweets", "bonding_retweets/no_retweets"])

bridging_tie_strengths = []
bonding_tie_strengths = []
bonding_rt_ratios = []
bridging_rt_ratios = []

#BRIDGING TIES
for k,v in bridging_flow.iteritems():
    if k != "recip":            
        if bridging_no_flow.has_key(k) and bridging_no_flow[k] != 0:            
            ratio = v/bridging_no_flow[k]
            bridging_tie_strengths.append(k)
            bridging_rt_ratios.append(ratio)
            bridging_csv_writer.writerow([k,v,bridging_no_flow[k],ratio])            

#BONDING TIES
for k,v in bonding_flow.iteritems():
    if k != "recip":            
        if bonding_no_flow.has_key(k) and bonding_no_flow[k] != 0:            
            ratio = v/bonding_no_flow[k]
            bonding_tie_strengths.append(k)
            bonding_rt_ratios.append(ratio)
            bonding_csv_writer.writerow([k,v,bonding_no_flow[k],ratio])
    
#Plot it
fig = plt.figure(figsize=(42.67, 32.0))
ax1 = fig.add_subplot(111)
ax1.plot(bridging_tie_strengths, bridging_rt_ratios,'b-', label='Bridging RT/No_RT percentage through ties with strength x')
ax1.plot(bonding_tie_strengths, bonding_rt_ratios,'g-', label='Bonding RT/No_RT percentage through ties with strength x')
ax1.legend(loc=2)
#plt.savefig("results/edges.png")
plt.savefig("results/reverse_edges.png")
plt.close()    