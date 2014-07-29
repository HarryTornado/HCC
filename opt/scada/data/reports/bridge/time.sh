#!/bin/bash

tc=$1
function trackblock {
	#Trackid=$1
	trackCircuit=$1
	maxtime=2
	tmptime=0
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
				echo -e "T1=$t1"
				echo -e "T2=$t2"
				echo "Blocked"				
				elapseTime=$((t2-t1))	
				echo $elapseTime			
				secTime=$(($(($((t2-t1))%60))/1000))
				nanoTime=$(($(($((t2-t1))%60))%1000))
				echo "Time Elapsed to block $secTime.$nanoTime"
			fi
		done
}
function trackUnblock {
	#Trackid=$1
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
				echo -e "T1=$t1"
				echo -e "T2=$t2"
				echo "Unblocked"
				elapseTime=$((t2-t1))	
				echo $elapseTime		
				secTime=$(($(($((t2-t1))%60))/1000))
				nanoTime=$(($(($((t2-t1))%60))%1000))
				echo "Time Elapsed to Unblock $secTime.$nanoTime"
			fi
		done
}



trackblock $tc
sleep 0.5
trackUnblock $tc
