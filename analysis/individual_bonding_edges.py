import networkx as nx
import math as math
import numpy as np
import matplotlib.pyplot as plt

project = "584"
    
AT = nx.read_edgelist('data/networks/%s_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
RT = nx.read_edgelist('data/networks/%s_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())

#How much information do the ties carry according to their strength
result = []

# Some tie strengths
thresholds = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
for threshold in thresholds:   
    at_edges = []
    for n,nbrs in AT.adjacency_iter():
        for nbr,eattr in nbrs.items():
            data=eattr['weight'] 
            if data==threshold: #if the ties have a specific strength
                at_edges.append((n,nbr,data)) # create a tuple of from_node,to_node,strength
    
    rt_edges = []
    for edge in at_edges:
        try:
            value = RT[edge[0]][edge[1]]['weight'] #if I can find this same pair of nodes in the RT graph capture how many retweets have been exchanged here.
        except KeyError:
            value = 0
        if value > 0:
            rt_edges.append((edge[0],edge[1],value))    #if retweets have been exchanged between those actors add them to the rt edges
    result.append([len(at_edges), math.fsum([x[2] for x in rt_edges]),threshold]) # sum up over the retweets and save the result
    
    
#Get the "0" strong tie which is when a retweet happend although there is no at_tie (in either direction)
AT_undir = nx.Graph(AT) # We make it undirected to search for @replies in both directions
rt_0_edges = []
for n,nbrs in RT.adjacency_iter():
        for nbr,eattr in nbrs.items():
            data=eattr['weight']
            try:
                value = AT_undir[n][nbr]['weight']
            except KeyError:
                rt_0_edges.append((n,nbr,data))

#insert our results to the array as the first datapoints
result.insert(0,[0,math.fsum([x[2] for x in rt_0_edges]),0])
thresholds.insert(0,0) 
#percentages = np.array([rt[1] for rt in result],dtype="float32")/np.array([at[0] for at in result]) # convert it to floats for division

#Plot it
fig = plt.figure()
ax1 = fig.add_subplot(111)
ax1.plot(thresholds, [at[0] for at in result],'b-', label='# of AT ties with strength x')
ax1.plot(thresholds, [at[1] for at in result], 'g-', label='# of retweets flowing through these ties')
ax1.legend(loc=2)
#ax2 = ax1.twinx()
#ax2.plot(thresholds, percentages, 'r-', label='% of #RT/#AT')
#ax2.legend()
plt.savefig("results/individual_edges.png")
plt.close()