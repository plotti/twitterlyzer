GET DATA 
  /TYPE=TXT 
  /FILE="D:\Dropbox\phD\analysis\results\results\spss\individual\584_individual.csv" 
  /DELCASE=LINE 
  /DELIMITERS="," 
  /ARRANGEMENT=DELIMITED 
  /FIRSTCASE=2 
  /IMPORTCASE=ALL 
  /VARIABLES= 
  bonding_Project F3.0 
  bonding_Community A29 
  bonding_Person_ID A15 
  bonding_Place_on_list F3.0 
  bonding_FF_bin_deg F11.9 
  bonding_FF_bin_in_deg F11.9 
  bonding_FF_bin_out_deg F11.9 
  bonding_FF_vol_in F2.0 
  bonding_FF_vol_out F2.0 
  bonding_FF_bin_close F11.9 
  bonding_FF_bin_page F11.9 
  bonding_FF_rec F11.9 
  bonding_AT_bin_deg F11.9 
  bonding_AT_bin_in_deg F11.9 
  bonding_AT_bin_out_deg F11.9 
  bonding_AT_bin_close F11.9 
  bonding_AT_bin_page F11.9 
  bonding_AT_rec F11.9 
  bonding_AT_avg F11.9 
  bonding_AT_vol_in F4.0 
  bonding_AT_vol_out F4.0 
  bonding_RT_bin_deg_in F11.9 
  bonding_RT_bin_deg_out F11.9 
  bonding_RT_vol_in F3.0 
  bonding_RT_vol_out F3.0 
  bonding_RT_global_vol_in F3.0 
  bonding_RT_global_vol_out F3.0 
  bridging_Project F3.0 
  bridging_Community A29 
  bridging_Person_ID A15 
  bridging_Competing_lists F1.0 
  bridging_FF_bin_degree F11.9 
  bridging_FF_bin_in_degree F11.9 
  bridging_FF_bin_out_degree F11.9 
  bridging_FF_vol_in F4.0 
  bridging_FF_vol_out F4.0 
  bridging_FF_groups_in F3.0 
  bridging_FF_groups_out F3.0 
  bridging_FF_rec F11.9 
  bridging_FF_bin_betweeness F11.9 
  bridging_AT_bin_degree F11.9 
  bridging_AT_bin_in_degree F11.9 
  bridging_AT_bin_out_degree F11.9 
  bridging_AT_vol_in F4.0 
  bridging_AT_vol_out F3.0 
  bridging_AT_groups_in F3.0 
  bridging_AT_groups_out F2.0 
  bridging_AT_rec F11.9 
  bridging_AT_bin_betweeness F11.9 
  bridging_AT_avg_tie_strength F11.9 
  bridging_AT_strength_centrality_in F11.9 
  bridging_RT_bin_in_degree F11.9 
  bridging_RT_bin_out_degree F11.9 
  bridging_RT_vol_in F3.0 
  bridging_RT_vol_out F3.0. 
CACHE. 
EXECUTE.

* Transform bonding IV*

COMPUTE LN_bonding_AT_vol_in=LN(bonding_AT_vol_in+1).
COMPUTE LN_bonding_FF_vol_in=LN(bonding_FF_vol_in+1).
COMPUTE LN_bonding_RT_vol_in=LN(bonding_RT_vol_in+1).
COMPUTE LN_bonding_FF_bin_in_deg=LN(bonding_FF_bin_in_deg+1).
COMPUTE LN_bonding_AT_bin_page=LN(bonding_AT_bin_page+1).
COMPUTE LN_bonding_FF_bin_page=LN(bonding_FF_bin_page+1).
COMPUTE LN_bonding_AT_avg=LN(bonding_AT_avg+1).

*Transform bridging IV*

COMPUTE LN_bridging_AT_vol_in=LN(bridging_AT_vol_in+1).
COMPUTE LN_bridging_FF_vol_in=LN(bridging_FF_vol_in+1).
COMPUTE LN_bridging_RT_vol_in=LN(bridging_RT_vol_in+1). 
COMPUTE LN_bridging_Competing_lists=LN(bridging_Competing_lists+1). 
COMPUTE LN_bridging_FF_bin_betweeness=LN(bridging_FF_bin_betweeness+1).
COMPUTE LN_bridging_AT_bin_betweeness=LN(bridging_AT_bin_betweeness+1).
COMPUTE LN_bridging_AT_avg_tie_strength=LN(bridging_AT_avg_tie_strength+1).
COMPUTE LN_bridging_AT_strength_centrality_in=LN(bridging_AT_strength_centrality_in+1). 

*Output the correlation matrix for path model

CORRELATIONS
    /VARIABLES=bonding_Place_on_list LN_bonding_AT_vol_in bonding_AT_bin_close LN_bonding_FF_bin_page bonding_FF_rec LN_bonding_RT_vol_in
                          LN_bridging_Competing_Lists LN_bridging_AT_vol_in LN_bridging_FF_vol_in bridging_FF_rec LN_bridging_RT_vol_in
   /MATRIX=OUT ('D:\Dropbox\phD\analysis\results\results\spss\individual\584_corr_matrix.sav').

MATRIX DATA VARIABLES= bonding_Place_on_list LN_bonding_AT_vol_in bonding_AT_bin_close LN_bonding_FF_bin_page bonding_FF_rec LN_bonding_RT_vol_in
                          LN_bridging_Competing_Lists LN_bridging_AT_vol_in LN_bridging_FF_vol_in bridging_FF_rec LN_bridging_RT_vol_in
/FILE=INLINE
/FORMAT=FREE LOWER DIAGONAL
/CONTENTS=CORR MEAN SD
/N=15413.

BEGIN DATA.
1.0000000	
-.2475679	1.0000000	
-.0570250	.6295603	1.0000000	
-.4457018	.3571782	.1269384	1.0000000	
-.0548316	.2189391	.2456310	.1514041	1.0000000	
-.2662161	.6289560	.5145619	.3368825	.1069528	1.0000000	
-.2411009	.0374314	-.0987369	.2685866	-.0813416	.0318178	1.0000000	
-.2216737	.3137558	.0625559	.2929884	-.0291326	.0805342	.4175973	1.0000000	
-.2236226	.0115678	-.0740450	.2633618	.2269244	-.1019471	.3857911	.6686792	1.0000000	
-.0057131	-.1111101	-.0477156	-.0037637	.6434988	-.1444201	-.0049485	.0166343	.4584486	1.0000000	
-.2231354	.1256545	-.0166568	.2893600	-.1080345	.1804246	.4511568	.7331388	.5929711	-.0269968	1.0000000
.0000000 .0000000 .0000000 .0000000 .0000000 .0000000 .0000000 .0000000 .0000000 .0000000 .0000000
1.000000 1.000000 1.000000 1.000000 1.000000 1.000000 1.000000 1.000000 1.000000 1.000000 1.000000 
END DATA.

* Path model

REGRESSION MATRIX IN(*)
  /DEPENDENT LN_bonding_RT_vol_in 
  /METHOD=ENTER  bonding_Place_on_list LN_bonding_AT_vol_in bonding_AT_bin_close LN_bonding_FF_bin_page bonding_FF_rec 
                          LN_bridging_Competing_Lists LN_bridging_AT_vol_in LN_bridging_FF_vol_in bridging_FF_rec 
.

REGRESSION MATRIX IN(*)
  /DEPENDENT LN_bridging_RT_vol_in 
  /METHOD=ENTER  bonding_Place_on_list LN_bonding_AT_vol_in bonding_AT_bin_close LN_bonding_FF_bin_page bonding_FF_rec 
                          LN_bridging_Competing_Lists LN_bridging_AT_vol_in LN_bridging_FF_vol_in bridging_FF_rec 
.

*
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_bonding_RT_vol_in 
 /METHOD=ENTER LN_bridging_AT_strength_centrality_in 
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

* Influence of having high individual bonding capital on information diffusion from outside the group *
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_bridging_RT_vol_in
 /METHOD=ENTER bonding_Place_on_list
  /METHOD=ENTER LN_bonding_AT_vol_in  bonding_FF_bin_in_deg
  /METHOD=ENTER bonding_AT_bin_close bonding_FF_bin_close
 /METHOD=ENTER LN_bonding_AT_bin_page LN_bonding_FF_bin_page
   /METHOD=ENTER bonding_AT_rec bonding_FF_rec LN_bonding_AT_avg
 /PARTIALPLOT ALL
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).
