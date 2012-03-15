import networkx as nx

for project in projects:
    
    print ""
    print "############ Calculating Project %s ############### " % project
    print ""
    
    FF = nx.read_edgelist('data/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
    AT = nx.read_edgelist('data/%s_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
    RT = nx.read_edgelist('data/%s_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
    
    FF_density = nx.density(FF)
    AT_density = nx.density(AT)
    RT_density = nx.density(RT)

    csv_writer.writerow([project, FF_density, AT_density, RT_density])