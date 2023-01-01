insheet using "${DATA}/conso-elec-gaz-annuelle-par-secteur-dactivite-agregee-commune.csv", clear delimiter(";")
	rename annee year
	tab filiere
	keep consor code_commune filiere year
	keep if filiere == "Electricité"
	
	destring code_commune , replace force
	drop if code_commune > 95999
	rename code_commune depcom
	keep if year == 2019
	replace depcom = 75056 if floor(depcom / 1000) == 75
	replace depcom = 69123 if inrange(depcom, 69381, 69389)
	replace depcom = 13055 if inrange(depcom, 13201, 13216)	
	replace depcom = 16186 if depcom == 16010
	replace depcom = 2054 if depcom == 2695
	replace depcom = 19143 if depcom == 19092
	replace depcom = 24325 if depcom == 24089
	replace depcom = 24325 if depcom == 24314 
	replace depcom = 25185 if depcom == 25134
	replace depcom = 25375 if depcom == 25628 
	replace depcom = 26216 if depcom == 26219
	replace depcom = 56213 if depcom == 56049
	replace depcom = 85001 if depcom == 85307
	collapse (sum) consor, by(depcom) fast

save "${TMP}/main", replace


import excel using "${DATA}/base-pop-historiques-1876-2020.xlsx", sheet("pop_1876_2020") clear firstrow
	drop AM-BL
	keep CODGEO pop*
	reshape long pop, i(CODGEO) j(year)
	destring CODGEO, replace force
	drop if CODGEO > 95999
	rename CODGEO depcom
	replace depcom = 75056 if floor(depcom / 1000) == 75
	collapse (sum) pop, by(year depcom) fast
	keep if year == 2019
	merge 1:1 depcom using "${TMP}/main"
	drop _m
save "${TMP}/main", replace

use "${TMP}/data", replace
	destring insee, replace force
	drop if insee > 95999
	rename insee depcom
	merge 1:1 depcom using "${TMP}/main"
	drop _m
	
	gen elec_pc = consor / pop
	grmap, activate
	xtset, clear
	spset _ID
	replace elec_pc = floor(elec_pc *10)/10
	
	grmap elec_pc using "${TMP}/coor", id(_ID) ocolor(none ..) fcolor(Reds2) clnumber(15)  ///
	title("Consommation d'électricité (MWh par habitant)", size(*0.8))           ///
    subtitle("Consommation dans le résidentiel (2019)", size(*0.8))  ///
	legend(pos(8) ring(0) size(*.75) symx(*.75) symy(*.75) forcesize ) legstyle(3)
	graph export  "${FIG}/map2.png", as(png) replace
	
	