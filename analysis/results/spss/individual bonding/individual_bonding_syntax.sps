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

* Transform the problematic ones *

COMPUTE LN_FF_bin_deg=LN(FF_bin_deg+1).
COMPUTE LN_FF_bin_in_deg=LN(FF_bin_in_deg+1). 
COMPUTE LN_FF_bin_out_deg=LN(FF_bin_out_deg+1). 
COMPUTE LN_AT_bin_deg=LN(AT_bin_deg+1).
COMPUTE LN_AT_bin_in_deg=LN(AT_bin_in_deg+1).
COMPUTE LN_AT_bin_out_deg=LN(AT_bin_out_deg+1).
COMPUTE LN_AT_avg=LN(AT_avg+1).
COMPUTE LN_AT_vol_in=LN(AT_vol_in+1). 
COMPUTE LN_AT_vol_out=LN(AT_vol_out+1). 
COMPUTE LN_RT_vol_in=LN(RT_vol_in+1). 
COMPUTE LN_RT_vol_out=LN(RT_vol_out+1). 

* Output a histogram of the transformed *

GRAPH
  /HISTOGRAM=LN_FF_bin_deg.
GRAPH
  /HISTOGRAM=LN_FF_bin_in_deg.
GRAPH
  /HISTOGRAM=LN_FF_bin_out_deg.
GRAPH
 /HISTOGRAM=LN_AT_bin_deg.
GRAPH
  /HISTOGRAM=LN_AT_bin_in_deg.
GRAPH
  /HISTOGRAM=LN_AT_bin_out_deg.
GRAPH
  /HISTOGRAM=LN_AT_avg.
GRAPH
  /HISTOGRAM=LN_AT_vol_in.
GRAPH
  /HISTOGRAM=LN_AT_vol_out.
GRAPH
  /HISTOGRAM=LN_RT_vol_in.
GRAPH
  /HISTOGRAM=LN_RT_vol_out.

* Perform a couple of regressions *

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=BACKWARD LN_FF_bin_deg LN_FF_bin_in_deg LN_FF_bin_out_deg LN_AT_bin_deg LN_AT_bin_in_deg LN_AT_bin_out_deg LN_AT_avg LN_AT_vol_in LN_AT_vol_out
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)..

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_vol_in 
  /METHOD=BACKWARD LN_FF_bin_in_deg LN_FF_bin_out_deg LN_AT_bin_in_deg LN_AT_vol_in LN_AT_vol_out
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).
