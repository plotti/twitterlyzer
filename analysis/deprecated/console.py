import helper as hp
import networkx as nx
G_all = hp.create_example_network()
partitions = hp.create_example_partitions()
names = ["a","b","c","d"]
FF = G_all.subgraph(partitions[0])
