#!/bin/bash

ints=(BBH BEL BLS BLY CAM CBE CFD CHL COB DNG EPP ERM FKS FSA FSB FSD FSE GRN HDB JLI KPK LAL MCD MRN MUL NME NMU NPT SDM SHM SKN SSN SSS SST STN STS SUN SYR UFD WFY WST)

for it in ${ints[@]}
do
	./track_test2.sh $it | tee  results/tracks/${it}.txt 
done
