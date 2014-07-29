#!/bin/bash

source programs/sumRV.txt



resultFile="results/rv_routes/summary_RV_Route_at_`date +%H%M`_on_`date +%d-%B-%Y`.txt"
resultFile=${resultFile/ /}

usage > $resultFile


sumDICInterlocking BBH Westrace
sumDICInterlocking BEL Westrace
sumDICInterlocking BLS WestLock
sumDICInterlocking BLY Westrace
sumDICInterlocking CAM WestLock
sumDICInterlocking CBE WestLock
sumDICInterlocking CFD WestLock
sumDICInterlocking CHL WestLock
sumDICInterlocking COB WestLock
sumDICInterlocking DNG WestLock
sumDICInterlocking EPP WestLock
sumDICInterlocking ERM Westrace
sumDICInterlocking FKS Westrace
sumDICInterlocking FSA Westrace
sumDICInterlocking FSB WestLock
sumDICInterlocking FSD WestLock
sumDICInterlocking FSE Westrace
sumDICInterlocking GRN Westrace
sumDICInterlocking HDB Westrace
sumDICInterlocking JLI Westrace
sumDICInterlocking KPK Westrace
sumDICInterlocking LAL Westrace
sumDICInterlocking MCD Westrace
sumDICInterlocking MRN Westrace
sumDICInterlocking MUL Westrace
sumDICInterlocking NME Westrace
sumDICInterlocking NMU Westrace
sumDICInterlocking NPT WestLock
sumDICInterlocking SDM WestLock
sumDICInterlocking SHM Westrace
sumDICInterlocking SKN WestLock
sumDICInterlocking SSN Westrace
sumDICInterlocking SSS Westrace
sumDICInterlocking SST WestLock
sumDICInterlocking STN WestLock
sumDICInterlocking STS WestLock
sumDICInterlocking SUN WestLock
sumDICInterlocking SYR Westrace
sumDICInterlocking UFD WestLock
sumDICInterlocking WFY Westrace
sumDICInterlocking WST Westrace

echo -e "
RV test result summarised in file $resultFile

Cheers!"
