import networkx as nx

def match_values(dict1,dict2):
    sample = []
    for key, value in dict1.iteritems():
        if dict2.has_key(key):
            sample.append([dict2[key],dict1[key]])
    sample_np = np.array(sample).T # Make it a matrix of two vectors for input e.g. [[x1,x2,x3],[y1,y2,y3]] ## T is for transpose
    return sample_np

for project in projects:
    
    #Read in Networks
    AT = nx.read_edgelist('%s_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
    RT = nx.read_edgelist('%s_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
    FF = nx.read_edgelist('%s_AT.edgelist' % project_name1, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 

    
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
    
    
    #Compute Information Diffusion
    dRT_in = nx.in_degree_centrality(RT) # Retweets that a person has received
    dRT_out = nx.out_degree_centrality(RT) # Retweets that a person has made
    
    #Compute Hypotheses
    
    #a: AT OUT is correlated to RT IN (The more often I adress people the more I get retweeted)
    values = match_values(dAT_out,dRT_in)
    output = sp.pearsonr(values[0],values[1])
    print "AT OUT is correlated to RT IN with: %f and p (%f) " % (output[0],output[1])
    
    #b: AT IN is correlated to RT IN (The more often I get adressed by people the more I get retweeted)
    values = match_values(dAT_in,dRT_in)
    output = sp.pearsonr(values[0],values[1])
    print "AT IN is correlated to RT IN with: %s and p: %f" % (output[0],output[1])

    #c: AT Closeness is correlated to RT IN (The closer I am to everybody else in the network the more often I am retweeted)
    values = match_values(dAT_closeness,dRT_in)
    output = sp.pearsonr(values[0],values[1])
    print "AT Closeness is correlated to RT IN with: %s and p: %f" % (output[0],output[1])

    #d: Pagerank is correlated to RT IN (The higher my pagerank in the network the more often I am retweeted)
    values = match_values(dAT_pagerank,dRT_in)
    output = sp.pearsonr(values[0],values[1])
    print "AT Pagerank is correlated to RT IN with: %s and p: %f" % (output[0],output[1])