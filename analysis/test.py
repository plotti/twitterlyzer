import os
import csv
import helper as hp
import networkx as nx
THRESHOLD = 0.01

#Create Test network and dump it to drive
T = hp.create_example_network()
# The RT/FF/AT Networks are the same. Optimally we should also have slightly different ones
nx.write_weighted_edgelist(T, "data/networks/test_FF.edgelist")
nx.write_weighted_edgelist(T, "data/networks/test_AT.edgelist")
nx.write_weighted_edgelist(T, "data/networks/test_RT.edgelist")

#Provide parameters for the test
partition = "data/partitions/test_partition.csv"
project = "test"

############## Group Bonding Test ##############

cmd = 'python group_bonding.py -p %s -s %s' % (project, partition)
os.system(cmd)
results = {}
indiv_reader = csv.reader(open("results/spss/group bonding/test_group_bonding.csv"))
indiv_reader.next()
for row in indiv_reader:        
    results[row[1]] = {"bin_density":float(row[6]),"density":float(row[7]), "avg_path_length": float(row[8]),
                       "clustering": float(row[10]),"reciprocity": float(row[12]), "transitivity": float(row[14]),
                       "total_volume":float(row[17])}    
delta = abs(results["a"]["bin_density"] - 0.214) # 12 / (8.0 x 7)
if  delta > THRESHOLD: print "DANGER: Binary Density group a is %s off" % delta # Density is computed in UCINET on the binarized version of A (A_GT_0)

delta = abs(results["a"]["density"] - 0.268) # Average tie strength = density in weighted networks in UCINET
if  delta > THRESHOLD: print "DANGER: Density in group a is %s off" % delta # In UCINET: Total of all values divided by the number of possible ties

delta = abs(results["a"]["avg_path_length"] - 1.583*24/(8*7)) # UCINET Reports average shortest path differntly #24 = number of geodesic distances # 8*7 = n*(n-1)
if  delta > THRESHOLD: print "DANGER: Average path length in group a is %s off" % delta

delta = abs(results["a"]["clustering"] - 0.383) # Clustering is computed on an undirected and then binarized graph 
# Additionally networkx does count the zeros in default, which we turned off (UCINET--> A-Sym-max-GT-0 network)
if  delta > THRESHOLD: print "DANGER: Clustering of group a is %s off" % delta

delta = abs(results["a"]["reciprocity"] - 0.333) #UCINET reciprocity on A_GT0 
if  delta > THRESHOLD: print "DANGER: Reciprocity of group a is %s off" % delta

delta = abs(results["a"]["transitivity"] - 0.316) # This is the result of weighted clustering coefficient in UCINET
if  delta > THRESHOLD: print "DANGER: Transitivity of group a is %s off" % delta

delta = abs(results["a"]["total_volume"] - 15) # Own computation
if  delta > THRESHOLD: print "DANGER: Total volume of group a is %s off" % delta

############## Group Bridging Test ##############

cmd = 'python group_bridging.py -p %s -s %s' % (project, partition)
os.system(cmd)
results = {}
indiv_reader = csv.reader(open("results/spss/group bridging/test_group_bridging.csv"))
indiv_reader.next()
for row in indiv_reader:        
    results[row[0]] = {"degree_centrality":float(row[2]),"in_degree_centrality":float(row[3]), "out_degree_centrality": float(row[4]),
                       "betweeness_centrality": float(row[5]),"closeness_centrality": float(row[6]), "eigenvector_centrality": float(row[7]),
                       "c_size":float(row[8]),"c_density":float(row[9]),"c_hierarch":float(row[10]),"c_index":float(row[11])}
delta = abs(results["a"]["degree_centrality"] - 0.333) # UCINET Degree Centrality Symetrized
if  delta > THRESHOLD: print "DANGER: Degree Centrality of group a is %s off" % delta

delta = abs(results["a"]["in_degree_centrality"] - 0) # UCINET In Degree Centrality non-symetrized
if  delta > THRESHOLD: print "DANGER: In Degree Centrality of group a is %s off" % delta

delta = abs(results["a"]["out_degree_centrality"] - 0.333) # UCINET Out Degree Centrality non-symetrized
if  delta > THRESHOLD: print "DANGER: Out Degree Centrality of group a is %s off" % delta

delta = abs(results["b"]["betweeness_centrality"] - 0.5) # UCINET Normalized Betweeness centrality
if  delta > THRESHOLD: print "DANGER: Betweeness Centrality of group b is %s off" % delta

delta = abs(results["b"]["closeness_centrality"] - 1.0) # UCINET closeness computed on dichotimized then symetrized #It seems to be normalized
# UCINET reports 1.0 but networkx counts 
if  delta > THRESHOLD: print "DANGER: Closeness Centrality of group b is %s off" % delta

delta = abs(results["b"]["eigenvector_centrality"] - 140.302) # UCINET Eigenvector computed on symetrized (max)
if  delta > THRESHOLD: print "DANGER: Eigenvector centrality of group b is %s off" % delta

delta = abs(results["b"]["c_size"] - 2.333) # Effecive Size
if  delta > THRESHOLD: print "DANGER: Effective Size of group b is %s off" % delta

delta = abs(results["b"]["c_density"] - 0.778) # Density
if  delta > THRESHOLD: print "DANGER: Density of group b is %s off" % delta

delta = abs(results["b"]["c_hierarch"] - 0.052) # Hierarchy
if  delta > THRESHOLD: print "DANGER: Hierarchy of group b is %s off" % delta

############## Individual bonding Tests ##############

cmd = 'python individual_bonding.py -p %s -s %s' % (project, partition)
os.system(cmd)
results = {}
indiv_reader = csv.reader(open("results/spss/individual bonding/test_individual_bonding.csv"))
indiv_reader.next()
for row in indiv_reader:        
    results[row[2]] = {"degree_centrality":float(row[4]),"in_degree_centrality":float(row[5]), "out_degree_centrality": float(row[6]),
                       "closeness_centrality": float(row[7]),"eigenvector_centrality": float(row[8]), "reciprocity": float(row[9]),
                       "average_tie_strength":float(row[16]),"volume_in": float(row[17]), "volume_out": float(row[18])}    
delta = abs(results["a2"]["degree_centrality"] -7.0 / 7)  # Due to the binarized nature weighted degrees are not computed therfore the indegree of 3.0 becomes 2.0 and 6.0 becomes 5.0
if  delta > THRESHOLD: print "DANGER: Degree Centrality a2 is %s off" % delta # UCI Net doesnt norm it by n-1

delta = abs(results["a2"]["in_degree_centrality"] - 2.0 / 7)
if  delta > THRESHOLD: print "DANGER: In Degree Centrality a2 is %s off" % delta

delta = abs(results["a2"]["out_degree_centrality"] - 5.0 / 7)
if  delta > THRESHOLD: print "DANGER: Out Degree Centrality a2 is %s off" % delta

delta = abs(results["a2"]["closeness_centrality"] - 0.777) # For networkx a2: (1 / 9.0 ) * 7 // 9 = 1+1+1+2+2+1+1 (which are shortest a1-a8 distances)
if  delta > THRESHOLD: print "DANGER: Closeness Centrality a2 is %s off" % delta # Closeness centrality computed on dichotimized (2-->1) then symetrized (min) data A-sym --> which is then automatically binarized by UCINET

# How is the eigenvector centrality normalized in ucinet
delta = abs(results["a2"]["eigenvector_centrality"] - 0.58 / 7)  
if  delta > THRESHOLD: print "DANGER: Eigenvector Centrality a2 is %s off" % delta # Eigenvector in UCINET symetrized

delta = abs(results["a2"]["reciprocity"] - 0.4 )
if  delta > THRESHOLD: print "DANGER: Reciprocity of a2 is %s off" % delta

delta = abs(results["a2"]["average_tie_strength"] - 9.0 / 7)
if  delta > THRESHOLD: print "DANGER: Average Tie strength of a2 is %s off" % delta # A total value of 9 with 7 ties (Own computation)

delta = abs(results["a2"]["volume_in"] - 3.0 )
if  delta > THRESHOLD: print "DANGER: Indegree of a2 is %s off" % delta

delta = abs(results["a2"]["volume_out"] - 6.0 )
if  delta > THRESHOLD: print "DANGER: Outdegree of a2 is %s off" % delta

#TODO Eventually compute individual clustering for each actor

############## Individual Bridging Test ##############

cmd = 'python individual_bridging.py -p %s -s %s' % (project, partition)
os.system(cmd)
results = {}
indiv_reader = csv.reader(open("results/spss/individual bridging/test_individual_bridging.csv"))
indiv_reader.next()
for row in indiv_reader:
    key = "%s%s%s" % (row[0],row[1],row[2]) #e.g. b7bd <--> b2's role in the pair group b and d
    results[key] = {"tie_number":float(row[3]),"competing_lists":float(row[4]), "betweeness_centrality": float(row[8]),
                       "own_group_indegree": float(row[9]),"other_group_indegree": float(row[10]), 
                       "own_group_outdegree":float(row[11]),"other_group_outdegree": float(row[12])}
    #STRUCTURAL HOLES MEASURES ARE MISSING
delta = abs(results["b7bd"]["tie_number"] - 2) # One incoming and one outgoing tie between group b and d
if  delta > THRESHOLD: print "DANGER: Tie number b7bd is %s off" % delta    

delta = abs(results["b7bd"]["competing_lists"] - 2) # b7 was listed for group b and d
if  delta > THRESHOLD: print "DANGER: Competing lists b7bd is %s off" % delta

delta = abs(results["b7bd"]["betweeness_centrality"] - 0.260) # Ucinet
if  delta > THRESHOLD: print "DANGER: Betweeness Centrality b7bd is %s off" % delta

delta = abs(results["b7bd"]["own_group_indegree"] - 7) # Own calculation
if  delta > THRESHOLD: print "DANGER: Own Group Indegree b7bd is %s off" % delta

delta = abs(results["b7bd"]["other_group_indegree"] - 1) # Own calculation
if  delta > THRESHOLD: print "DANGER: Other Group Indegree b7bd is %s off" % delta

delta = abs(results["b7bd"]["own_group_outdegree"] - 1) # Own calculation
if  delta > THRESHOLD: print "DANGER: Own Group Outdegree b7bd is %s off" % delta

delta = abs(results["b7bd"]["other_group_outdegree"] - 1) # Own calculation
if  delta > THRESHOLD: print "DANGER: Other Group Outdegree b7bd is %s off" % delta