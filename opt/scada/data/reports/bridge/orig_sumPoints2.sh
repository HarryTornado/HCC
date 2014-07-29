#!/bin/bash
function usage {
echo -e "#================================================================================================================================="
echo -e "#"
echo -e "#\tFor each of the interlockings, the summary would include the following section:"
echo -e "#"
echo -e "#\t1.\tPoints failed "
echo -e "#"
echo -e "#\t2.\tTotal Number of Points turn to Normal/Reverse, Average time to turn Normal/Reverse, Max & Minimum time to turn Normal/Reverse"
echo -e "#"
echo -e "#=================================================================================================================================="
}

function sumTracksInterlocking {
	it=$1
	type=$2
	
	tmpFile="tmp.`date +%k%M%S%N`"
	tmpFile=${tmpFile/ /}

	echo -e "\n==========================================================================================================================" >> $resultFile
	echo -e "\nPoint test summary for ${type} interlocking ${it}...." >> $resultFile
	echo -e -n "\n\tpoints failed the test" >> $resultFile

	# check for Point Failure
	cat results/points/${it}.txt | grep "Error: failed to t" > ${tmpFile}
	sed -i 's/ Error: failed to turn//g' ${tmpFile}
        sed -i 's/to reverse//g' ${tmpFile}
	sed -i 's/to normal//g' ${tmpFile}
	sed -i 's/ //g' ${tmpFile}
	sed -i 's/\\t//g' ${tmpFile}
	count=`cat ${tmpFile} | sort | uniq | wc -l`
	echo -e " ($count):" >> $resultFile
	cat ${tmpFile} | sort | uniq | awk '{print "\t\t", $1}' >> $resultFile
	
	#check for average time to turn point to Normal and Reverse.
	echo -e "\n\tpoint successfully turn to Normal and Reverse:\n" >> $resultFile	
	cat results/points/${it}.txt | awk ' \
		BEGIN \
			{min=100; max=0; sum=0} \
		        /Spent/ && /normal/  \
			{ \
				sum+=$2; count++;			   
				if (max < $2) \
					max=$2;  
				if (min > $2) \
					min=$2; \
			} \
		END\
			{ \
				if (count != 0) \
					{printf "\t\t%d points turn to normal.\taverage:%0.4f\tminmax:%0.4f\tmax:%0.4f seconds\n",count,sum/count,min,max} \
		   	}' >> $resultFile

	cat results/points/${it}.txt | awk ' \
                BEGIN \
                        {min=100; max=0; sum=0} \
                        /Spent/ && /reverse/  \
                        { \
                                sum+=$2; count++;                          
                                if (max < $2) \
                                        max=$2;  
                                if (min > $2) \
                                        min=$2; \
                        } \
                END\
                        { \
                                if (count != 0) \
                                        {printf "\t\t%d points turn to reverse.\taverage:%0.4f\tminmax:%0.4f\tmax:%0.4f seconds\n",count,sum/count,min,max} \
                        }' >> $resultFile

	
	# check to see if every point in the interlocking failed
	failedCount=`cat ${tmpFile} | wc -l`
        if [[ "$failedCount" != "0" ]]
        then
                okCount=`cat results/points/${it}.txt | grep "Spent" | wc -l`
                if [[ "$okCount" == "0" ]]
                then
                        echo -e "\n\tNotice: all the points in the interlocking ${it} are not working\n" >> $resultFile
                fi
        else
                okCount=`cat results/points/${it}.txt | grep "Spent" | wc -l`
                if [[ "$okCount" == "0" ]]
                then
                        echo -e "\n\tNotice: no points found in interlocking ${it}.\n"  >> $resultFile
                fi
        fi
}

resultFile="results/points/summary_at_`date +%H%M`_on_`date +%d-%B-%Y`.txt"


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

echo -e "points test result summarised in file $resultFile

Cheers!"

