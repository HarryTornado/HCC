#!/bin/bash

function usage {
echo -e "#==================================================================================================================================="
echo -e "#"
echo -e "#"
echo -e "# 	For each of the interlockings the summary of DI&C test would include the following section"	
echo -e "#"
echo -e "#	Report:"
echo -e "#"
echo -e "#		1. Route Failed to Set"
echo -e "#"
echo -e "#		2. Route failed to cancel"	
echo -e "#"
echo -e "# 		3. Number of routes are set, Average time taken to set, Maximum and Minimum time to Set route in each interlocking"
echo -e "#"
echo -e "#"
echo -e "#===================================================================================================================================="
}

function sumDICInterlocking {
 it=$1
 type=$2
	
	echo -e "\n=========================================================================================" >> $resultFile
	echo -e "\n \nDI&C test summary for ${type} interlocking ${it}.... ">> $resultFile
	echo -e -n "\n 1.Route Set Failed">> $resultFile

	#checking for Route failed to set
	RouteSet cleared 
	echo -e -n "\n 2.Route Cancel Failed">> $resultFile	
	#
	cat results/dic_routes/$it.txt |  grep "Error" |grep "cancel"|awk '{print $8}' |uniq | wc -l | awk '{printf "(%d)\n\n",$1}' >> $resultFile
	#checking for Route failed to cancel
	RouteSet cancel 
	
	#Listing Timing
	RouteTime 
	
}

function RouteSet {
	
	#echo "$2 value-> " $2
	if [ "$1" == "cleared" ]
	then
	# count the number of routes
	cat results/dic_routes/$it.txt | awk -v ptn="Error.*$1" '
		BEGIN {count=0}
		$0 ~ ptn \
		     {count++}
		 END { \
			printf "(%d):\n\n", count 
		    }'>> $resultFile
		
	fi
	#List the routes
	cat results/dic_routes/$it.txt | awk -v ptn="Error.*$1" '
				$0 ~ ptn {print "\t\t" $8 }'|uniq >> $resultFile
}


function RouteTime {


}


resultFile="results/dic_routes/summary_DIC_Route_at_`date +%H%M`_on_`date +%d-%B-%Y`.txt"
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
DIC test result summarised in file $resultFile

Cheers!"
