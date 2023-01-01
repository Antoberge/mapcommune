clear all
set more off
cd "${HOME}"

shp2dta using "${DATA}/shp/communes-20220101", data("${TMP}/data") coor("${TMP}/coor") replace
use "${TMP}/coor", replace
	geo2xy _Y _X, proj (web_mercator) replace
	sort _ID
save, replace


	
	