#!/bin/bash

source programs/sumPoints.txt

resultFile="results/points/summary_at_`date +%H%M`_on_`date +%d-%B-%Y`.txt"
resultFile=${resultFile/ /}

usage > $resultFile

sumPointsInterlocking BBH Westrace
sumPointsInterlocking BEL Westrace
sumPointsInterlocking BLS WestLock
sumPointsInterlocking BLY Westrace
sumPointsInterlocking CAM WestLock
sumPointsInterlocking CBE WestLock
sumPointsInterlocking CFD WestLock
sumPointsInterlocking CHL WestLock
sumPointsInterlocking COB WestLock
sumPointsInterlocking DNG WestLock
sumPointsInterlocking EPP WestLock
sumPointsInterlocking ERM Westrace
sumPointsInterlocking FKS Westrace
sumPointsInterlocking FSA Westrace
sumPointsInterlocking FSB WestLock
sumPointsInterlocking FSD WestLock
sumPointsInterlocking FSE Westrace
sumPointsInterlocking GRN Westrace
sumPointsInterlocking HDB Westrace
sumPointsInterlocking JLI Westrace
sumPointsInterlocking KPK Westrace
sumPointsInterlocking LAL Westrace
sumPointsInterlocking MCD Westrace
sumPointsInterlocking MRN Westrace
sumPointsInterlocking MUL Westrace
sumPointsInterlocking NME Westrace
sumPointsInterlocking NMU Westrace
sumPointsInterlocking NPT WestLock
sumPointsInterlocking SDM WestLock
sumPointsInterlocking SHM Westrace
sumPointsInterlocking SKN WestLock
sumPointsInterlocking SSN Westrace
sumPointsInterlocking SSS Westrace
sumPointsInterlocking SST WestLock
sumPointsInterlocking STN WestLock
sumPointsInterlocking STS WestLock
sumPointsInterlocking SUN WestLock
sumPointsInterlocking SYR Westrace
sumPointsInterlocking UFD WestLock
sumPointsInterlocking WFY Westrace
sumPointsInterlocking WST Westrace

echo -e "
point test result summarised in file $resultFile

Cheers!"

