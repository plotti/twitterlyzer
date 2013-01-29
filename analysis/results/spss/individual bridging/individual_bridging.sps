
* Open File *

GET DATA 
  /TYPE=TXT 
  /FILE="D:\Dropbox\phD\analysis\results\results\spss\individual bridging\584_individual_bridging_3.csv" 
  /DELCASE=LINE 
  /DELIMITERS="," 
  /ARRANGEMENT=DELIMITED 
  /FIRSTCASE=2 
  /IMPORTCASE=ALL 
  /VARIABLES= 
  Project F3.0 
  Community A11 
  Person_ID A15 
  Competing_lists F1.0 
  FF_bin_degree F17.15 
  FF_bin_in_degree F17.15 
  FF_bin_out_degree F17.15 
  FF_vol_in F6.1 
  FF_vol_out F6.1 
  FF_groups_in F3.0 
  FF_groups_out F3.0 
  FF_rec F15.13 
  FF_bin_betweeness F17.15 
  AT_bin_degree F17.15 
  AT_bin_in_degree F17.15 
  AT_bin_out_degree F17.15 
  AT_vol_in F6.1 
  AT_vol_out F6.1 
  AT_groups_in F2.0 
  AT_groups_out F2.0 
  AT_rec F16.14 
  AT_bin_betweeness F17.15 
  AT_avg_tie_strength F13.11 
  AT_strength_centrality_in F14.12 
  RT_bin_in_degree F17.15 
  RT_bin_out_degree F17.15 
  RT_vol_in F5.1 
  RT_vol_out F5.1. 
CACHE. 
EXECUTE.

* Graph all Distributions *

GRAPH
	/HISTOGRAM(NORMAL)=Competing_lists.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_degree.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_in_degree.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_out_degree.
GRAPH
	/HISTOGRAM(NORMAL)=FF_vol_in.
GRAPH
	/HISTOGRAM(NORMAL)=FF_vol_out.
GRAPH
	/HISTOGRAM(NORMAL)=FF_groups_in.
GRAPH
	/HISTOGRAM(NORMAL)=FF_groups_out.
GRAPH
	/HISTOGRAM(NORMAL)=FF_rec.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_degree.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_in_degree.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_out_degree.
GRAPH
	/HISTOGRAM(NORMAL)=LN_AT_vol_in.
GRAPH
	/HISTOGRAM(NORMAL)=AT_vol_out.
GRAPH
	/HISTOGRAM(NORMAL)=AT_groups_in.
GRAPH
	/HISTOGRAM(NORMAL)=AT_groups_out.
GRAPH
	/HISTOGRAM(NORMAL)=AT_rec.
GRAPH
	/HISTOGRAM(NORMAL)=AT_strength_centrality_in.
GRAPH
	/HISTOGRAM(NORMAL)=RT_bin_in_degree.
GRAPH
	/HISTOGRAM(NORMAL)=RT_bin_out_degree.
GRAPH
	/HISTOGRAM(NORMAL)=LN_RT_vol_in.
GRAPH
	/HISTOGRAM(NORMAL)=RT_vol_out.

* Transform the non normal variables *

COMPUTE LN_Competing_lists=LN(Competing_lists+1).
COMPUTE LN_FF_bin_degree=LN(FF_bin_degree+1).
COMPUTE LN_FF_bin_in_degree=LN(FF_bin_in_degree+1).
COMPUTE LN_FF_bin_out_degree=LN(FF_bin_out_degree+1).
COMPUTE LN_FF_vol_in=LN(FF_vol_in+1).
COMPUTE LN_FF_vol_out=LN(FF_vol_out+1).
COMPUTE LN_FF_groups_in=LN(FF_groups_in+1).
COMPUTE LN_FF_groups_out=LN(FF_groups_out+1).
COMPUTE LN_FF_rec=LN(FF_rec+1).
COMPUTE LN_AT_bin_degree=LN(AT_bin_degree+1).
COMPUTE LN_AT_bin_in_degree=LN(AT_bin_in_degree+1).
COMPUTE LN_AT_bin_out_degree=LN(AT_bin_out_degree+1).
COMPUTE LN_AT_vol_in=LN(AT_vol_in+1).
COMPUTE LN_AT_vol_out=LN(AT_vol_out+1).
COMPUTE LN_AT_groups_in=LN(AT_groups_in+1).
COMPUTE LN_AT_groups_out=LN(AT_groups_out+1).
COMPUTE LN_AT_rec=LN(AT_rec+1).
COMPUTE LN_AT_strength_centrality_in=LN(AT_strength_centrality_in+1).
COMPUTE LN_RT_bin_in_degree=LN(RT_bin_in_degree+1).
COMPUTE LN_RT_bin_out_degree=LN(RT_bin_out_degree+1).
COMPUTE LN_RT_vol_in=LN(RT_vol_in+1).
COMPUTE LN_RT_vol_out=LN(RT_vol_out+1).
COMPUTE LN_FF_bin_betweeness=LN(FF_bin_betweeness+1).
COMPUTE LN_AT_bin_betweeness=LN(AT_bin_betweeness+1).
COMPUTE LN_AT_avg_tie_strength=LN(AT_avg_tie_strength+1).

* Output examination of the non-transformed variables *
EXAMINE VARIABLES=Competing_lists  FF_vol_in AT_vol_in FF_groups_in  AT_groups_in 
                                    FF_bin_betweeness AT_bin_betweeness
                                    FF_rec AT_rec AT_avg_tie_strength
                                    AT_strength_centrality_in
																																				RT_vol_in
  /PLOT NPPLOT  
  /STATISTICS DESCRIPTIVES.

* NonTransformed descriptives
DESCRIPTIVES  VARIABLES=Competing_lists  FF_vol_in AT_vol_in FF_groups_in  AT_groups_in 
                                    FF_bin_betweeness AT_bin_betweeness
                                    FF_rec AT_rec AT_avg_tie_strength
                                    AT_strength_centrality_in
																																				RT_vol_in
/STATISTICS=MEAN STDDEV MIN MAX.

EXAMINE VARIABLES= RT_vol_in Competing_lists  
                                    FF_vol_in AT_vol_in FF_groups_in  AT_groups_in 
                                    FF_bin_betweeness AT_bin_betweeness
                                    FF_rec AT_rec AT_avg_tie_strength
                                    AT_strength_centrality_in																																				
  /PLOT NPPLOT  
  /STATISTICS DESCRIPTIVES.

DESCRIPTIVES  VARIABLES= RT_vol_in Competing_lists  
                                    FF_vol_in AT_vol_in FF_groups_in  AT_groups_in 
                                    FF_bin_betweeness AT_bin_betweeness
                                    FF_rec AT_rec AT_avg_tie_strength
                                    AT_strength_centrality_in				
/STATISTICS=MEAN STDDEV MIN MAX.

* Examine if the indegree and group in measures and the combined measure all load onto the same factors *
* Result: We see that the factors determined are the FF and AT networks *

FACTOR 
  /VARIABLES  LN_RT_vol_in LN_Competing_lists  LN_FF_vol_in LN_AT_vol_in FF_groups_in  AT_groups_in 
                                    LN_FF_bin_betweeness LN_AT_bin_betweeness
                                    FF_rec AT_rec LN_AT_avg_tie_strength
                                    LN_AT_strength_centrality_in																										
  /MISSING LISTWISE 
  /ANALYSIS  	LN_RT_vol_in LN_Competing_lists  LN_FF_vol_in LN_AT_vol_in FF_groups_in  AT_groups_in 
                                    LN_FF_bin_betweeness LN_AT_bin_betweeness
                                    FF_rec AT_rec LN_AT_avg_tie_strength
                                    LN_AT_strength_centrality_in													
  /PRINT UNIVARIATE INITIAL CORRELATION SIG DET KMO INV REPR AIC EXTRACTION ROTATION 
  /FORMAT SORT BLANK(.4) 
  /PLOT EIGEN ROTATION 
  /CRITERIA  FACTORS(2)   ITERATE(25) /* MINEIGEN(1)  FACTORS(2) 
  /EXTRACTION PC 
  /CRITERIA ITERATE(25) 
  /ROTATION VARIMAX  /*   OBLIMIN VARIMAX
  /METHOD=CORRELATION.

* Examine if the number of reciprocated ties to other groups is its own factor*
* Result not really because having reciprocated edges effect in the FF network is actually negative while in the AT network it is positive*
* In the FF network it describes hierarchy and accounts that have a lot of followers but dont follow anyone* 
* In the AT network it describes accounts that like maintain their relations with their readers *
FACTOR 
  /VARIABLES  LN_AT_vol_in LN_FF_vol_in LN_AT_groups_in LN_FF_groups_in  LN_AT_strength_centrality_inc LN_FF_rec LN_AT_rec 
  /MISSING LISTWISE 
  /ANALYSIS LN_AT_vol_in LN_FF_vol_in LN_AT_groups_in LN_FF_groups_in  LN_AT_strength_centrality_inc LN_FF_rec LN_AT_rec 
  /PRINT UNIVARIATE INITIAL CORRELATION SIG DET KMO INV REPR AIC EXTRACTION ROTATION 
  /FORMAT SORT BLANK(.4) 
  /PLOT EIGEN ROTATION 
  /CRITERIA  FACTORS(2)   ITERATE(25) /* MINEIGEN(1)  FACTORS(2) 
  /EXTRACTION PC 
  /CRITERIA ITERATE(25) 
  /ROTATION VARIMAX  /*   OBLIMIN VARIMAX
  /METHOD=CORRELATION.


* Examine if the number of competing lists is an own factor*
* Result comparing it to the other variables we definitely see that its clustered in its own factor*
FACTOR 
  /VARIABLES  LN_AT_vol_in LN_FF_vol_in LN_AT_groups_in LN_FF_groups_in  LN_AT_strength_centrality_inc Competing_lists
  /MISSING LISTWISE 
  /ANALYSIS LN_AT_vol_in LN_FF_vol_in LN_AT_groups_in LN_FF_groups_in  LN_AT_strength_centrality_inc Competing_lists
  /PRINT UNIVARIATE INITIAL CORRELATION SIG DET KMO INV REPR AIC EXTRACTION ROTATION 
  /FORMAT SORT BLANK(.4) 
  /PLOT EIGEN ROTATION 
  /CRITERIA  FACTORS(2)   ITERATE(25) /* MINEIGEN(1)  FACTORS(2) 
  /EXTRACTION PC 
  /CRITERIA ITERATE(25) 
  /ROTATION VARIMAX  /*   OBLIMIN VARIMAX
  /METHOD=CORRELATION.

/* Regression explaining the amount of bridging retweets towards this person */
/* It exclueds LN_AT_groups_in LN_FF_groups_in due to  the high multicollinearity with the volume of followers in and interaction in
/* It also excludes  LN_AT_strength_centrality_inc due to a has a high amount of multicollinearity with AT volume in 

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=ENTER LN_Competing_lists
  /METHOD=ENTER LN_AT_vol_in LN_FF_vol_in 
  /METHOD=ENTER FF_groups_in AT_groups_in 
  /METHOD=ENTER LN_FF_bin_betweeness LN_AT_bin_betweeness
  /METHOD=ENTER FF_rec AT_rec  LN_AT_avg_tie_strength
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /PARTIALPLOT ALL
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).


* Regression explaining the amount of bridging retweets towards this person */
* Instead of ff and at volume in it uses the group in measure *
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=ENTER Competing_lists
  /METHOD=ENTER  LN_AT_groups_in LN_FF_groups_in 
  /METHOD=ENTER LN_FF_rec LN_AT_rec 
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

* Regression exploring the influence of the at olume centrality measure on retweets from other groups *
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=ENTER Competing_lists
  /METHOD=ENTER LN_AT_strength_centrality_in
  /METHOD=ENTER LN_FF_rec LN_AT_rec 
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

*Regression only on ties
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=ENTER FF_rec AT_rec  
 /METHOD=ENTER LN_AT_avg_tie_strength
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).


/* Regression exploring only the influence of the last measure

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=ENTER LN_Competing_lists
  /METHOD=ENTER LN_AT_strength_centrality_in
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

*Combined measure

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=ENTER LN_Competing_lists
  /METHOD=ENTER LN_AT_vol_in LN_FF_vol_in 
  /METHOD=ENTER FF_rec
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /PARTIALPLOT ALL
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

