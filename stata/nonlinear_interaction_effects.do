*hyun woo kim, chungbuk national university, 2025



*data-generating process

	clear all
	set seed 1234
	set obs 1000

	gen x1=rnormal(0, 1)
	gen x2=rnormal(1, 2)<0.5
	
	local b0=0
	local b1=-1
	local b2=1
	local b12=0.5

	gen xb=`b0'+`b1'*x1+`b2'*x2+`b12'*x1*x2
	gen p=invlogit(xb)     // 1/[1+exp(-xb)]
	gen y=runiform()<p     // introduce random disturbance

	
	
	
*linear probability model

	est clear
	eststo: logit y c.x1##i.x2
	estat class
	eststo: reg y c.x1##i.x2
	predict yhat
	gen correct=(yhat>0.5&y==1)|(yhat<0.5&y==0)
	esttab
	esttab using "table1.csv", nonotes csv se nogap replace ///
		star(* 0.05 ** 0.01 *** 0.001) b(%4.3f) ///
		stats(N ll r2_p aic, fmt(%4.0f %4.2f %10.2f %4.2f))

		
		

	
	
*predicted probabilities
	
	logit y c.x1##i.x2
	su x1 x2
	margins, at(x1=(-3(0.5)3)) by(x2)
	marginsplot, recast(line) ciopts(recast(rarea) color(%20) lcolor(%1)) ///
				title("") ///
				xtitle("X{subscript:1}") ///
				ytitle("Predicted probabilities") ///
				xlabel(-3(1)3, nogrid) ylabel(, nogrid) ///
				legend(pos(6) col(2) order(1 "X{subscript:2}=0" 2 "X{subscript:2}= 1")) ///
				plotregion(margin(zero))
	graph export "fig4.png", width(2000) replace
	
	*wald tests for local interaction effects (table 3)
	margins r.x2, at(x1=(-3(0.5)3)) post
	
	*manual computations
	di (_b[r1vs0.x2@1bn._at]/_se[r1vs0.x2@1bn._at])^2     // (1 vs 0)  1 => 1.41
	logit y c.x1##i.x2          // won't work unless you use post option above
	margins, at(x1=(-3(0.5)3)) by(x2) post
	di _b[1bn._at#1.x2]-_b[1bn._at#0bn.x2]     // _b[r1vs0.x2@1bn._at] => .037
	
		
		
		
				
*conditional marginal effects by another covariate

	logit y c.x1##i.x2
	su x1 x2
	margins, dydx(x2) at(x1=(-3(0.1)3))
	marginsplot, recast(line) ciopts(recast(rarea) color(%20) lcolor(%1)) ///
				title("") ytitle("Average marginal effects of X{subscript:2}") ///
				xtitle("X{subscript:1}") yline(0, lcolor(black%20) lwidth(thin)) ///
				xlabel(-3(1)3, nogrid) ylabel(, nogrid) ///
				plotregion(margin(zero))
	graph export "fig5.png", width(2000) replace
	
	

	
*the average interaction marginal effects

	*ai and norton (2003)
	gen x12=x1*x2
	logit y x1 x2 x12
	*inteff y x1 x2 x12, savegraph1("figS1.png", replace) savegraph2("figS2.png", replace)

	*margins with contrast
	logit y c.x1##i.x2
	margins r.x2, dydx(x1) post           //ginteff, dydxs(x1 x2)
	coefplot, lcolor(black) mcolor(black) msymbol(Oh) msize(large) ///
	          ciopts(recast(rcapsym) msymbol(pipe) ///
			         lcolor(black) msize(huge) mcolor(black)) ///
			  ytitle("") xtitle("Interaction effects", size(huge)) ///
			  xlabel(0(.01).12, labsize(huge) grid) ylabel("", nogrid) ysize(3) xsize(8) 
	graph export "fig6.png", width(2000) replace

		

*computing the marginal odds ratios

	*canned command for marginal odds ratio of x2, when interacted with x1
	logit y c.x1##i.x2, or r
	lnmor c.x1, at(x2) or post	
	di exp(_b[2:x1])/exp(_b[1:x1])   //"exp(_b[1.x2#c.x1])" after "logit y c.x1##i.x2, or"
	coefplot, keep(1:x1 2:x1) rename(1:x1="X{subscript:2}=0" 2:x1="X{subscript:2}=1") ///
	          eqrename(1="" 2="") eform ysize(3) xsize(8) ///
			  lcolor(black) mcolor(black) msymbol(Oh) msize(large) ///
			  ciopts(recast(rcapsym) msymbol(pipe) ///
					 lcolor(black) msize(huge) mcolor(black)) ///
			  ytitle("") xtitle("Marginal odds ratio", size(huge)) ///
			  xlabel(.3(.1).8, labsize(huge) grid) ylabel(, labsize(huge) nogrid)
	graph export "fig7.png", width(2000) replace
	