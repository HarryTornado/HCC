#!/bin/bash
##################################################################################
#
# Summary for Points and the result is stored in Point_Summary_Test_$date.txt
#
#	1. Failure of Point.
#
#
#
##################################################################################

ints=(BBH BEL BLS BLY CAM CBE CFD CHL COB DNG EPP ERM FKS FSA FSB FSD FSE GRN HDB JLI KPK LAL MCD MRN MUL NME NMU NPT SDM SHM SKN SSN SSS SST STN STS SUN SYR UFD WFY WST)

resultFile="results/points/summary_at_`date +%I`_on_`date +%B-%d`.txt"

for it in ${ints[@]}
do
	cat results/points/${it}.txt | grep "Error: failed to t" > tmp
	sed -i 's/ Error: failed to turn//g' tmp
	sed -i 's/to reverse//g' tmp
	sed -i 's/\\t//g' tmp
	sed -i 's/ //g' tmp
	uniq tmp >> $resultFile

done

