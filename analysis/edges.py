import networkx as nx
import math as math
import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict
import csv
import sys,getopt
import helper as hp

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False
   
def main(argv):
    #Partitionfile
    partitionfile = "data/partitions/final_partitions_p100_200_0.2.csv"
    project = "584"
    reverse = False
    
    #Read in Networks    
    FF_all = nx.read_edgelist('data/networks/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
    AT_all = nx.read_edgelist('data/networks/%s_solr_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
    RT_all = nx.read_edgelist('data/networks/%s_solr_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())

    try:
        opts, args = getopt.getopt(argv,"r")
    except getopt.GetoptError:
        print 'edges.py -r [if you want to reverse the AT<-->RT tie direction ]'
    for opt, arg, in opts:
        if opt in ("-r"):
            print "Calculating the influence of outgoing AT ties on incoming RT ties"
            reverse = True
    
    #Output
    summary_csv_writer = csv.writer(open('results/spss/edges/%s_edges_summary.csv' % project, "wb"))
    summary_csv_writer.writerow(["Community", "Retweets Inside Community", "Retweets between Communities"])
    
    if reverse:
        bridging_csv_writer = csv.writer(open('results/spss/edges/%s_reverse_bridging_edges.csv' % project, 'wb')) #reverse
        bonding_csv_writer = csv.writer(open('results/spss/edges/%s_reverse_bonding_edges.csv' % project, 'wb')) #reverse
    else:
        bridging_csv_writer = csv.writer(open('results/spss/edges/%s_bridging_edges.csv' % project, 'wb'))
        bonding_csv_writer = csv.writer(open('results/spss/edges/%s_bonding_edges.csv' % project, 'wb'))

        
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
    total_bridging_edges = 0
    total_bonding_edges = 0
    
    i = 0
    for partition in partitions:
            
        ################ FF Edges ######################
        
        #Collect the FF edges between groups
        for edge in nx.edge_boundary(FF_all, partition):
            if FF_all.has_edge(edge[1],edge[0]):
                ff_bridging_edges[edge[0]][edge[1]] = "ff_recip"            
            else:
                ff_bridging_edges[edge[0]][edge[1]] = "ff_non_recip"
        
        #Collect the FF edges inside the group
        for edge in FF_all.subgraph(partition).edges():
            if FF_all.has_edge(edge[1],edge[0]):
                ff_bonding_edges[edge[0]][edge[1]] = "ff_recip"              
            else:
                ff_bonding_edges[edge[0]][edge[1]] = "ff_non_recip"              
        
        ################ AT Edges ######################
        # TODO its missing the reciprocated edges that have a weight > 1
        # Idea 1: We might simply add up the incoming and outgoing edges to a total weight
        
        #Collect the AT edges that are between groups
        for edge in nx.edge_boundary(AT_all, partition):
            if AT_all.has_edge(edge[1],edge[0]):
                if AT_all.get_edge_data(*edge)["weight"] == 1:
                    at_bridging_edges[edge[0]][edge[1]] = "at_recip"                  
            else:
                if AT_all.get_edge_data(*edge)["weight"] == 1:
                    at_bridging_edges[edge[0]][edge[1]] = "at_non_recip_w1"                  
                else:
                    at_bridging_edges[edge[0]][edge[1]] = AT_all.get_edge_data(*edge)["weight"]
        
        #Collect the AT edges that are inside the group
        for edge in AT_all.subgraph(partition).edges():
            if AT_all.has_edge(edge[1],edge[0]):
                if AT_all.get_edge_data(*edge)["weight"] == 1:
                    at_bonding_edges[edge[0]][edge[1]] = "at_recip"
            else:
                if AT_all.get_edge_data(*edge)["weight"] == 1:                    
                    at_bonding_edges[edge[0]][edge[1]] = "at_non_recip_w1"
                else:
                    at_bonding_edges[edge[0]][edge[1]] = AT_all.get_edge_data(*edge)["weight"]            
        
        
        ################ RT Edges ######################
        
        #Collect the RT edges between groups:
        tmp_rt_bridging_edges = 0
        for edge in nx.edge_boundary(RT_all, partition):                
            tmp_rt_bridging_edges += RT_all.get_edge_data(*edge)["weight"]
            rt_bridging_edges[RT_all.get_edge_data(*edge)["weight"]].append((edge[0],edge[1]))
        total_bridging_edges += tmp_rt_bridging_edges
        
        #Collect the RT edges inside group
        tmp_rt_bonding_edges = 0
        for edge in RT_all.subgraph(partition).edges():
            tmp_rt_bonding_edges += RT_all.get_edge_data(*edge)["weight"]
            rt_bonding_edges[RT_all.get_edge_data(*edge)["weight"]].append((edge[0],edge[1]))
        total_bonding_edges += tmp_rt_bonding_edges
        
        summary_csv_writer.writerow([groups[i],tmp_rt_bonding_edges,tmp_rt_bridging_edges])
        print "Community %s, Total Retweets inside: %s, Total Retweets between %s" % (groups[i],tmp_rt_bonding_edges,tmp_rt_bridging_edges)
        i += 1
        
    print "Total Bonding Edges %s" % total_bonding_edges
    print "Total Bridging Edges %s" % total_bridging_edges
    
    ##################BONDING: Influence of AT strengths on bonding retweets ##############################
    bonding_flow = defaultdict(list)
    for rt_strength,retweets in rt_bonding_edges.iteritems():             
            for retweet in retweets:
                value = None
                try:
                    if reverse:
                        value = at_bonding_edges[retweet[1]][retweet[0]] # Reverse                        
                        del at_bonding_edges[retweet[1]][retweet[0]] # delete that entry reverse
                    else:
                        value = at_bonding_edges[retweet[0]][retweet[1]] #Same direction
                        del at_bonding_edges[retweet[0]][retweet[1]] # delete that entry same direction                                       
                except:
                    ""                    
                if value == None:  #If the AT Network led to no diffusion ONLY then check the FF network
                    try:
                        if reverse:
                            value = ff_bonding_edges[retweet[1]][retweet[0]] # Reverse                        
                            del ff_bonding_edges[retweet[1]][retweet[0]] # delete that entry reverse
                        else:                                
                            value = ff_bonding_edges[retweet[0]][retweet[1]] #Same direction
                            del ff_bonding_edges[retweet[0]][retweet[1]] # delete that entry same direction                                            
                    except:
                        ""
                if value == None: # A retweet happend despite there being no ties at all                                        
                    value = "no_tie"
                bonding_flow[value].append(rt_strength)
    
    bonding_no_flow = {}
    
    #Count the AT ties that led to no diffusion
    for k,v1 in at_bonding_edges.iteritems():
            for k,value in v1.iteritems():
                if bonding_no_flow.has_key(value):
                    bonding_no_flow[value] += 1
                else:
                    bonding_no_flow[value] = 0
    
    #Count the FF ties that led to no diffusion
    for k,v1 in ff_bonding_edges.iteritems():
        for k,value in v1.iteritems():
            if bonding_no_flow.has_key(value):
                bonding_no_flow[value] += 1
            else:
                bonding_no_flow[value] = 0
    
    ##################BRIDGING: Influence of AT strenghts on bridging retweets ##############################
    
    bridging_flow = defaultdict(list)
    for rt_strength,retweets in rt_bridging_edges.iteritems():             
            for retweet in retweets:
                value = None
                try:
                    if reverse:
                        value = at_bridging_edges[retweet[1]][retweet[0]] #reverse
                        del at_bridging_edges[retweet[1]][retweet[0]] # delete that entry reverse
                    else:
                        value = at_bridging_edges[retweet[0]][retweet[1]] #Same direction
                        del at_bridging_edges[retweet[0]][retweet[1]] # delete that entry same direction                    
                except:
                    ""
                if value == None:  #If the AT Network led to no diffusion ONLY then check the FF network                
                    try:
                        if reverse:
                            value = ff_bridging_edges[retweet[1]][retweet[0]] # Reverse                        
                            del ff_bridging_edges[retweet[1]][retweet[0]] # delete that entry reverse
                        else:                                
                            value = ff_bridging_edges[retweet[0]][retweet[1]] #Same direction
                            del ff_bridging_edges[retweet[0]][retweet[1]] # delete that entry same direction                                            
                    except:
                        ""
                if value == None: # A retweet happend despite there being no ties at all
                    value = "no_tie"
                bridging_flow[value].append(rt_strength)
                    
    bridging_no_flow = {}
    
    #Count the AT ties that led to no diffusion
    for k,v1 in at_bridging_edges.iteritems():
            for k,value in v1.iteritems():
                if bridging_no_flow.has_key(value):
                    bridging_no_flow[value] += 1
                else:
                    bridging_no_flow[value] = 0
    
    #Count the FF ties that led to no diffusion
    for k,v1 in ff_bridging_edges.iteritems():
        for k,value in v1.iteritems():
            if bridging_no_flow.has_key(value):
                bridging_no_flow[value] += 1
            else:
                bridging_no_flow[value] = 0

    ###########################  Output ###########################
    
    bridging_csv_writer.writerow(["bridging_at_strength","bridging_retweets", "bridging_no_retweets", "bridging_retweets/no_retweets", "average","std"])
    bonding_csv_writer.writerow(["bonding_at_strength","bonding_retweets", "bonding_no_retweets", "bonding_retweets/no_retweets", "average", "std"])

    bridging_tie_strengths = []
    bridging_rt_ratios = []
    bridging_stds = []
    
    bonding_tie_strengths = []
    bonding_rt_ratios = []
    bonding_stds = []
    
    #BRIDGING TIES
    for k,v in bridging_flow.iteritems():        
        if bridging_no_flow.has_key(k) and bridging_no_flow[k] != 0 and len(bridging_flow[k]) > 5:                        
            ratio = sum(bridging_flow[k])/bridging_no_flow[k]            
            std = np.std(bridging_flow[k])
            average = np.average(bridging_flow[k])
            if is_number(k):
                bridging_tie_strengths.append(k)
                bridging_rt_ratios.append(ratio)
                bridging_stds.append(std)                    
            bridging_csv_writer.writerow([k,sum(bridging_flow[k]),bridging_no_flow[k],ratio,average,std])
        if k == "no_tie":
            std = np.std(bridging_flow[k])
            bridging_csv_writer.writerow([k,sum(bridging_flow[k]),0,0,0,std])
    
    #BONDING TIES
    for k,v in bonding_flow.iteritems():    
        if bonding_no_flow.has_key(k) and bonding_no_flow[k] != 0 and len(bonding_flow[k]) > 5:
            ratio = sum(bonding_flow[k])/bonding_no_flow[k]   
            std = np.std(bonding_flow[k])
            average = np.average(bonding_flow[k])
            if is_number(k):
                bonding_tie_strengths.append(k)
                bonding_rt_ratios.append(ratio)
                bonding_stds.append(std)  
            bonding_csv_writer.writerow([k,sum(bonding_flow[k]),bonding_no_flow[k],ratio,average,std])
        if k == "no_tie":
            std = np.std(bonding_flow[k])
            bonding_csv_writer.writerow([k,sum(bonding_flow[k]),0,0,0,std])
      
    
    #Plot Errorplots
    fig = plt.figure(figsize=(42.67, 32.0))
    plt.errorbar(bridging_tie_strengths, bridging_rt_ratios, bridging_stds,ls="-",color="g", label='Bridging RT/No_RT percentage through ties with strength x')
    plt.errorbar(bonding_tie_strengths, bonding_rt_ratios, bonding_stds,ls="-",color="b", label='Bonding RT/No_RT percentage through ties with strength x')
    plt.ylim([0,40])
    plt.axhline(1,color="r")
    plt.legend()
    if reverse:
        plt.savefig("results/errorplot_reverse_valued_edges.png")
    else:
        plt.savefig("results/errorplot_valued_edges.png")       
    plt.close()

if __name__ == "__main__":
   main(sys.argv[1:])