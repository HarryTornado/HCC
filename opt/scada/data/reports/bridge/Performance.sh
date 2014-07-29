#!/bin/bash

ints=(BBH BEL BLS BLY CAM CBE CFD CHL COB DNG EPP ERM FKS FSA FSB FSD FSE GRN HDB JLI KPK LAL MCD MRN MUL NME NMU NPT SDM SHM SKN SSN SSS SST STN STS SUN SYR UFD WFY WST)
echo -e "Performance Test includes( TCMS_SyRS_1193, TCMS_SyRS_1217, TCMS_SyRS_1218, TCMS_SyRS_1216, TCMS_SyRS_1192, TCMS_SyRS_1219 ) Average spent time is greater than 3 sec " > PeformanceSummary.txt
declare -a trackblock
declare -a trackunblock
trackblockcount=0;
trackunblockcount=0;
function sumPerformance {
	type=$1
	for int in ${ints[@]}
		{
			cat results/$type/$int.txt | sed 's/:/ /' | awk -v Int=$int -v testType=$type '
				BEGIN {
				count = 0
				rtHighSetTimeCount =0;
				rtHighCancelTimeCount = 0;
				rtPerforTime = 3
				}
				/Spent/ && /set/ {
					if ( $2 > rtPerforTime ) {
						rtHighSet[rtHighSetTimeCount] = $7
						rtHighSetTime[rtHighSetTimeCount] = $2
						rtHighSetTimeCount++
					}
				}	
				/Spent/ && /cancel/ {
					if ( $2 > rtPerforTime ) {
						rtHighCancel[rtHighCancelTimeCount]=$7
						rtHighCancelTime[rtHighCancelTimeCount]=$2
						rtHighCancelTimeCount++
					}				
				}		
				END {
					printf			("\n============================================================================================================================");
					printf("\n Performance Test(%s) for %s interlocking...\n",testType, Int);
					if( rtHighSetTimeCount != 0 || rtHighCancelTimeCount !=0 ) {
						if ( rtHighSetTimeCount != 0 ) {
							printf("\n\t1. Timetaken to set route more then %0.1f sec in %s interlocking are (%d)..." ,rtPerforTime,Int,rtHighSetTimeCount)
							printf("\n\tRoute")
							for ( i=0; i<rtHighSetTimeCount; i++)	
								printf("\n\t%s",rtHighSet[i]);
						}
						if ( rtHighCancelTimeCount !=0 ) {
							printf("\n\n\t2. Timetaken to cancel route more then %0.1f sec in %s interlocking are (%d)...",rtPerforTime, Int,rtHighCancelTimeCount)
							printf("\n\tRoute")
							for ( i=0; i<rtHighCancelTimeCount; i++)
								printf("\n\t%s",rtHighCancel[i]);
						}
					}
				}' >> PeformanceSummary.txt
		
	}	
}

function Trackblock {
	TrackId=$1
	TrackCircuit=$2
	status=0
	curl -X PUT --data "BlockTrack track-circuit=$TrackCircuit" -H 'content-type:text/plain' http://routevalidation.TCMS:8080/cli 2>/dev/null
	sleep 0.5
	ret=`curl http://railwaystatemanager.TCMS:8080/track-circuit/$TrackCircuit 2>/dev/null`
	#echo "ret is: "$ret
	status=${ret:6:2}
	if [[ $status == 11 || $status == 00 ]]; then
		if [[ $status != 11 ]]; then			
			echo -e "\t$TrackId \t\t$TrackCircuit \t\ttrack blocked more than 0.5 Seconds"
			trackblock[trackblockcount]=$TrackCircuit
			trackblockcount++	
		fi		
	fi
} >> PeformanceSummary.txt

function TrackUnblock {	
	TrackId=$1
	TrackCircuit=$2
	status=0
	curl -X PUT --data "UnblockTrack track-circuit=$TrackCircuit" -H 'content-type:text/plain' http://routevalidation.TCMS:8080/cli 2>/dev/null
	sleep 0.5
	ret=`curl http://railwaystatemanager.TCMS:8080/track-circuit/$TrackCircuit 2>/dev/null`
	#echo "ret is: "$ret
	status=${ret:6:2}
	if [[ $status == 11 || $status == 00 ]]; then
		if [[ $status != 00 ]]; then
			echo -e "\t$TrackId \t\t$TrackCircuit \t\ttrack unblocked more than 0.5 Seconds"
			trackunblock[trackblockcount]=$TrackCircuit
			trackunblockcount++
		fi
	fi
} >> PeformanceSummary.txt
sumPerformance dic_routes
sumPerformance rv_routes
echo "==============================================================================================================================" >> PeformanceSummary.txt
echo -e "\nPerformance test for Internal commands ( TCMS_SyRS_1200, TCMS_SyRS_1201 ) - Track Block and Unblock, Minimum the task should complete in 0.5 second for 95% of instances\n" >> PeformanceSummary.txt
echo -e "\tTrack Circuit" >> PeformanceSummary.txt
while read line
do
	#echo -e "\nTesting track circuit $line" >> PeformanceSummary.txt
	Trackblock $line
	sleep 1
	TrackUnblock $line
done < PerformanceTest/TrackCir.txt

for i in $(seq 1 $trackblockcount); do
	echo "\t ${trackblock[i]} "
done >> PeformanceSummary.txt

for i in $(seq 1 $trackunblockcount); do
	echo "\t ${trackunblock[i]} "
done >> PeformanceSummary.txt

