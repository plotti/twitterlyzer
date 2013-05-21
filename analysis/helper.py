import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plot
import csv
import numpy as np
from itertools import groupby
import networkx as nx

		
# The min_threshold returns the highest possible weight threshold to filter out the graph but to remain one component
def min_threshold(G):
    max_weights = []
    for node in G.nodes():
	local_max = 0
	for edge in G[node].values():        
	    if edge["weight"] > local_max:
		local_max = edge["weight"]
	max_weights.append(local_max)
    return min(max_weights)

#Island method for filtering edges
def trim_edges(g, weight=1):
	g2=nx.DiGraph()
	for f, to, edata in g.edges(data=True):
		if edata['weight'] > weight:
			g2.add_edge(f,to,edata)
	return g2


def uniq(seq): 
	# order preserving
	checked = []
	for e in seq:
		if e not in checked:
			checked.append(e)
	return checked

# It matches two different dictionarys or networks and returns the nodes that are present in both
def match_values(dict1,dict2):
    sample = []
    for key, value in dict1.iteritems():
        if dict2.has_key(key):
            sample.append([dict2[key],dict1[key]])
    sample_np = np.array(sample).T # Make it a matrix of two vectors for input e.g. [[x1,x2,x3],[y1,y2,y3]] ## T is for transpose
    return sample_np

#Get the partition from a partition file
# It looks like [[m1,m2,m3],[m4,m5,m6]]
def get_partition(name):
	partition = []
	reader = csv.reader(open(name, "rb"), delimiter=",")
	temp  = []
	for row in reader:
		temp.append([row[0],row[1]])
		
	#Sort the list according to category
	temp = sorted(temp, key=lambda x: x[1])
	groups = uniq(map(lambda x: x[1],temp))

	for key, group in groupby(temp, lambda x: x[1]):
		g = []
		for thing in group:
			g.append(thing[0])	
		partition.append(g)
	return [partition,groups]		

# Draw a network graph
def draw_graph(D):
	D = D.to_undirected()
	plot.figure(figsize=(16,16))
	nx.draw_spring(D,
			node_color=[float(D.degree(v)) for v in D],
			#edge_color=[np.log(D[e1][e2]["weight"]+1) for e1,e2 in D.edges()],
			width=3,
			edge_cmap=plot.cm.Reds,			
			with_labels=True,
			cmap=plot.cm.Reds,
			node_size=1000,
			font_size=8,
			iterations=100000)
	plot.title("Spring Network Layout of %s" % D.name)
	plot.savefig("results/network_graphs/%s.png" % D.name)
	plot.close()
	
# Draws a histrogram of tie strength distributions
def draw_histogram(values,D):
	plot.hist(values,100)
	plot.xlabel("%s strength" % D.name)
	plot.ylabel("probability")
	plot.title("Histogram of %s distribution" % D.name)
	plot.savefig('results/histograms/%s.png' % D.name)
	plot.close()

# Calculates the total weight on the edges of the graph
# The edges are in both directions
def total_edge_weight(D):
	total = 0
	values = []
	for edge in D.edges(data=True):
		total += edge[2]["weight"]
		values.append(edge[2]["weight"])
	#draw_histogram(values,D)
	return total

# Total weight of edges / nodes
def average_tie_strength(D):
	return float(total_edge_weight(D))/(len(D.nodes())*(len(D.nodes())-1))

# Adds up all the incoming ties from a number of groups for an individual node
def incoming_group_volume(G,node,groups):
	total = {}
	for group in groups:
		total[group] = 0
		
	for edge in G.in_edges(node,data=True):		
		for group in groups:
			if G.node[edge[0]]['group'] == group:
				total[group] += 1	
	return total

# Adds up all the outgoing ties to a number of groups for an individual node
def outgoing_group_volume(G,node,groups):
	total = {}
	for group in groups:
		total[group] = 0
		
	for edge in G.out_edges(node,data=True):		
		for group in groups:
			if G.node[edge[1]]['group'] == group:
				total[group] += 1	
	return total

#Filters an array so that only the ties with a certain total strength towards a group are added up
def filtered_group_volume(group_values, threshold):
	result = 0
        for k,v in group_values.items():
		if v > threshold:
			result += 1
	return result

#def incoming_group_volume(G, groups):
#	total = []
#	for group in groups:
#		total.append(individual_in_volume(G,group))
#	return total
#
#def outgoing_group_volume(G, groups):
#	total = []
#	for group in groups:
#		total.append(individual_out_volume(G,group))
#	return total

#Computes the volume of incoming ties according to some group
#The ties are only counted if they come fromn a member of the named group
def individual_in_volume(D,group):
	output = {}
	for node in D.nodes_iter():
		weights = 0
		for edge in D.in_edges(node,data=True):
			if D.node[edge[0]]['group'] == group:
				weights+=edge[2]['weight']
		output[node] = weights
	return output

#Computes the volume of outgoing ties according to some group
#The ties are only counted if they go to a member of the named group
def individual_out_volume(D,group):
	output = {}
	for node in D.nodes():
		weights = 0
		for edge in D.out_edges(node,data=True):			
			if D.node[edge[1]]['group'] == group:
				weights+=edge[2]['weight']
		output[node] = weights
	return output

# Calculates the average tie strength for each person in the graph
def individual_average_tie_strength(D,node=None):
	output = {}
	if node == None:
		nodes = D.nodes()
	else:
		nodes = [node]
	for node in nodes:
		weights = D.in_degree(node,weight="weight") + D.out_degree(node,weight="weight")
		total_edges = len(D.in_edges(node)+D.out_edges(node))
		if  total_edges != 0:
			avg_weight = float(weights) / total_edges
		else:
			avg_weight = 0
		output[node] = avg_weight	
	return output

#Calculates how many ties of an individual are reciprocated
def individual_reciprocity(D,node=None):
	output = {}
	if node == None:
		nodes = D.nodes()
	else:
		nodes = [node]
	for node in nodes:
		reciprocated = 0
		unreciprocated = 0
		for (u,v) in D.in_edges(node):
			if D.has_edge(v,u):
				reciprocated += 1
		total_edges = float(len(D.in_edges(node)+D.out_edges(node))-reciprocated)
		if total_edges != 0:
			output[node] = reciprocated / total_edges
		else:
			output[node] = 0
	return output
	
# Calculates the overal reciprocity in a graph
# Is this my own algorithm or is it based on some considerations from theoretical literature?
#http://en.wikipedia.org/wiki/Reciprocity_in_network
def reciprocity(D):
	G = reciprocated_graph(D)
	return float(len(G.edges()))/len(D.edges())

def reciprocated_graph(D):
	G=D.to_undirected() # copy 
	for (u,v) in D.edges(): 
		if not D.has_edge(v,u): 
			G.remove_edge(u,v)
	G.remove_nodes_from(nx.isolates(G))
	return G

def to_binary(D):
	G = D.copy()
	for edge in G.edges(data=True):
		edge[2]["weight"] = 1
	return G

def create_example_network():
	G = nx.DiGraph()
	G.name = "Test Network"
	G.add_nodes_from(["a1","a2","a3","a4","a5","a6","a7","a8","b1","b2","b3","b4","b5","b6","b7","b8","c1","c2","c3","c4","c5","c6","c7","c8","d1","d2","d3","d4","d5","d6","d7","d8"])
	#As
	G.add_edges_from([
		("a1","a2",{'weight':2}),
		("a1","a3",{'weight':2}),
		("a1","a4",{'weight':1}),
		("a2","a4",{'weight':2}),
		("a2","a3",{'weight':1}),
		("a2","a7",{'weight':1}),
		("a2","a8",{'weight':1}),
		("a2","a1",{'weight':1}),
		("a4","a6",{'weight':1}),
		("a3","a5",{'weight':1}),
		("a3","b5",{'weight':1}),
		("a3","b4",{'weight':1}),
		("a5","a3",{'weight':1}),
		("a8","a2",{'weight':1})
		])
	#Bs
	G.add_edges_from([
		("b1","b2",{'weight':2}),
		("b1","b3",{'weight':2}),
		("b1","b4",{'weight':2}),
		("b1","b5",{'weight':2}),
		("b1","b6",{'weight':2}),
		("b1","b7",{'weight':2}),
		("b2","b3",{'weight':2}),
		("b2","b4",{'weight':2}),
		("b2","b6",{'weight':2}),
		("b2","b7",{'weight':2}),
		("b3","b4",{'weight':2}),
		("b3","b2",{'weight':2}),
		("b3","b5",{'weight':2}),
		("b3","b5",{'weight':2}),
		("b3","b7",{'weight':1}),
		("b4","b5",{'weight':2}),
		("b4","b6",{'weight':1}),
		("b5","b8",{'weight':1}),
		("b6","b7",{'weight':2}),
		("b6","b1",{'weight':2}),
		("b6","c1",{'weight':2}),
		("b7","d2",{'weight':1}),
		("b7","b6",{'weight':1})
	])
	#Cs
	G.add_edges_from([
		("c1","c2",{'weight':1}),
		("c1","c4",{'weight':2}),
		("c1","c5",{'weight':1}),
		("c2","c4",{'weight':1}),
		("c2","c5",{'weight':1}),
		("c2","c7",{'weight':1}),
		("c2","c8",{'weight':1}),
		("c3","c4",{'weight':1}),
		("c3","c5",{'weight':1}),
		("c3","c6",{'weight':1}),
		("c3","c7",{'weight':1}),
		("c5","c2",{'weight':1}),
		("c7","c3",{'weight':1})
	])
	#Ds
	G.add_edges_from([
		("d1","d2",{'weight':2}),
		("d1","d3",{'weight':2}),
		("d1","d4",{'weight':1}),
		("d2","d3",{'weight':1}),
		("d2","d4",{'weight':1}),
		("d2","d8",{'weight':1}),
		("d2","d1",{'weight':2}),
		("d3","d5",{'weight':1}),
		("d3","d8",{'weight':1}),
		("d4","d7",{'weight':1}),
		("d5","d6",{'weight':1}),
		("d5","d7",{'weight':1}),
		("d7","d8",{'weight':1}),
		("c2","d1",{'weight':1}),
		("c4","d3",{'weight':1}),
		("d2","b7",{'weight':1})
	])	
	return G

def create_example_partitions():
	return[["a1","a2","a3","a4","a5","a6","a7","a8"],["b1","b2","b3","b4","b5","b6","b7","b8"],["c1","c2","c3","c4","c5","c6","c7","c8"],["d1","d2","d3","d4","d5","d6","d7","d8"]]

def create_groups():
	return["a","b","c","d"]