import networkx as nx
import csv
import helper as hp

csv_writer = csv.writer(open('results/spss/whole network/whole_network.csv', 'wb'))
csv_writer.writerow(["FF_assortativity","AT_assortativity","RT_assortativity"])

# Read in the partition
tmp = hp.get_partition()
partitions = tmp[0]
groups = tmp[1]

# Read in the networks
project = "584"
FF_all = nx.read_edgelist('data/networks/%s_FF.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
AT_all = nx.read_edgelist('data/networks/%s_AT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph()) 
RT_all = nx.read_edgelist('data/networks/%s_RT.edgelist' % project, nodetype=str, data=(('weight',float),),create_using=nx.DiGraph())

# Add dummy nodes if they are missing in the networks
i = 0
for partition in partitions:
    for node in partition:
        FF_all.add_node(node, group =  groups[i])
        AT_all.add_node(node, group =  groups[i])
        RT_all.add_node(node, group =  groups[i])
    i += 1


# Compute Assortativity in Friendships
aFF = nx.attribute_assortativity_coefficient(FF_all,'group')
aAT = nx.attribute_assortativity_coefficient(AT_all,'group')
aRT = nx.attribute_assortativity_coefficient(RT_all,'group')

# Output
csv_writer.writerow([aFF,aAT,aRT])


## TODO Compute the average between ties that are inside the group and ties that are between groups
