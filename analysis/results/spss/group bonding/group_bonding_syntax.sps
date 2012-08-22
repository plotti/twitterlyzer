* Open File *
 
GET DATA 
  /TYPE=TXT 
  /FILE="D:\Dropbox\phD\analysis\results\results\spss\group bonding\584_group_bonding.csv" 
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
  FF_bin_density F15.13 
  AT_density F15.13 
  FF_bin_avg_path_length F13.11 
  AT_bin_avg_path_length F14.12 
  FF_bin_clustering F14.12 
  AT_bin_clustering F14.12 
  FF_reciprocity F14.12 
  AT_reciprocity F15.13 
  FF_bin_transitivity F14.12 
  AT_bin_transitivity F15.13 
  RT_density F15.13 
  RT_total_volume F6.1. 
CACHE. 
EXECUTE. 

* Graph all Distributions *

GRAPH
	/HISTOGRAM(NORMAL)=Member_count.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_density.
GRAPH
	/HISTOGRAM(NORMAL)=AT_density.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_avg_path_length.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_avg_path_length.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_clustering.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_clustering.
GRAPH
	/HISTOGRAM(NORMAL)=FF_reciprocity.
GRAPH
	/HISTOGRAM(NORMAL)=AT_reciprocity.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_transitivity.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_transitivity.
GRAPH
	/HISTOGRAM(NORMAL)=RT_density.
GRAPH
	/HISTOGRAM(NORMAL)=RT_total_volume.



* Examine the IVs and DVs *

EXAMINE VARIABLES= Member_count FF_bin_density AT_density FF_bin_avg_path_length AT_bin_avg_path_length FF_bin_clustering AT_bin_clustering FF_reciprocity AT_reciprocity FF_bin_transitivity AT_bin_transitivity RT_density RT_total_volume
  /PLOT NPPLOT  
  /STATISTICS DESCRIPTIVES.

* Transform the problematic ones *

COMPUTE LN_Member_count=LN(Member_count+1).
COMPUTE LN_AT_density=LN(AT_density+1).
COMPUTE LN_RT_density=LN(RT_density+1). 
COMPUTE RECODE_FF_bin_avg_path_length = 1 - FF_bin_avg_path_length. 

*RT density is actually fine without transformations but it gets a bit better in the KS statistic so both ways seem doable *


* Output a histogram of the transformed variables *

GRAPH
  /HISTOGRAM(NORMAL)=LN_Member_count.
GRAPH
 /HISTOGRAM(NORMAL)=LN_AT_density.
GRAPH
  /HISTOGRAM(NORMAL)=LN_RT_density.

* Output examination of the transformed variables *

EXAMINE VARIABLES=LN_Member_count LN_AT_density LN_RT_density
  /PLOT NPPLOT 
  /STATISTICS DESCRIPTIVES.

* Check for multicolinarity VIF of all IVs should be smaller than 3 or 5.
*  Also a multimatrix for a first look would be nice! * 

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT FF_bin_density 
  /METHOD=ENTER FF_bin_avg_path_length FF_bin_clustering FF_reciprocity FF_bin_transitivity LN_AT_density AT_bin_avg_path_length    AT_bin_clustering  AT_reciprocity  AT_bin_transitivity .


* Multicolinearity check only for the IV  around * 

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT Member_count
  /METHOD=ENTER   LN_AT_density FF_bin_avg_path_length AT_bin_clustering FF_reciprocity.

* Perform a exploratory regressions using BACKWARD method with DV: RT_density*

REGRESSION 
  /DESCRIPTIVES MEAN STDDEV CORR SIG N 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_density 
  /METHOD=BACKWARD LN_Member_count FF_bin_density LN_AT_density FF_bin_avg_path_length AT_bin_avg_path_length FF_bin_clustering AT_bin_clustering FF_reciprocity AT_reciprocity FF_bin_transitivity AT_bin_transitivity 
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).

* Perform a exploratory regressions using BACKWARD method with DV: RT_total_volume*

REGRESSION 
  /DESCRIPTIVES MEAN STDDEV CORR SIG N 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE ZPP 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT RT_total_volume 
  /METHOD=BACKWARD LN_Member_count FF_bin_density LN_AT_density FF_bin_avg_path_length AT_bin_avg_path_length FF_bin_clustering AT_bin_clustering FF_reciprocity AT_reciprocity FF_bin_transitivity AT_bin_transitivity 
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /CASEWISE PLOT(ZRESID) OUTLIERS(2)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).

/* Perform final 3 step regression */
/* First Step direct influence of ties, second step second order network metrics, third step tie strength */

REGRESSION 
  /DESCRIPTIVES MEAN STDDEV CORR SIG N 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE ZPP 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_density 
  /METHOD=ENTER Member_count
  /METHOD=ENTER LN_AT_density FF_bin_density
  /METHOD=ENTER  FF_bin_clustering AT_bin_clustering 
  /METHOD=ENTER FF_bin_avg_path_length AT_bin_avg_path_length
  /METHOD=ENTER FF_reciprocity AT_reciprocity 
  /METHOD=ENTER FF_bin_transitivity AT_bin_transitivity
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /PARTIALPLOT ALL 
  /CASEWISE PLOT(ZRESID) OUTLIERS(2)
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

/* Alternative Perform regression with steps that contain only significant contributions for each step (its a bit trial and error) */
/* First Step direct influence of ties, second step second order network metrics, third step tie strength, fourth step your outgoing measures*/

REGRESSION 
  /DESCRIPTIVES MEAN STDDEV CORR SIG N 
  /MISSING LISTWISE 
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE ZPP 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_density 
  /METHOD=ENTER Member_count
 /METHOD=ENTER LN_AT_density 
  /METHOD=ENTER FF_bin_avg_path_length AT_bin_clustering 
  /METHOD=ENTER FF_reciprocity 
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /PARTIALPLOT ALL 
  /CASEWISE PLOT(ZRESID) OUTLIERS(2)
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

/* Perform an exploratory factor analysis  *
/* Attention this analysis EXCLUDES AT_bin_avg_path_length because it doesnt meet the criterion of having an anti image correlation of over 0.5 *
/* The rotation in oblimin since we expect that the two networks will be somewhat correlated *


FACTOR 
  /VARIABLES FF_bin_density LN_AT_density FF_bin_avg_path_length FF_bin_clustering AT_bin_clustering AT_reciprocity FF_reciprocity FF_bin_transitivity AT_bin_transitivity 
  /MISSING LISTWISE 
  /ANALYSIS FF_bin_density LN_AT_density FF_bin_avg_path_length FF_bin_clustering AT_bin_clustering AT_reciprocity FF_reciprocity FF_bin_transitivity AT_bin_transitivity 
  /PRINT UNIVARIATE INITIAL CORRELATION SIG DET KMO INV REPR AIC EXTRACTION ROTATION FSCORE 
  /FORMAT SORT BLANK(.4) 
  /PLOT EIGEN 
  /CRITERIA MINEIGEN(1) ITERATE(25) 
  /EXTRACTION PC 
  /CRITERIA ITERATE(25) DELTA(0) 
  /ROTATION OBLIMIN 
  /SAVE REG(ALL) 
  /METHOD=CORRELATION.


*/ Perform a cronbach alpha test for factor 1 (FF) *
* Note how removing the avg path length improves the alpha to .9 *

RELIABILITY 
  /VARIABLES=FF_bin_density FF_bin_transitivity FF_bin_clustering FF_reciprocity RECODE_FF_bin_avg_path_length 
  /SCALE('ALL VARIABLES') ALL 
  /MODEL=ALPHA 
  /SUMMARY=TOTAL.

*/ Perform a cronbach alpha test for factor 2 (AT measures) *
* Note: Removing ln-AT-density improves alpha to .9*

RELIABILITY 
  /VARIABLES= LN_AT_density AT_bin_transitivity AT_bin_clustering AT_reciprocity 
  /SCALE('ALL VARIABLES') ALL 
  /MODEL=ALPHA 
  /SUMMARY=TOTAL.

