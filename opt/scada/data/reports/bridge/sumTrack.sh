#!/bin/bash
function usage {
echo "#================================================================================================="
echo "#"
echo "#	    The track test results would be sumarrised in the file track_test_summary_${date}.txt"
echo "#"
echo "#	    for each of the interlockings, the summary would include the following sections:"
echo "#		1. URI not at all define in the "
echo "#			/opt/scada/var/${domain}/TrafficSimulator/A/trafficSim.cfg.xml"
echo "#		   file."
echo "#"
echo "#		2. tracks failed to pick or drop, which usually implies URI defined in the "
echo "#		   the file"
echo "#			/opt/scada/var/${domain}/TrafficSimulator/A/trafficSim.cfg.xml"
echo "#		   but probably not properly defined."
echo "#"
echo "#================================================================================================="
}

ints=(BBH BEL BLS BLY CAM CBE CFD CHL COB DNG EPP ERM FKS FSA FSB FSD FSE GRN HDB JLI KPK LAL MCD MRN MUL NME NMU NPT SDM SHM SKN SSN SSS SST STN STS SUN SYR UFD WFY WST)

resultFile="results/tracks/summary_at_`date +%I`_on_`date +%B-%d`.txt"

usage > $resultFile

for it in ${ints[@]}
do
	echo -e "\n=========================================================================================" >> $resultFile
	echo -e "\nTrack test summary for interlocking ${it}...." >> $resultFile
	
	echo -e "\n\ttracks for which URI is not defined at all:" >> $resultFile

	# check for URI errors
	cat results/tracks/${it}.txt | grep "URI" > tmp
	sed -i 's/URI null for //g' tmp 
	sed -i 's/ //g' tmp
	sed -i 's/\\t//g' tmp
	cat tmp | uniq | awk '{print "\t\t", $1}' >> $resultFile

	# check for tracks that do not pick or drop properly
	echo -e "\n\ttracks which can not picked up or dropped properly:" >> $resultFile
	cat results/tracks/${it}.txt | grep "Error:" > tmp
	sed -i 's/Error: failed to pick up //g' tmp
	sed -i 's/Error: failed to drop //g' tmp
	sed -i 's/ //g' tmp
	sed -i 's/\\t//g' tmp
	cat tmp | uniq | awk '{print "\t\t", $1}' >> $resultFile

	# check to see if every track in the interlocking failed
	failedCount=`cat tmp | wc -l`
	if [[ "$failedCount" != "0" ]]
	then
		okCount=`cat results/tracks/${it}.txt | grep "Spent" | wc -l`
		if [[ "$okCount" == "0" ]]
		then
			echo -e "\n\tNotice: all the tracks in the interlocking ${it} are not working\n" >> $resultFile
		fi
	else
		okCount=`cat results/tracks/${it}.txt | grep "Spent" | wc -l`
		if [[ "$okCount" == "0" ]]
		then
			echo -e "\n\tNotice: no tracks found in interlocking ${it}.\n" >> $resultFile
		fi
	fi
done

echo "track test summary was saved to $resultFile .... Cheers!"
