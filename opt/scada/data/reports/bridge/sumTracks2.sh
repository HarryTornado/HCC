#!/bin/bash

source programs/constants.txt
source programs/sumTracks.txt

resultFile="results/tracks/summary_at_`date +%H%M`_on_`date +%d-%B-%Y`.txt"
resultFile=${resultFile/ /}

usage > $resultFile

sumTracksInterlocking BBH Westrace
sumTracksInterlocking BEL Westrace
sumTracksInterlocking BLS WestLock
sumTracksInterlocking BLY Westrace
sumTracksInterlocking CAM WestLock
sumTracksInterlocking CBE WestLock
sumTracksInterlocking CFD WestLock
sumTracksInterlocking CHL WestLock
sumTracksInterlocking COB WestLock
sumTracksInterlocking DNG WestLock
sumTracksInterlocking EPP WestLock
sumTracksInterlocking ERM Westrace
sumTracksInterlocking FKS Westrace
sumTracksInterlocking FSA Westrace
sumTracksInterlocking FSB WestLock
sumTracksInterlocking FSD WestLock
sumTracksInterlocking FSE Westrace
sumTracksInterlocking GRN Westrace
sumTracksInterlocking HDB Westrace
sumTracksInterlocking JLI Westrace
sumTracksInterlocking KPK Westrace
sumTracksInterlocking LAL Westrace
sumTracksInterlocking MCD Westrace
sumTracksInterlocking MRN Westrace
sumTracksInterlocking MUL Westrace
sumTracksInterlocking NME Westrace
sumTracksInterlocking NMU Westrace
sumTracksInterlocking NPT WestLock
sumTracksInterlocking SDM WestLock
sumTracksInterlocking SHM Westrace
sumTracksInterlocking SKN WestLock
sumTracksInterlocking SSN Westrace
sumTracksInterlocking SSS Westrace
sumTracksInterlocking SST WestLock
sumTracksInterlocking STN WestLock
sumTracksInterlocking STS WestLock
sumTracksInterlocking SUN WestLock
sumTracksInterlocking SYR Westrace
sumTracksInterlocking UFD WestLock
sumTracksInterlocking WFY Westrace
sumTracksInterlocking WST Westrace

echo -e "
track test result summarised in file $resultFile

Cheers!"

