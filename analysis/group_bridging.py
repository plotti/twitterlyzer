import networkx as nx
import csv

csv_writer = csv.writer(open('results/group_bridging.csv', 'wb'))

project = 4

    
FF = nx.read_edgelist('data/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
AT = nx.read_edgelist('data/%s_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())
RT = nx.read_edgelist('data/%s_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())


partition = [FF.nodes()[0:10],FF.nodes()[10:101]]
M = nx.blockmodel(FF,partition)

nx.write_pajek(M,"%s.net" % project)
