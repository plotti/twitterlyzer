* Get the data *

GET DATA 
  /TYPE=TXT 
  /FILE="D:\Dropbox\phD\analysis\results\results\spss\multi-level\multi_level.csv" 
  /DELCASE=LINE 
  /DELIMITERS="," 
  /ARRANGEMENT=DELIMITED 
  /FIRSTCASE=2 
  /IMPORTCASE=ALL 
  /VARIABLES= 
  indiv_bonding_Project F3.0 
  indiv_bonding_Community A29 
  indiv_bonding_Person_ID A15 
  indiv_bonding_Place_on_list F3.0 
  indiv_bonding_FF_bin_deg F11.9 
  indiv_bonding_FF_bin_in_deg F11.9 
  indiv_bonding_FF_bin_out_deg F11.9 
  indiv_bonding_FF_vol_in F2.0 
  indiv_bonding_FF_vol_out F2.0 
  indiv_bonding_FF_bin_close F11.9 
  indiv_bonding_FF_bin_page F11.9 
  indiv_bonding_FF_rec F11.9 
  indiv_bonding_AT_bin_deg F11.9 
  indiv_bonding_AT_bin_in_deg F11.9 
  indiv_bonding_AT_bin_out_deg F11.9 
  indiv_bonding_AT_bin_close F11.9 
  indiv_bonding_AT_bin_page F11.9 
  indiv_bonding_AT_rec_A F11.9 
  indiv_bonding_AT_avg F11.9 
  indiv_bonding_AT_vol_in F4.0 
  indiv_bonding_AT_vol_out F3.0 
  indiv_bonding_RT_bin_deg_in F11.9 
  indiv_bonding_RT_bin_deg_out F11.9 
  indiv_bonding_RT_vol_in F3.0 
  indiv_bonding_RT_vol_out F3.0 
  indiv_bonding_RT_global_vol_in F3.0 
  indiv_bonding_RT_global_vol_out F3.0 
  indiv_bridging_Project F3.0 
  indiv_bridging_Community A29 
  indiv_bridging_Person_ID A15 
  indiv_bridging_Competing_lists F1.0 
  indiv_bridging_FF_bin_degree F11.9 
  indiv_bridging_FF_bin_in_degree F11.9 
  indiv_bridging_FF_bin_out_degree F11.9 
  indiv_bridging_FF_vol_in F4.0 
  indiv_bridging_FF_vol_out F4.0 
  indiv_bridging_FF_groups_in F3.0 
  indiv_bridging_FF_groups_out F3.0 
  indiv_bridging_FF_rec F11.9 
  indiv_bridging_AT_bin_degree F11.9 
  indiv_bridging_AT_bin_in_degree F11.9 
  indiv_bridging_AT_bin_out_degree F11.9 
  indiv_bridging_AT_vol_in F4.0 
  indiv_bridging_AT_vol_out F3.0 
  indiv_bridging_AT_groups_in F3.0 
  indiv_bridging_AT_groups_out F2.0 
  indiv_bridging_AT_rec F11.9 
  indiv_bridging_AT_strength_centrality_in F11.9 
  indiv_bridging_RT_bin_in_degree F11.9 
  indiv_bridging_RT_bin_out_degree F11.9 
  indiv_bridging_RT_vol_in F3.0 
  indiv_bridging_RT_vol_out F3.0 
  group_bonding_Name A29 
  group_bonding_Member_count F6.0 
  group_bonding_FF_Nodes F3.0 
  group_bonding_AT_Nodes F3.0 
  group_bonding_RT_Nodes F3.0 
  group_bonding_FF_bin_density F11.9 
  group_bonding_AT_density F11.9 
  group_bonding_FF_bin_avg_path_length F11.9 
  group_bonding_AT_bin_avg_path_length F11.9 
  group_bonding_FF_bin_clustering F11.9 
  group_bonding_AT_bin_clustering F11.9 
  group_bonding_FF_reciprocity F11.9 
  group_bonding_AT_reciprocity F11.9 
  group_bonding_FF_bin_transitivity F11.9 
  group_bonding_AT_bin_transitivity F11.9 
  group_bonding_RT_density F11.9 
  group_bonding_RT_total_volume F4.0 
  group_bridging_FF_bin_degree F11.9 
  group_bridging_FF_bin_in_degree F11.9 
  group_bridging_FF_bin_out_degree F11.9 
  group_bridging_FF_volume_in F5.0 
  group_bridging_FF_volume_out F5.0 
  group_bridging_FF_bin_betweeness F11.9 
  group_bridging_FF_bin_closeness F11.9 
  group_bridging_FF_bin_pagerank F11.9 
  group_bridging_FF_bin_c_size F11.9 
  group_bridging_FF_bin_c_density F11.9 
  group_bridging_FF_bin_c_hierarchy F11.9 
  group_bridging_FF_bin_c_index F11.9 
  group_bridging_AT_bin_degree F11.9 
  group_bridging_AT_bin_in_degree F11.9 
  group_bridging_AT_bin_out_degree F11.9 
  group_bridging_AT_bin_betweeness F11.9 
  group_bridging_AT_bin_closeness F11.9 
  group_bridging_AT_bin_pagerank F11.9 
  group_bridging_AT_bin_c_size F11.9 
  group_bridging_AT_bin_c_density F11.9 
  group_bridging_AT_bin_c_hierarchy F11.9 
  group_bridging_AT_bin_c_index F11.9 
  group_bridging_AT_volume_in F5.0 
  group_bridging_AT_volume_out F5.0 
  group_bridging_RT_volume_in F4.0  
  group_bridging_RT_volume_out F5.0. 
CACHE. 
EXECUTE. 

* Transform the problematic ones*

COMPUTE LN_group_bonding_AT_density=LN(group_bonding_AT_density+1).

COMPUTE LN_group_bridging_FF_volume_in=LN(group_bridging_FF_volume_in+1).
COMPUTE LN_group_bridging_AT_volume_in=LN(group_bridging_AT_volume_in+1).

COMPUTE LN_indiv_bridging_FF_vol_in=LN(indiv_bridging_FF_vol_in+1).
COMPUTE LN_indiv_bridging_AT_vol_in=LN(indiv_bridging_AT_vol_in+1).
COMPUTE LN_indiv_bridging_RT_vol_in=LN(indiv_bridging_RT_vol_in+1).

COMPUTE LN_indiv_bonding_FF_vol_in=LN(indiv_bonding_FF_vol_in+1).
COMPUTE LN_indiv_bonding_AT_vol_in=LN(indiv_bonding_AT_vol_in+1). 
COMPUTE LN_indiv_bonding_RT_vol_in=LN(indiv_bonding_RT_vol_in+1). 

EXAMINE VARIABLES=LN_indiv_bonding_FF_vol_in LN_indiv_bonding_AT_vol_in LN_indiv_bonding_RT_vol_in LN_indiv_bridging_FF_vol_in LN_indiv_bridging_AT_vol_in LN_indiv_bridging_RT_vol_in
  /PLOT NPPLOT   
  /STATISTICS DESCRIPTIVES.

*Influence of group bonding capital and individual bonding capital on individual retweets*

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_indiv_bonding_RT_vol_in 
  /METHOD=ENTER LN_indiv_bonding_AT_vol_in indiv_bonding_FF_bin_in_deg 
  /METHOD=ENTER group_bonding_FF_bin_density LN_group_bonding_AT_density  
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).


*Influence of group bridging capital and individual bonding capital on individual retweets*

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_indiv_bonding_RT_vol_in 
  /METHOD=ENTER LN_indiv_bonding_AT_vol_in indiv_bonding_FF_bin_in_deg 
  /METHOD=ENTER LN_group_bridging_FF_volume_in LN_group_bridging_AT_volume_in  
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

*Influence of group bonding capital and individual bridging capital on individual retweets*

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_indiv_bridging_RT_vol_in 
  /METHOD=ENTER LN_indiv_bridging_AT_vol_in LN_indiv_bridging_FF_vol_in 
  /METHOD=ENTER group_bonding_FF_bin_density LN_group_bonding_AT_density  
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

*Influence of group bridging  capital and individual bridging capital on individual retweets*

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_indiv_bridging_RT_vol_in 
  /METHOD=ENTER LN_indiv_bridging_AT_vol_in LN_indiv_bridging_FF_vol_in 
  /METHOD=ENTER LN_group_bridging_FF_volume_in LN_group_bridging_AT_volume_in  
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

