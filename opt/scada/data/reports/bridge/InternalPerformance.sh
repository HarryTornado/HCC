#!/bin/bash

tc=$1
function trackblock {
	trackCircuit=$1
	maxtime=2
	tmptime=0
	flag=0
	t1=`date +%M%S%N | cut -b1-7`
	ret=`curl http://railwaystatemanager.TCMS:8080/track-circuit/$trackCircuit 2>/dev/null`
	status=${ret:6:2}

		while [[ $tmptime -le $maxtime && $status != 11 ]]
		do
			curl -X PUT --data "BlockTrack track-circuit=$trackCircuit" -H 'content-type:text/plain' http://routevalidation.TCMS:8080/cli 2>/dev/null
			ret=`curl http://railwaystatemanager.TCMS:8080/track-circuit/$trackCircuit 2>/dev/null`
			status=${ret:6:2}
			if [[ $status == 11 ]]
			then
				t2=`date +%M%S%N | cut -b1-7`		
				secTime=$(($(($((t2-t1))%60))/1000))
				nanoTime=$(($(($((t2-t1))%60))%1000))
				echo -e "\t Spent $secTime.$nanoTime sec to block track"			
			fi
			sleep 0.5
			tmptime=$((tmptime+1))
		done
		if [[$tmptime == 2]]
		then
			echo -e "\t Failed to block the track"
		fi
}
function trackUnblock {
	trackCircuit=$1
	maxtime=2
	tmptime=0
	t1=`date +%M%S%N | cut -b1-7`
	ret=`curl http://railwaystatemanager.TCMS:8080/track-circuit/$trackCircuit 2>/dev/null`
	status=${ret:6:2}

		while [[ $tmptime -le $maxtime && $status != 00 ]]
		do
			curl -X PUT --data "UnblockTrack track-circuit=$trackCircuit" -H 'content-type:text/plain' http://routevalidation.TCMS:8080/cli 2>/dev/null
			ret=`curl http://railwaystatemanager.TCMS:8080/track-circuit/$trackCircuit 2>/dev/null`
			status=${ret:6:2}
			if [[ $status == 00 ]]
			then
				t2=`date +%M%S%N | cut -b1-7`			
				secTime=$(($(($((t2-t1))%60))/1000))
				nanoTime=$(($(($((t2-t1))%60))%1000))
				#echo "Time Elapsed to Unblock $secTime.$nanoTime"
				echo -e "\t Spent $secTime.$nanoTime sec time to unblock track"				
			fi
				sleep 0.5
				tmptime=$((tmptime+1))			
		done
		
		
}

cat /opt/scada/data/RailwayData/RailwayTracks.xml | awk '/Track id/ && /circuit_name/ {print $5}' | sed 's/circuit_name="//' | sed 's/"//' >tmp

while read line 
do
	echo "testing track circuit $line ..."
	trackblock $line
	sleep 0.5
	trackUnblock $line
done < tmp

rm tmp
