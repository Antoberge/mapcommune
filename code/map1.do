
import excel using "${DATA}/base-pop-historiques-1876-2020.xlsx", sheet("pop_1876_2020") clear firstrow
	drop AM-BL
	keep CODGEO pop*
	reshape long pop, i(CODGEO) j(year)
	destring CODGEO, replace force
	drop if CODGEO > 95999
	rename CODGEO depcom
	replace depcom = 75056 if floor(depcom / 1000) == 75
	collapse (sum) pop, by(year depcom) fast
save "${TMP}/main", replace

use "${TMP}/data", replace
	destring insee, replace force
	drop if insee > 95999
	rename insee depcom
	merge 1:m depcom using "${TMP}/main"
	drop _m
	drop if year == 2020
	drop if year < 2019 & year > 2010
	drop if year < 2010 & year > 2000
	bys year: egen totpop = sum(pop)
	replace pop = pop / totpop
	bys depcom : egen double maxpop = max(pop)
	gen foo = year if pop == maxpop
	drop if foo == .
	bys depcom: egen maxyear = max(foo)
	bys depcom: keep if _n == 1
	keep depcom maxyear _ID
	
	
	grmap, activate
	xtset, clear
	spset _ID
	spmap maxyear using "${TMP}/coor", id(_ID) ocolor(none ..) fcolor(Blues2) clnumber(21) clmethod(unique) ///
	title("Année de population maximale", size(*0.8))           ///
    subtitle("En proportion du total" " ", size(*0.8))  ///
	legend(pos(9) ring(1) size(*.75) symx(*.75) symy(*.75) forcesize )
	graph export  "${FIG}/map1.png", as(png) replace
	