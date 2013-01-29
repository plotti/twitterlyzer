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
  FF_Edges F4.0 
  AT_Edges F8.6 
  RT_Edges F4.0 
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
  Competing_Lists F3.0 
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
  RT_volume_in F8.6 
  RT_volume_out F8.6 
  FF_rec F11.9 
  AT_rec F11.9 
  AT_avg F11.7 
  FF_avg F11.7. 
CACHE.
/* Examine the IVs and DVs *

EXAMINE VARIABLES=RT_volume_in FAC1_1 FAC2_1 AT_volume_in FF_volume_in RT_density RT_total_volume
  /PLOT NPPLOT  
  /STATISTICS DESCRIPTIVES.

*/Transform a couple of variables

COMPUTE LN_AT_density=LN(AT_density+1).
COMPUTE LN_FF_density=LN(FF_bin_density+1).
COMPUTE LN_RT_volume_in=LN(RT_volume_in +1).
COMPUTE LN_RT_density =LN(RT_density +1).
COMPUTE LN_RT_total_volume =LN(RT_total_volume +1).
COMPUTE LN_FF_volume_in=LN(FF_volume_in +1).
COMPUTE LN_AT_volume_in=LN(AT_volume_in +1).
COMPUTE LN_FF_volume_out=LN(FF_volume_out +1).
COMPUTE LN_AT_volume_out=LN(AT_volume_out +1).
COMPUTE LN_FF_bin_betweeness=LN(FF_bin_betweeness +1).
COMPUTE LN_AT_bin_betweeness=LN(AT_bin_betweeness +1).
COMPUTE LN_FF_bin_pagerank=LN(FF_bin_pagerank +1).
COMPUTE LN_AT_bin_pagerank=LN(AT_bin_pagerank +1).
COMPUTE LN_FF_avg=LN(FF_avg+1).
COMPUTE LN_AT_avg=LN(AT_avg+1).

* Examine the transformed variables
EXAMINE VARIABLES=LN_RT_volume_in  LN_FF_volume_in LN_AT_volume_in LN_RT_density
  /PLOT NPPLOT  
  /STATISTICS DESCRIPTIVES.

CORRELATIONS
    /VARIABLES= AT_bin_clustering LN_AT_density FF_bin_avg_path_length FF_reciprocity LN_RT_density
                          Competing_Lists LN_AT_volume_in AT_bin_closeness LN_FF_avg LN_RT_volume_in
   /MATRIX=OUT ('D:\Dropbox\phD\analysis\results\results\spss\group\584_corr_matrix.sav').

MATRIX DATA VARIABLES= AT_bin_clustering LN_AT_density FF_bin_avg_path_length FF_reciprocity LN_RT_density
                          Competing_Lists LN_AT_volume_in AT_bin_closeness LN_FF_avg LN_RT_volume_in
/FILE=INLINE
/FORMAT=FREE LOWER DIAGONAL
/CONTENTS=CORR MEAN SD
/N=166.

BEGIN DATA.
1.0000000	
.8271857	1.0000000	
-.4124013	-.4079326	1.0000000	
.2101182	.2718447	-.4267718	1.0000000	
.6520247	.6314326	-.3692334	.0083631	1.0000000	
-.2887417	-.2392241	.3043977	-.1476346	-.2311574	1.0000000	
-.1469389	-.0677423	.2268802	-.0826047	-.1910919	.5661081	1.0000000	
-.1119249	-.1190582	.0589028	.2829712	-.2068774	.4905843	.3997626	1.0000000	
-.0930358	-.0521679	-.1517201	.3764766	-.2037519	.4339039	.3898856	.4606385	1.0000000	
-.2544948	-.2824306	.3155713	-.2203496	-.1312083	.6996652	.6814637	.5872480	.3193605	1.0000000
.0000000 .0000000 .0000000 .0000000 .0000000 .0000000 .0000000 .0000000 .0000000 .0000000 
1.000000 1.000000 1.000000 1.000000 1.000000 1.000000 1.000000 1.000000 1.000000 1.000000 
END DATA.



REGRESSION MATRIX IN(*)
  /DEPENDENT LN_RT_density 
  /METHOD=ENTER  AT_bin_clustering LN_AT_density FF_bin_avg_path_length FF_reciprocity 
                          Competing_Lists LN_AT_volume_in AT_bin_closeness LN_FF_avg 
.


REGRESSION MATRIX IN(*)
  /DEPENDENT LN_RT_volume_in 
  /METHOD=ENTER   AT_bin_clustering LN_AT_density FF_bin_avg_path_length FF_reciprocity 
                          Competing_Lists LN_AT_volume_in AT_bin_closeness LN_FF_avg 
.

* Regress the case where bonding SC is negatively correlated with information the group receives*
* Possiblity to factor the IVs into two factors and then regress those
/METHOD=ENTER  /* Also possible with the two factors FAC1_1 FAC2_1
* Its a bit problematic we can explain only little a bit less than 10% and the clustering is clashing with density
* I've taken the factors that were best at describing internal diffusion
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_volume_in 
  /METHOD=ENTER LN_AT_density 
 /METHOD=ENTER FF_reciprocity
  /METHOD=ENTER  AT_bin_clustering
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(2).

* Regression of the case where bridging SC is negatively correlated with the information that the group exchanges between its members*
* Only one of the IVs iis negatively correlated with SC (FF_volume_in aka the attention the group gets). AT_volume in seems to be only low correlated to RT density inside the group.
* It seems like the regression is estimating a slope that is too low and it understimates values with high retweet density* (Sort by retweet density and then run regression)
* I could need more cases of groups with high retweet density to get better results *
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_density 
 /METHOD=ENTER Competing_Lists
 /METHOD=ENTER FF_bin_closeness  AT_bin_closeness LN_AT_volume_in
 /METHOD=ENTER LN_FF_avg /*LN_FF_volume_out LN_AT_volume_out  
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(2).

*TOTAL VOLUME AS DV: Results here of all IVs are nonsignificant
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_total_volume 
  /METHOD=ENTER   LN_AT_volume_in LN_FF_volume_in LN_FF_volume_out LN_AT_volume_out
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).

* For exploration reasons check the regression of some of the network measures against retweet_density
* FF Closeness seems negatively correlated with the DV the rest renders insignificant, probably also because of the small effect
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_total_volume 
  /METHOD=ENTER   FF_bin_betweeness FF_bin_closeness FF_bin_pagerank 
/METHOD=ENTER AT_bin_betweeness AT_bin_closeness AT_bin_pagerank 
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).

