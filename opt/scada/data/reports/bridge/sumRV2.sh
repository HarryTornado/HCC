#!/bin/bash

source programs/sumRv.txt

resultFile="results/rv_routes/summary_at_`date +%H%M`_on_`date +%d-%B-%Y`.txt"
resultFile=${resultFile/ /}

usage > $resultFile

sumRVInterlocking BBH Westrace
sumRVInterlocking BEL Westrace
sumRVInterlocking BLS WestLock
sumRVInterlocking BLY Westrace
sumRVInterlocking CAM WestLock
sumRVInterlocking CBE WestLock
sumRVInterlocking CFD WestLock
sumRVInterlocking CHL WestLock
sumRVInterlocking COB WestLock
sumRVInterlocking DNG WestLock
sumRVInterlocking EPP WestLock
sumRVInterlocking ERM Westrace
sumRVInterlocking FKS Westrace
sumRVInterlocking FSA Westrace
sumRVInterlocking FSB WestLock
sumRVInterlocking FSD WestLock
sumRVInterlocking FSE Westrace
sumRVInterlocking GRN Westrace
sumRVInterlocking HDB Westrace
sumRVInterlocking JLI Westrace
sumRVInterlocking KPK Westrace
sumRVInterlocking LAL Westrace
sumRVInterlocking MCD Westrace
sumRVInterlocking MRN Westrace
sumRVInterlocking MUL Westrace
sumRVInterlocking NME Westrace
sumRVInterlocking NMU Westrace
sumRVInterlocking NPT WestLock
sumRVInterlocking SDM WestLock
sumRVInterlocking SHM Westrace
sumRVInterlocking SKN WestLock
sumRVInterlocking SSN Westrace
sumRVInterlocking SSS Westrace
sumRVInterlocking SST WestLock
sumRVInterlocking STN WestLock
sumRVInterlocking STS WestLock
sumRVInterlocking SUN WestLock
sumRVInterlocking SYR Westrace
sumRVInterlocking UFD WestLock
sumRVInterlocking WFY Westrace
sumRVInterlocking WST Westrace

echo -e "
rv_route test results summarised in file $resultFile

Cheers!"

