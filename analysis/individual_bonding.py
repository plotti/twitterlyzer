import networkx as nx
import csv
import numpy as np
import scipy.stats as sp

csv_writer = csv.writer(open('results/individual_bonding.csv', 'wb'))

#Log 05.05 group 109, 110, 111 missing
projects1 = [4, 6, 9, 13, 17, 19, 21, 25, 27, 31, 33, 39, 44, 46, 48, 56, 62, 70, 72, 82, 86, 94, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108]
#Log 06.06 Adding more groups to the analysis
projects2 = [112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 123, 137, 141, 143, 145, 149, 153, 155, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 170, 171, 172, 174, 175, 176, 177, 178, 179, 180, 181, 187, 189, 207, 209, 211, 213, 217, 219, 221, 233, 245, 247, 251, 253, 255, 257, 259, 261, 263, 265, 271, 275, 279, 281, 285, 291, 293, 297, 303, 305, 307, 311, 315, 317, 319, 325, 327, 329, 333, 337, 339, 341, 351, 353, 355, 357, 359, 361, 365, 367, 369, 371, 373, 379, 385, 387, 389, 391, 395, 397, 399, 401, 403, 405, 407]
projects = projects1 + projects2

def match_values(dict1,dict2):
    sample = []
    for key, value in dict1.iteritems():
        if dict2.has_key(key):
            sample.append([dict2[key],dict1[key]])
    sample_np = np.array(sample).T # Make it a matrix of two vectors for input e.g. [[x1,x2,x3],[y1,y2,y3]] ## T is for transpose
    return sample_np

csv_writer.writerow(["id", "at_out_rt_in R^2", "p", "at_in_rt_in R^2", "p", "at_clos_rt_in R^2", "p", "at_pag_rt_in R^2", "p","ff_out_rt_in R^2", "p", "ff_in_rt_in R^2", "p", "ff_clos_rt_in R^2", "p", "ff_pag_rt_in R^2", "p" ])

for project in projects:
    
    #Read in Networks
    AT = nx.read_edgelist('data/%s_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
    RT = nx.read_edgelist('data/%s_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
    FF = nx.read_edgelist('data/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
    
    #Compute AT Centralities
    dAT = nx.degree_centrality(AT)
    dAT_in = nx.in_degree_centrality(AT)
    dAT_out = nx.out_degree_centrality(AT)
    dAT_closeness = nx.closeness_centrality(AT)
    #dAT_eigenvector = nx.eigenvector_centrality(AT.to_undirected()) fails to converge too often what to do?
    dAT_pagerank = nx.pagerank(AT)
    
    #Compute FF Centralities    
    dFF = nx.degree_centrality(FF)
    dFF_in = nx.in_degree_centrality(FF)  #People that follow me in the network
    dFF_out = nx.out_degree_centrality(FF) #People that I follow in the network
    dFF_closeness = nx.closeness_centrality(FF) 
    dFF_pagerank = nx.pagerank(FF)
    
    #Compute Information Diffusion
    dRT_in = nx.in_degree_centrality(RT) # Retweets that a person has received
    dRT_out = nx.out_degree_centrality(RT) # Retweets that a person has made
    
#Compute Pearson AT <-> RT
    
    #AT OUT is correlated to RT IN (The more often I adress people the more I get retweeted)
    values = match_values(dAT_out,dRT_in)
    at_out_rt_in = sp.pearsonr(values[0],values[1])
    print "AT OUT is correlated to RT IN with: %f and p (%f) " % (at_out_rt_in[0],at_out_rt_in[1])
    
    #AT IN is correlated to RT IN (The more often I get adressed by people the more I get retweeted)
    values = match_values(dAT_in,dRT_in)
    at_in_rt_in = sp.pearsonr(values[0],values[1])
    print "AT IN is correlated to RT IN with: %s and p: %f" % (at_in_rt_in[0],at_in_rt_in[1])

    #AT Closeness is correlated to RT IN (The closer I am to everybody else in the network the more often I am retweeted)
    values = match_values(dAT_closeness,dRT_in)
    at_clo_rt_in = sp.pearsonr(values[0],values[1])
    print "AT Closeness is correlated to RT IN with: %s and p: %f" % (at_clo_rt_in[0],at_clo_rt_in[1])

    #Pagerank is correlated to RT IN (The higher my pagerank in the network the more often I am retweeted)
    values = match_values(dAT_pagerank,dRT_in)
    at_pag_rt_in = sp.pearsonr(values[0],values[1])
    print "AT Pagerank is correlated to RT IN with: %s and p: %f" % (at_pag_rt_in[0],at_pag_rt_in[1])

#Compute Pearson FF <-> RT

    #AT OUT is correlated to RT IN (The more often I adress people the more I get retweeted)
    values = match_values(dFF_out,dRT_in)
    ff_out_rt_in = sp.pearsonr(values[0],values[1])
    print "FF OUT is correlated to RT IN with: %f and p (%f) " % (ff_out_rt_in[0],ff_out_rt_in[1])
    
    #AT IN is correlated to RT IN (The more often I get adressed by people the more I get retweeted)
    values = match_values(dFF_in,dRT_in)
    ff_in_rt_in = sp.pearsonr(values[0],values[1])
    print "FF IN is correlated to RT IN with: %s and p: %f" % (ff_in_rt_in[0],ff_in_rt_in[1])

    #AT Closeness is correlated to RT IN (The closer I am to everybody else in the network the more often I am retweeted)
    values = match_values(dFF_closeness,dRT_in)
    ff_clo_rt_in = sp.pearsonr(values[0],values[1])
    print "FF Closeness is correlated to RT IN with: %s and p: %f" % (ff_clo_rt_in[0],ff_clo_rt_in[1])

    #d: Pagerank is correlated to RT IN (The higher my pagerank in the network the more often I am retweeted)
    values = match_values(dFF_pagerank,dRT_in)
    ff_pag_rt_in = sp.pearsonr(values[0],values[1])
    print "FF Pagerank is correlated to RT IN with: %s and p: %f" % (ff_pag_rt_in[0],ff_pag_rt_in[1])    

    #Write out everything to csv
    
    csv_writer.writerow([project, '%.3f'%at_out_rt_in[0], '%.3f'%at_out_rt_in[1], '%.3f'%at_in_rt_in[0], '%.3f'%at_in_rt_in[1], '%.3f'%at_clo_rt_in[0], '%.3f'%at_clo_rt_in[1], '%.3f'%at_pag_rt_in[0], '%.3f'%at_pag_rt_in[1], '%.3f'%ff_out_rt_in[0], '%.3f'%ff_out_rt_in[1], '%.3f'%ff_in_rt_in[0], '%.3f'%ff_in_rt_in[1], '%.3f'%ff_clo_rt_in[0], '%.3f'%ff_clo_rt_in[1], '%.3f'%ff_pag_rt_in[0], '%.3f'%ff_pag_rt_in[1]])
    
    