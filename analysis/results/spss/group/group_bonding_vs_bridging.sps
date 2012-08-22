/* Get the merged file for cross analysis *

GET DATA 
  /TYPE=TXT 
  /FILE="D:\Dropbox\phD\analysis\results\results\spss\group\bridging_vs_bonding.csv" 
  /DELCASE=LINE 
  /DELIMITERS="," 
  /ARRANGEMENT=DELIMITED 
  /FIRSTCASE=2 
  /IMPORTCASE=ALL 
  /VARIABLES= 
  Project F3.0 
  Name A29 
  Member_count F6.0 
  FF_Nodes F3.0 
  AT_Nodes F3.0 
  RT_Nodes F3.0 
  FF_bin_density F11.9 
  AT_density F11.9 
  FF_bin_avg_path_length F11.9 
  AT_bin_avg_path_length F11.9 
  FF_bin_clustering F11.9 
  AT_bin_clustering F11.9 
  FF_reciprocity F11.9 
  AT_reciprocity F11.9 
  FF_bin_transitivity F11.9 
  AT_bin_transitivity F11.9 
  RT_density F11.9 
  RT_total_volume F4.0 
  FF_bin_degree F11.9 
  FF_bin_in_degree F11.9 
  FF_bin_out_degree F11.9 
  FF_volume_in F5.0 
  FF_volume_out F5.0 
  FF_bin_betweeness F11.9 
  FF_bin_closeness F11.9 
  FF_bin_pagerank F11.9 
  FF_bin_c_size F11.9 
  FF_bin_c_density F11.9 
  FF_bin_c_hierarchy F11.9 
  FF_bin_c_index F11.9 
  AT_bin_degree F11.9 
  AT_bin_in_degree F11.9 
  AT_bin_out_degree F11.9 
  AT_bin_betweeness F11.9 
  AT_bin_closeness F11.9 
  AT_bin_pagerank F11.9 
  AT_bin_c_size F11.9 
  AT_bin_c_density F11.9 
  AT_bin_c_hierarchy F11.9 
  AT_bin_c_index F11.9 
  AT_volume_in F5.0 
  AT_volume_out F5.0 
  RT_volume_in F4.0 
  RT_volume_out F5.0. 
CACHE. 
EXECUTE.

/* Examine the IVs and DVs *

EXAMINE VARIABLES=RT_volume_in FAC1_1 FAC2_1 AT_volume_in FF_volume_in RT_density RT_total_volume
  /PLOT NPPLOT  
  /STATISTICS DESCRIPTIVES.

*/Transform a couple of variables

COMPUTE LN_RT_volume_in=LN(RT_volume_in +1).
COMPUTE LN_RT_density =LN(RT_density +1).
COMPUTE LN_RT_total_volume =LN(RT_total_volume +1).
COMPUTE LN_FF_volume_in=LN(FF_volume_in +1).
COMPUTE LN_AT_volume_in=LN(AT_volume_in +1).
COMPUTE LN_FF_volume_out=LN(FF_volume_out +1).
COMPUTE LN_AT_volume_out=LN(AT_volume_out +1).

/* Examine the transformed variables

EXAMINE VARIABLES=LN_RT_volume_in  LN_FF_volume_in LN_AT_volume_in LN_RT_density
  /PLOT NPPLOT  
  /STATISTICS DESCRIPTIVES.

/* Regress the case where bonding SC is negatively correlated with information the group receives*

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_volume_in 
  /METHOD=ENTER FAC1_1 FAC2_1
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(2).

*/ Regression of the case where bridging SC is negatively correlated with the information that the group exchanges between its members*
/* Only one of the IVs iis negatively correlated with SC (FF_volume_in aka the attention the group gets). AT_volume in seems to be only low correlated to RT density inside the group.
/* It seems like the regression is estimating a slope that is too low and it understimates values with high retweet density* (Sort by retweet density and then run regression)
/* I could need more cases of groups with high retweet density to get better results *

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA  COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_density 
  /METHOD=ENTER   LN_AT_volume_in LN_FF_volume_in /*LN_FF_volume_out LN_AT_volume_out
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(2).

*TOTAL VOLUME AS DV: Results here of all IVs are nonsignificant

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_total_volume 
  /METHOD=ENTER   LN_AT_volume_in LN_FF_volume_in LN_FF_volume_out LN_AT_volume_out
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).

/* For exploration reasons check the regression of some of the network measures against retweet_density
/* FF Closeness seems negatively correlated with the DV the rest renders insignificant, probably also because of the small effect

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_total_volume 
  /METHOD=ENTER   FF_bin_betweeness FF_bin_closeness FF_bin_pagerank 
/METHOD=ENTER AT_bin_betweeness AT_bin_closeness AT_bin_pagerank 
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).

