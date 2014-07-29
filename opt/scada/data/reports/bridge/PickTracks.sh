#!/bin/bash
function usage {
echo -e "#================================================================================================="
echo -e "#"
echo -e "#"
echo -e "# 	This File is used to collect the Tracks deals with time"	
echo -e "#"
echo -e "#	Report:"
echo -e "#"
echo -e "#		Pick Up: Expected is 4-7 Seconds"
echo -e "#"
echo -e "#		1. Picking of Tracks less than 4 seconds"
echo -e "#		2. Picking of Tracks more than 7 seconds"
echo -e "#"
echo -e "#		Drop: Expected is 0-3 Seconds"
echo -e "#"
echo -e "#		3. Droping of Tracks less than 0 seconds"
echo -e "#		4. Droping of Tracks more than 3 seconds"	
echo -e "#"
echo -e "#================================================================================================="
}


function picktrack {
	it=$1
	type=$2

	#variable declaration:
	drop_time_low_limit=0;
	drop_time_high_limit=3;
	pick_up_time_low_limit=4;
	pick_up_time_high_limit=7;

	tmpFile="tmp.`date +%k%M%S%N`"
	tmpFile=${tmpFile/ /}

	echo -e "\n=========================================================================================" >> $resultFile
	echo -e "\nTrack test summary for ${type} interlocking ${it}...." >> $resultFile
	echo -e "\nPicking of Tracks less than 4 seconds... ">> $resultFile
	echo -e "\n\t\tTrack Number\tPickup Time" >> $resultFile

	#Picking of Tracks less than 4 seconds or more than 7 seconds
	cat results/tracks/${it}.txt | awk '
		BEGIN {pick_up_time_low_limit=4; pick_up_time_high_limit=7;count=0}

		/Spent/ && /pick/ \
			{ if ( $2 < pick_up_time_low_limit) \
				{count++; print "\t\t "$7"\t"$2 }}
		END {
			if (count!=0)
			{print "\n\t Total Number of Tracks: " count}}' >> $resultFile
	
	#Picking of Tracks more than 7 seconds
	echo -e "\nPicking of Tracks less than more than 7 seconds... ">> $resultFile
	echo -e "\n\t\tTrack Number\tPickup Time" >> $resultFile
	cat results/tracks/${it}.txt | awk '
		BEGIN {pick_up_time_high_limit=7;count=0}

		/Spent/ && /pick/ \
			{
			if ( $2  > pick_up_time_high_limit) 
				{count++;print "\t\t "$7"\t"$2 }}
			END {
			if (count != 0)
					{print "\n\t Total Number of Tracks: " count}}' >> $resultFile

	#Droping of Tracks less than 0 seconds or more than 3 seconds
	echo -e "\nDroping of Tracks less than 0 seconds... ">> $resultFile
	echo -e "\n\t\tTrack Number\tDrop Time" >> $resultFile
	cat results/tracks/${it}.txt | awk '
		BEGIN {drop_time_low_limit=0;drop_time_high_limit=3;count=0}

		/Spent/ && /drop/ \
			{if ($2< drop_time_low_limit ) \
				{count++;print "\t\t "$6"\t"$2 }}
			END {
			if (count != 0)
					{print "\n\t Total Number of Tracks: " count}}' >> $resultFile

	#Droping of Tracks more than 3 seconds
	echo -e "\nDroping of Tracks more than 3 seconds... ">> $resultFile
	echo -e "\n\t\tTrack Number\tDrop Time" >> $resultFile
	cat results/tracks/${it}.txt | awk '
		BEGIN {drop_time_high_limit=3;count=0}

		/Spent/ && /drop/ \
			{
			if ($2>drop_time_high_limit) 
				{count++;print "\t\t "$6"\t"$2 }}
			END {
			if (count != 0)
					{print "\n\t Total Number of Tracks: " count }}' >> $resultFile
}

resultFile="results/tracks/summary_track_time_at_`date +%H%M`_on_`date +%d-%B-%Y`.txt"
resultFile=${resultFile/ /}

usage > $resultFile

picktrack BBH Westrace
picktrack BEL Westrace
picktrack BLS WestLock
picktrack BLY Westrace
picktrack CAM WestLock
picktrack CBE WestLock
picktrack CFD WestLock
picktrack CHL WestLock
picktrack COB WestLock
picktrack DNG WestLock
picktrack EPP WestLock
picktrack ERM Westrace
picktrack FKS Westrace
picktrack FSA Westrace
picktrack FSB WestLock
picktrack FSD WestLock
picktrack FSE Westrace
picktrack GRN Westrace
picktrack HDB Westrace
picktrack JLI Westrace
picktrack KPK Westrace
picktrack LAL Westrace
picktrack MCD Westrace
picktrack MRN Westrace
picktrack MUL Westrace
picktrack NME Westrace
picktrack NMU Westrace
picktrack NPT WestLock
picktrack SDM WestLock
picktrack SHM Westrace
picktrack SKN WestLock
picktrack SSN Westrace
picktrack SSS Westrace
picktrack SST WestLock
picktrack STN WestLock
picktrack STS WestLock
picktrack SUN WestLock
picktrack SYR Westrace
picktrack UFD WestLock
picktrack WFY Westrace
picktrack WST Westrace


echo -e "
track test result summarised in file $resultFile

Cheers!"


