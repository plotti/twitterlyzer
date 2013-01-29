* Open File *
 
GET DATA 
  /TYPE=TXT 
  /FILE="D:\Dropbox\phD\analysis\results\results\spss\individual bonding\584_individual_bonding_w_language.csv" 
  /DELCASE=LINE 
  /DELIMITERS="," 
  /ARRANGEMENT=DELIMITED 
  /FIRSTCASE=2 
  /IMPORTCASE=ALL 
  /VARIABLES= 
  Project F3.0 
  Community A10 
  Person_ID A15 
  Place_on_list F3.0 
  Shared_Language F3.0 
  Other_language F3.0 
  FF_bin_deg F4.2 
  FF_bin_in_deg F4.2 
  FF_bin_out_deg F4.2 
  FF_vol_in F2.0 
  FF_vol_out F2.0 
  FF_bin_close F11.9 
  FF_bin_page F11.9 
  FF_rec F11.9 
  AT_bin_deg F4.2 
  AT_bin_in_deg F4.2 
  AT_bin_out_deg F4.2 
  AT_bin_close F11.9 
  AT_bin_page F11.9 
  AT_rec F11.9 
  AT_avg F11.9 
  AT_vol_in F3.0 
  AT_vol_out F3.0 
  RT_bin_deg_in F11.9 
  RT_bin_deg_out F11.9 
  RT_vol_in F3.0 
  RT_vol_out F3.0 
  RT_global_vol_in F3.0 
  RT_global_vol_out F3.0. 
CACHE. 
EXECUTE.

* Graph all Distributions *

GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_deg.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_in_deg.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_out_deg.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_close.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_page.
GRAPH
	/HISTOGRAM(NORMAL)=FF_rec.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_deg.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_in_deg.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_out_deg.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_close.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_page.
GRAPH
	/HISTOGRAM(NORMAL)=AT_rec.
GRAPH
	/HISTOGRAM(NORMAL)=AT_avg.
GRAPH
	/HISTOGRAM(NORMAL)=AT_vol_in.
GRAPH
	/HISTOGRAM(NORMAL)=AT_vol_out.
GRAPH
	/HISTOGRAM(NORMAL)=RT_vol_in.
GRAPH
	/HISTOGRAM(NORMAL)=RT_vol_out.
GRAPH
	/HISTOGRAM(NORMAL)=RT_global_vol_in.
GRAPH
	/HISTOGRAM(NORMAL)=RT_global_vol_out.
GRAPH
	/HISTOGRAM(NORMAL)=Shared_Language.

* Examine the IVs and DVs 

EXAMINE VARIABLES= RT_vol_in Place_on_list FF_bin_in_deg  AT_vol_in FF_bin_close AT_bin_close FF_bin_page AT_bin_page FF_rec AT_rec AT_avg
  /PLOT NPPLOT 
  /STATISTICS DESCRIPTIVES.

* Transform the problematic ones *

COMPUTE LN_FF_bin_page=LN(FF_bin_page+1).
COMPUTE LN_AT_bin_deg=LN(AT_bin_deg+1).
COMPUTE LN_AT_bin_in_deg=LN(AT_bin_in_deg+1).
COMPUTE LN_AT_bin_out_deg=LN(AT_bin_out_deg+1).
COMPUTE LN_AT_bin_close=LN(AT_bin_close+1).
COMPUTE LN_AT_bin_page=LN(AT_bin_page+1). 
COMPUTE LN_AT_avg=LN(AT_avg+1).
COMPUTE LN_AT_vol_in=LN(AT_vol_in+1). 
COMPUTE LN_AT_vol_out=LN(AT_vol_out+1). 
COMPUTE LN_RT_vol_in=LN(RT_vol_in+1). 
COMPUTE LN_RT_vol_out=LN(RT_vol_out+1). 
COMPUTE LN_RT_global_vol_in=LN(RT_global_vol_in+1). 
COMPUTE LN_RT_global_vol_out=LN(RT_global_vol_out+1). 
COMPUTE LN_Shared_Language=LN(Shared_Language+1). 


* RESULT: it seems that FF_bin_page, AT_bin_page and AT_bin_close cannot be improved by transformation their QQ plots are still terrible*

* Output a histogram of the transformed variables *

GRAPH
  /HISTOGRAM(NORMAL)=LN_FF_bin_page.
GRAPH
 /HISTOGRAM(NORMAL)=LN_AT_bin_deg.
GRAPH
  /HISTOGRAM(NORMAL)=LN_AT_bin_in_deg.
GRAPH
  /HISTOGRAM(NORMAL)=LN_AT_bin_out_deg.
GRAPH
  /HISTOGRAM(NORMAL)=LN_AT_bin_close.
GRAPH
  /HISTOGRAM(NORMAL)=LN_AT_bin_page.
GRAPH
  /HISTOGRAM(NORMAL)=LN_AT_avg.
GRAPH
  /HISTOGRAM(NORMAL)=LN_AT_vol_in.
GRAPH
  /HISTOGRAM(NORMAL)=LN_AT_vol_out.
GRAPH
  /HISTOGRAM(NORMAL)=LN_RT_vol_in.
GRAPH
  /HISTOGRAM(NORMAL)=LN_RT_vol_out.
GRAPH
  /HISTOGRAM(NORMAL)=LN_RT_global_vol_in.
GRAPH
  /HISTOGRAM(NORMAL)=LN_RT_global_vol_out.
GRAPH
  /HISTOGRAM(NORMAL)=LN_Shared_Language.

* Output examination of the transformed variables *

EXAMINE VARIABLES=LN_FF_bin_page LN_AT_bin_deg LN_AT_bin_in_deg LN_AT_bin_out_deg LN_AT_bin_close LN_AT_bin_page LN_AT_avg LN_AT_vol_in LN_AT_vol_out LN_RT_vol_in LN_RT_vol_out LN_RT_global_vol_in LN_RT_global_vol_out
  /PLOT NPPLOT 
  /STATISTICS DESCRIPTIVES.

DESCRIPTIVES  VARIABLES=RT_vol_in Place_on_list FF_bin_in_deg AT_vol_in FF_bin_close AT_bin_close FF_bin_page AT_bin_page AT_rec AT_avg FF_rec 
/STATISTICS=MEAN STDDEV MIN MAX.

EXAMINE VARIABLES=RT_vol_in  Place_on_list FF_bin_in_deg AT_vol_in FF_bin_close AT_bin_close FF_bin_page AT_bin_page AT_rec AT_avg FF_rec 
  /PLOT NPPLOT 
  /STATISTICS DESCRIPTIVES.

* Do some factor analysis to see which measures load onto the same factor *
* Below are the IVs that can be used for pca
LN_AT_bin_deg LN_AT_bin_in_deg LN_AT_bin_out_deg
LN_FF_bin_deg LN_FF_bin_in_deg LN_FF_bin_out_deg
LN_FF_bin_page   LN_AT_bin_page
FF_bin_close LN_AT_bin_close 
LN_AT_vol_in  LN_AT_vol_out
FF_bin_in_deg  FF_bin_out_deg
FF_rec AT_rec AT_avg

* This factor analysis shows that the vol in and out load onto the FF and AT components
FACTOR 
  /VARIABLES  LN_AT_vol_in  LN_AT_vol_out FF_bin_in_deg  FF_bin_out_deg 
  /MISSING LISTWISE 
  /ANALYSIS LN_AT_vol_in  LN_AT_vol_out FF_bin_in_deg  FF_bin_out_deg
  /PRINT UNIVARIATE INITIAL CORRELATION SIG DET KMO INV REPR AIC EXTRACTION ROTATION 
  /FORMAT SORT BLANK(.4) 
  /PLOT EIGEN ROTATION 
  /CRITERIA  FACTORS(2)   ITERATE(25) /* MINEIGEN(1)  FACTORS(2) 
  /EXTRACTION PC 
  /CRITERIA ITERATE(25) 
  /ROTATION VARIMAX  /*   OBLIMIN VARIMAX
  /METHOD=CORRELATION.

* Look how the Reciprocity measures align with the indegree factors *
* It seems they are also added to the FF/AT components instead of building its own factor
FACTOR 
  /VARIABLES  LN_AT_vol_in  LN_AT_vol_out FF_bin_in_deg  FF_bin_out_deg FF_rec AT_rec AT_avg
  /MISSING LISTWISE 
  /ANALYSIS LN_AT_vol_in  LN_AT_vol_out FF_bin_in_deg  FF_bin_out_deg FF_rec AT_rec AT_avg
  /PRINT UNIVARIATE INITIAL CORRELATION SIG DET KMO INV REPR AIC EXTRACTION ROTATION 
  /FORMAT SORT BLANK(.4) 
  /PLOT EIGEN ROTATION 
  /CRITERIA  MINEIGEN(1)  ITERATE(25) /* MINEIGEN(1)  FACTORS(2) 
  /EXTRACTION PC 
  /CRITERIA ITERATE(25) 
  /ROTATION VARIMAX  /*   OBLIMIN VARIMAX
  /METHOD=CORRELATION.

* This factor analysis explores how the network measures and reciprocity measures load onto possible factors

FACTOR 
  /VARIABLES  LN_RT_vol_in Place_on_list FF_bin_in_deg  LN_AT_vol_in  FF_bin_close AT_bin_close LN_FF_bin_page  LN_AT_bin_page FF_rec AT_rec LN_AT_avg
  /MISSING LISTWISE 
  /ANALYSIS LN_RT_vol_in Place_on_list FF_bin_in_deg  LN_AT_vol_in  FF_bin_close AT_bin_close LN_FF_bin_page  LN_AT_bin_page FF_rec AT_rec LN_AT_avg
  /PRINT UNIVARIATE INITIAL CORRELATION SIG DET KMO INV REPR AIC EXTRACTION ROTATION 
  /FORMAT SORT BLANK(.4) 
  /PLOT EIGEN ROTATION 
  /CRITERIA MINEIGEN(1)   ITERATE(25) /* MINEIGEN(1)  FACTORS(2) 
  /EXTRACTION PC 
  /CRITERIA ITERATE(25) 
  /ROTATION VARIMAX  /*   OBLIMIN VARIMAX
  /METHOD=CORRELATION.

* Perform a exploratory regressions using BACKWARD method*
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=BACKWARD LN_FF_bin_deg LN_FF_bin_in_deg LN_FF_bin_out_deg LN_AT_bin_deg LN_AT_bin_in_deg LN_AT_bin_out_deg LN_AT_avg LN_AT_vol_in LN_AT_vol_out
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).

*/ Perform a regression on a reduced list of factors*
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=BACKWARD LN_FF_bin_in_deg LN_FF_bin_out_deg LN_AT_bin_in_deg LN_AT_vol_in LN_AT_vol_out
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).

/* Optional: Save sub-communities to single files */
SELECT IF (COMMUNITY = "anime").
SAVE OUTFILE='D:\Dropbox\phD\analysis\results\results\spss\individual bonding\anime.sav' .
SAVE TRANSLATE OUTFILE='D:\Dropbox\phD\analysis\results\results\spss\individual bonding\anime.xls' 
  /TYPE=XLS 
  /VERSION=8 
  /MAP 
  /REPLACE 
  /FIELDNAMES 
  /CELLS=VALUES. 


/* Perform final 4 step regression */
/* First Step direct influence of ties, second step second order network metrics, third step tie strength */

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE ZPP 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=ENTER Place_on_list 
   /METHOD=ENTER LN_AT_vol_in FF_bin_in_deg 
  /METHOD=ENTER AT_bin_close FF_bin_close 
   /METHOD=ENTER LN_AT_bin_page  LN_FF_bin_page 
  /METHOD=ENTER AT_rec LN_AT_avg FF_rec 
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE ZPP 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=ENTER Place_on_list 
   /METHOD=ENTER LN_AT_vol_in  
  /METHOD=ENTER AT_bin_close  
   /METHOD=ENTER  LN_FF_bin_page 
  /METHOD=ENTER FF_rec 
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

* Alternative Perform final 4 step regression */
* First Step direct influence of ties, second step second order network metrics, third step tie strength, fourth step your outgoing measures*/
* THe reson for not using this regression are the hihger VIF scores ~ 7 in some measures. And from theory we know that indegree and outdegree are highly correlated *
* Especially when including the AT vol out it captures the most of the effect that has been described through the network measures*
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=ENTER LN_AT_vol_in FF_bin_in_deg 
  /METHOD=ENTER LN_AT_bin_close LN_AT_bin_page FF_bin_close LN_FF_bin_page 
  /METHOD=ENTER AT_rec LN_AT_avg FF_rec 
 /METHOD=ENTER LN_AT_vol_out FF_bin_out_deg
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).


* Because the direct indegrees are correlated with the resulting measures it might make less sense to put them in directly instead only regress the network measures *
* The VIF (multicollinearity) statistics indicate that it seems ok to use the indegrees as well espeically because the contribute the most *
* 
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=ENTER LN_AT_bin_close LN_AT_bin_page FF_bin_close LN_FF_bin_page 
  /METHOD=ENTER AT_rec LN_AT_avg FF_rec 
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

* Exploratory regression seeing the combined effects of in and out degrees alone *
* See how when controlling for AT outdegree the AT reciprocity becomes negative *
* This means that "controlling" for outdegree reciprocity is actually not that important!"
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=ENTER LN_AT_vol_in FF_bin_in_deg /* 
  /METHOD=ENTER AT_rec LN_AT_avg FF_rec 
  /METHOD=ENTER LN_AT_vol_out FF_bin_out_deg 
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID).

