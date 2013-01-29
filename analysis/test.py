import os
import csv
import helper as hp
import networkx as nx
THRESHOLD = 0.01

#Create Test network and dump it to drive
T = hp.create_example_network()
# The RT/FF/AT Networks are the same. Optimally we should also have slightly different ones
nx.write_weighted_edgelist(T, "data/networks/test_FF.edgelist")
nx.write_weighted_edgelist(T, "data/networks/test_solr_AT.edgelist")
nx.write_weighted_edgelist(T, "data/networks/test_solr_RT.edgelist")

#Provide parameters for the test
partition = "data/partitions/test_partition.csv"
project = "test"

############## Group Bonding Test ##############

cmd = 'python group_bonding.py -p %s -s %s' % (project, partition)
os.system(cmd)
results = {}
indiv_reader = csv.reader(open("results/spss/group bonding/test_group_bonding.csv"))
header = indiv_reader.next()
for row in indiv_reader:        
    results[row[1]] = {"FF_bin_density":float(row[header.index("FF_bin_density")]),
                       "AT_density":float(row[header.index("AT_density")]),
                       "FF_bin_avg_path_length": float(row[header.index("FF_bin_avg_path_length")]),
                       "FF_bin_clustering": float(row[header.index("FF_bin_clustering")]),
                       "FF_reciprocity": float(row[header.index("FF_reciprocity")]),
                       "FF_bin_transitivity": float(row[header.index("FF_bin_transitivity")]),
                       "RT_total_volume":float(row[header.index("RT_total_volume")])}    

delta = abs(results["a"]["FF_bin_density"] - 0.214) # 12 / (8.0 x 7)
if  delta > THRESHOLD: print "DANGER: FF_bin_density group a is %s off" % delta # Density is computed in UCINET on the binarized version of A (A_GT_0)

delta = abs(results["a"]["AT_density"] - 0.268) # Average tie strength = density in weighted networks in UCINET
if  delta > THRESHOLD: print "DANGER: AT_density in group a is %s off" % delta # In UCINET: Total of all values divided by the number of possible ties

delta = abs(results["a"]["FF_bin_avg_path_length"] - 1.583*24/(8*7)) # UCINET Reports average shortest path differntly #24 = number of geodesic distances # 8*7 = n*(n-1)
if  delta > THRESHOLD: print "DANGER: FF_bin_avg_path_length path length in group a is %s off" % delta

delta = abs(results["a"]["FF_bin_clustering"] - 0.383) # Clustering is computed on an undirected and then binarized graph 
# Additionally networkx does count the zeros in default, which we turned off (UCINET--> A-Sym-max-GT-0 network)
if  delta > THRESHOLD: print "DANGER: FF_bin_clustering of group a is %s off" % delta

delta = abs(results["a"]["FF_reciprocity"] - 0.333) #UCINET reciprocity on A_GT0 
if  delta > THRESHOLD: print "DANGER: FF_reciprocity of group a is %s off" % delta

delta = abs(results["a"]["FF_bin_transitivity"] - 0.316) # This is the result of weighted clustering coefficient in UCINET
if  delta > THRESHOLD: print "DANGER: FF_bin_transitivity of group a is %s off" % delta

delta = abs(results["a"]["RT_total_volume"] - 15) # Own computation
if  delta > THRESHOLD: print "DANGER: RT_total_volume volume of group a is %s off" % delta

############## Group Bridging Test ##############

cmd = 'python group_bridging.py -p %s -s %s' % (project, partition)
os.system(cmd)
results = {}
indiv_reader = csv.reader(open("results/spss/group bridging/test_group_bridging.csv"))
header = indiv_reader.next()
for row in indiv_reader:        
    results[row[1]] = {"FF_bin_degree":float(row[header.index("FF_bin_degree")]),
                       "FF_bin_in_degree":float(row[header.index("FF_bin_in_degree")]),
                       "FF_bin_out_degree": float(row[header.index("FF_bin_out_degree")]),
                       "FF_bin_betweeness": float(row[header.index("FF_bin_betweeness")]),
                       "FF_bin_closeness": float(row[header.index("FF_bin_closeness")]),
                       "FF_bin_pagerank": float(row[header.index("FF_bin_pagerank")]),
                       "FF_bin_c_size":float(row[header.index("FF_bin_c_size")]),
                       "FF_bin_c_density":float(row[header.index("FF_bin_c_density")]),
                       "FF_bin_c_hierarchy":float(row[header.index("FF_bin_c_hierarchy")]),
                       "FF_bin_c_index":float(row[header.index("FF_bin_c_index")])}
    
delta = abs(results["a"]["FF_bin_degree"] - 0.333) # UCINET Degree Centrality Symetrized
if  delta > THRESHOLD: print "DANGER: FF_bin_degree of group a is %s off" % delta

delta = abs(results["a"]["FF_bin_in_degree"] - 0) # UCINET In Degree Centrality non-symetrized
if  delta > THRESHOLD: print "DANGER: FF_bin_in_degree Centrality of group a is %s off" % delta

delta = abs(results["a"]["FF_bin_out_degree"] - 0.333) # UCINET Out Degree Centrality non-symetrized
if  delta > THRESHOLD: print "DANGER: FF_bin_out_degree Centrality of group a is %s off" % delta

delta = abs(results["b"]["FF_bin_betweeness"] - 0.5) # UCINET Normalized Betweeness centrality
if  delta > THRESHOLD: print "DANGER: FF_bin_betweeness Centrality of group b is %s off" % delta

delta = abs(results["b"]["FF_bin_closeness"] - 1.0) # UCINET closeness computed on dichotimized then symetrized #It seems to be normalized
# UCINET reports 1.0 but networkx counts 
if  delta > THRESHOLD: print "DANGER: FF_bin_closeness Centrality of group b is %s off" % delta

delta = abs(results["b"]["FF_bin_pagerank"] - 140.302) # UCINET Eigenvector computed on symetrized (max)
if  delta > THRESHOLD: print "DANGER: FF_bin_pagerank centrality of group b is %s off" % delta

delta = abs(results["b"]["FF_bin_c_size"] - 2.333) # Effecive Size
if  delta > THRESHOLD: print "DANGER: FF_bin_c_size Size of group b is %s off" % delta

delta = abs(results["b"]["FF_bin_c_density"] - 0.778) # Density
if  delta > THRESHOLD: print "DANGER: FF_bin_c_density of group b is %s off" % delta

delta = abs(results["b"]["FF_bin_c_hierarchy"] - 0.052) # Hierarchy
if  delta > THRESHOLD: print "DANGER: FF_bin_c_hierarchy of group b is %s off" % delta

############## Individual bonding Tests ##############

cmd = 'python individual_bonding.py -p %s -s %s' % (project, partition)
os.system(cmd)
results = {}
indiv_reader = csv.reader(open("results/spss/individual bonding/test_individual_bonding.csv"))
header = indiv_reader.next()
for row in indiv_reader:        
    results[row[2]] = {"FF_bin_deg":float(row[header.index("FF_bin_deg")]),
                       "FF_bin_in_deg":float(row[header.index("FF_bin_in_deg")]),
                       "FF_bin_out_deg": float(row[header.index("FF_bin_out_deg")]),
                       "FF_bin_close": float(row[header.index("FF_bin_close")]),
                       "FF_bin_page": float(row[header.index("FF_bin_page")]),
                       "FF_rec": float(row[header.index("FF_rec")]),
                       "AT_avg":float(row[header.index("AT_avg")]),
                       "AT_vol_in": float(row[header.index("AT_vol_in")]),
                       "AT_vol_out": float(row[header.index("AT_vol_out")])}

delta = abs(results["a2"]["FF_bin_deg"] -7.0 / 7)  # Due to the binarized nature weighted degrees are not computed therfore the indegree of 3.0 becomes 2.0 and 6.0 becomes 5.0
if  delta > THRESHOLD: print "DANGER: FF_bin_deg Centrality a2 is %s off" % delta # UCI Net doesnt norm it by n-1

delta = abs(results["a2"]["FF_bin_in_deg"] - 2.0 / 7)
if  delta > THRESHOLD: print "DANGER: FF_bin_in_deg Degree Centrality a2 is %s off" % delta

delta = abs(results["a2"]["FF_bin_out_deg"] - 5.0 / 7)
if  delta > THRESHOLD: print "DANGER: FF_bin_out_deg Degree Centrality a2 is %s off" % delta

delta = abs(results["a2"]["FF_bin_close"] - 0.777) # For networkx a2: (1 / 9.0 ) * 7 // 9 = 1+1+1+2+2+1+1 (which are shortest a1-a8 distances)
if  delta > THRESHOLD: print "DANGER: FF_bin_close Centrality a2 is %s off" % delta # Closeness centrality computed on dichotimized (2-->1) then symetrized (min) data A-sym --> which is then automatically binarized by UCINET

# How is the eigenvector centrality normalized in ucinet
delta = abs(results["a2"]["FF_bin_page"] - 0.58 / 7)  
if  delta > THRESHOLD: print "DANGER: FF_bin_page Centrality a2 is %s off" % delta # Eigenvector in UCINET symetrized

delta = abs(results["a2"]["FF_rec"] - 0.4 )
if  delta > THRESHOLD: print "DANGER: FF_rec of a2 is %s off" % delta

delta = abs(results["a2"]["AT_avg"] - 9.0 / 7)
if  delta > THRESHOLD: print "DANGER: AT_avg Tie strength of a2 is %s off" % delta # A total value of 9 with 7 ties (Own computation)

delta = abs(results["a2"]["AT_vol_in"] - 3.0 )
if  delta > THRESHOLD: print "DANGER: AT_vol_in of a2 is %s off" % delta

delta = abs(results["a2"]["AT_vol_out"] - 6.0 )
if  delta > THRESHOLD: print "DANGER: AT_vol_out of a2 is %s off" % delta

#TODO Eventually compute individual clustering for each actor

############## Individual Bridging Test (Pairs of communities) ##############

#cmd = 'python individual_bridging.py -p %s -s %s' % (project, partition)
#os.system(cmd)
#results = {}
#indiv_reader = csv.reader(open("results/spss/individual bridging/test_individual_bridging.csv"))
#indiv_reader.next()
#for row in indiv_reader:
#    key = "%s%s%s" % (row[0],row[1],row[2]) #e.g. b7bd <--> b2's role in the pair group b and d
#    results[key] = {"tie_number":float(row[3]),"competing_lists":float(row[4]), "betweeness_centrality": float(row[8]),
#                       "own_group_indegree": float(row[9]),"other_group_indegree": float(row[10]), 
#                       "own_group_outdegree":float(row[11]),"other_group_outdegree": float(row[12])}
#    #STRUCTURAL HOLES MEASURES ARE MISSING
#delta = abs(results["b7bd"]["tie_number"] - 2) # One incoming and one outgoing tie between group b and d
#if  delta > THRESHOLD: print "DANGER: Tie number b7bd is %s off" % delta    
#
#delta = abs(results["b7bd"]["competing_lists"] - 2) # b7 was listed for group b and d
#if  delta > THRESHOLD: print "DANGER: Competing lists b7bd is %s off" % delta
#
#delta = abs(results["b7bd"]["betweeness_centrality"] - 0.260) # Ucinet
#if  delta > THRESHOLD: print "DANGER: Betweeness Centrality b7bd is %s off" % delta
#
#delta = abs(results["b7bd"]["own_group_indegree"] - 7) # Own calculation
#if  delta > THRESHOLD: print "DANGER: Own Group Indegree b7bd is %s off" % delta
#
#delta = abs(results["b7bd"]["other_group_indegree"] - 1) # Own calculation
#if  delta > THRESHOLD: print "DANGER: Other Group Indegree b7bd is %s off" % delta
#
#delta = abs(results["b7bd"]["own_group_outdegree"] - 1) # Own calculation
#if  delta > THRESHOLD: print "DANGER: Own Group Outdegree b7bd is %s off" % delta
#
#delta = abs(results["b7bd"]["other_group_outdegree"] - 1) # Own calculation
#if  delta > THRESHOLD: print "DANGER: Other Group Outdegree b7bd is %s off" % delta

############## Individual Bridging 2 Test (Whole Network) ##############

cmd = 'python individual_bridging_3.py -p %s -s %s' % (project, partition)
os.system(cmd)
results = {}
indiv_reader = csv.reader(open("results/spss/individual bridging/test_individual_bridging_3.csv"))
header = indiv_reader.next()
for row in indiv_reader:        
    results[row[2]] = {"Competing_lists":float(row[header.index("Competing_lists")]),
                       "FF_bin_degree":float(row[header.index("FF_bin_degree")]),
                       "FF_bin_in_degree": float(row[header.index("FF_bin_in_degree")]),
                       "FF_bin_out_degree": float(row[header.index("FF_bin_out_degree")]),
                       "FF_vol_in": float(row[header.index("FF_vol_in")]),
                       "FF_vol_out": float(row[header.index("FF_vol_out")]),
                       "FF_groups_in": float(row[header.index("FF_groups_in")]),
                       "FF_groups_out": float(row[header.index("FF_groups_out")]),
                       "FF_rec":float(row[header.index("FF_rec")]),
                       "FF_bin_betweeness":float(row[header.index("FF_bin_betweeness")]),
                       "AT_strength_centrality_in": float(row[header.index("AT_strength_centrality_in")])}

delta = abs(results["a3"]["FF_bin_in_degree"] - 0) # 0 incoming ties from other groups
if  delta > THRESHOLD: print "DANGER: FF_bin_in_degree is %s off" % delta    

delta = abs(results["a3"]["FF_bin_out_degree"] - 2.0/24) # 2.0 outgoing ties and 24 remaining nodes
if  delta > THRESHOLD: print "DANGER: FF_bin_out_degree is %s off" % delta

delta = abs(results["a3"]["FF_vol_out"] - 2.0) # 2x1.0 outgoing ties 
if  delta > THRESHOLD: print "DANGER: FF_vol_out is %s off" % delta

delta = abs(results["b6"]["FF_vol_out"] - 2.0) # 1x2.0 outgoing ties 
if  delta > THRESHOLD: print "DANGER: FF_vol_out is %s off" % delta

delta = abs(results["c1"]["FF_vol_in"] - 2.0) # 1x2.0 ingoing ties 
if  delta > THRESHOLD: print "DANGER: FF_vol_in is %s off" % delta

delta = abs(results["b4"]["FF_groups_in"] - 1.0) # only group a is incocoming
if  delta > THRESHOLD: print "DANGER: FF_groups_in is %s off" % delta

delta = abs(results["b7"]["FF_groups_out"] - 1.0) # only pointing to group d
if  delta > THRESHOLD: print "DANGER: FF_groups_out is %s off" % delta

delta = abs(results["d2"]["FF_rec"] - 1.0) # d2 is the only one of d to have reciprocal relations to a group
if  delta > THRESHOLD: print "DANGER: FF_rec is %s off" % delta

delta = abs(results["c1"]["AT_strength_centrality_in"] - 2*4/7.0) # c1 has an incoming tie with strength 2 and b6 4 incoming ties
if  delta > THRESHOLD: print "DANGER: AT_strength_centrality_in is %s off" % delta
