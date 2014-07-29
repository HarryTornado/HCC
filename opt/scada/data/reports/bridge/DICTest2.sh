#!/bin/bash

function usage {
echo -e "#==================================================================================================================================="
echo -e "#"
echo -e "#"
echo -e "# 	For each of the interlockings the summary of DI&C test would include the following section"	
echo -e "#"
echo -e "#	Report:"
echo -e "#"
echo -e "#		1. Route set, Time taken to Route Set, Average time taken to set, Maximum and Minimum time to Set route in each interlocking."
echo -e "#"
echo -e "#		2. Route cancel, Time taken to Cancel route, Average time taken to Cancel, Maximum and Minimum time to Cancel route in each interlocking."	
echo -e "#"
echo -e "# 		3. Failed to Cancel the Signal."
echo -e "#"
echo -e "# 		4. Entry Signal Not Cleared and Route is not Set"
echo -e "#"
echo -e "#		5. Entry Signal Not Cleared but Route is Set"
echo -e "#"
echo -e "# 		6. Point is neither in Correct Position or not Locked."
echo -e "#"
echo -e "# 		7. Point is locked wrong Position."
echo -e "#"
echo -e "# 		8. Route is set, Signal is Clear, Point is in correct position but not locked."
echo -e "#"
echo -e "#		9. Route is set but Signal is not Cleared and Point is in correct position but not locked."
echo -e "#===================================================================================================================================="
}

function sumDICInterlocking {
 it=$1
 type=$2
	echo -e "\n============================================================================================================================" >> $resultFile
	echo -e "\n \nDI&C test summary for ${type} interlocking ${it}.... ">> $resultFile
	
	
	#creation of patterns	
	cat results/dic_routes/$it.txt | sed 's/->/ -> /' | sed 's/:/ :/' | awk '
		 BEGIN { 
		route = "null";                
		minSetRoute=100; maxSetRoute=0; countSetRoute=0;sumSetRoute=0;
		minCanRoute=100; maxCanRoute=0; countCanRoute=0;sumCanRoute=0;rtClear="null";
		routeSetOkCount = 0;
                routeCancelFailedCount = 0;
		sigNotCancelCount=0;
		signalNotClearPtnCount =0;
		signalNotClearRtSetCount= 0;
		pntNolockNopostionCount=0;
		pntlockNopositionCount =0;
		pntNolocNosetCount=0;
		pntNolocCount=0;
		routefound="false";
		cancelsignal="false";
		}

		/testing route/ {
                	route = $3;
                	entrySignal = $5;
			{getline;gsub(/can/,"caan")}
			rtClear="null"
                	setRouteOkPtn = "Spent.*seconds to set route " route;
			cancelRouteOkPtn = "Spent.*seconds to cancel signal "entrySignal;
			cancelRouteNotOkptn = "Error : can not cancel signal "entrySignal;
			signalNotClearPtn = "Error : the entry signal.*" entrySignal ".*" route ".*not cleared. And the route is not set";
			signalNotClearRtSet = "Error : the entry signal.* " entrySignal ".*" route ".*not cleared. But the route is set";	

                	pntNolockNopostion = "Neither in correct position nor locked";
			pntlockNoposition = "Locked but in wrong position";
			pntNoloc = "checking that point.*has been locked.*In correct position but not locked";
		
			 
        	}

		##Successfully Route Set...
		 $0 ~ setRouteOkPtn {														
			rtSet[routeSetOkCount]= route;
			rtSetTm[routeSetOkCount] = $2;
			routeSetOkCount++;			
			sumSetRoute=sumSetRoute+$2;
			if($2>maxSetRoute)
				maxSetRoute=$2;
			if($2<minSetRoute)
				minSetRoute=$2
			rtClear="Yes"
			}
		
		##Successfully Route Cancel...	
		$0 ~  cancelRouteOkPtn {
			for (i=0;i<routeCancelFailedCount;i++)
				{
					if ( route == rtcancel[i] ) {
						cancelsignal="true"
						break
					}else 
						cancelsignal= "false" 
						
				}
			if(cancelsignal == "false")
				{
					rtcancel[routeCancelFailedCount]= route;	
					rtcanceltm[routeCancelFailedCount]=$2;
					routeCancelFailedCount++
					sumCanRoute=sumCanRoute+$2;
					if($2>maxCanRoute)
						maxCanRoute=$2;
					if($2<minCanRoute)
						minCanRoute=$2;
				}
			}

		##Failed to cancel the Signal...	
		$0 ~ cancelRouteNotOkptn {	
				for (i=0; i<sigNotCancelCount; i++)
					{
						if ( route == sigNotCancelRoute[i] ){
							routefound="true"
							break}
						else
							{
							routefound="false"
							}
					}
				if (routefound=="false"){
					sigNotCancel[sigNotCancelCount]=entrySignal;
					sigNotCancelRoute[sigNotCancelCount]=route;
					sigNotCancelCount++;												
					}
			}

		##Entry Signal Not Cleared and Route not Set ...		
		$0 ~ signalNotClearPtn {			
			entSignal[signalNotClearPtnCount] = entrySignal;
			entSignalRoute[signalNotClearPtnCount]=route;
			signalNotClearPtnCount++
			rtClear="null"
			}

		##Entry Signal is Not Cleared but Route is Set...
		$0 ~ signalNotClearRtSet {
			entSignal1[signalNotClearRtSetCount]=entrySignal;
			entSignalRoute1[signalNotClearRtSetCount]=route;
			signalNotClearRtSetCount++;
			
			}

		##Route is not set due to Point neither in correct position nor locked..
		$0 ~ pntNolockNopostion {
			pntNLNPSignal[pntNolockNopostionCount]= entrySignal;
			pntNLNPRoute[pntNolockNopostionCount]=route;
			pntNLNP[pntNolockNopostionCount]=$4;
			pntNolockNopostionCount++
			}

		##Route is not set due Point is locked but in wrong position..
		$0 ~ pntlockNoposition {
			pntLNPSignal[pntlockNopositionCount]=entrySignal;
			pntLNPRoute[pntlockNopositionCount]=route;
			pntLNP[pntlockNopositionCount]=$4;
			pntlockNopositionCount++
			}

		##Route is set, Signal is Clear, Point is in correct position but not locked..
		$0 ~ pntNoloc {		
			if(rtClear=="Yes")
				{	
				pntNLSetSignal[pntNolocCount]=entrySignal;	
				pntNLSetRoute[pntNolocCount]=route;
				pntSet[pntNolocCount]=$4;
				pntNolocCount++;						
				}
			else
				{
		##Route is set but Signal is not Cleared and Point is in correct position but not locked..
				pntNLSignalnotSet[pntNolocNosetCount]=entrySignal;	
				pntNLRoutenotSet[pntNolocNosetCount]=route;
				pntnotSet[pntNolocNosetCount]=$4;
				pntNolocNosetCount++;
				}
			rtClear="null"
			}
		
		END {
			printf("\n\t Successfully Route Set...\n");
			printf("\t\tRoute\t\t\tSpent Time: (%d)\n",routeSetOkCount);
			for (i = 0; i<routeSetOkCount;i++)			
				printf("\t\t%s\t\t%0.4f\n",rtSet[i],rtSetTm[i]);
			if(routeSetOkCount!=0)
			printf("\n\t Average Time : %0.4f\t Max : %0.4f\t Min : %0.4f\n", sumSetRoute/routeSetOkCount,maxSetRoute,minSetRoute);
	
			printf("\n\t Successfully Route Cancel...\n");
			printf("\t\tRoute\t\t\tCancel Time: (%d)\n", routeCancelFailedCount);
			for (i = 0; i<routeCancelFailedCount;i++)
				printf("\t\t%s\t\t%0.4f\n",rtcancel[i],rtcanceltm[i]);
			if(routeCancelFailedCount!=0)
			printf("\n\t Average Time : %0.4f\t Max : %0.4f\t Min : %0.4f\n", sumCanRoute/routeCancelFailedCount,maxCanRoute,minCanRoute);

			printf("\n\t Failed to cancel the Signal...\n");
			printf("\t\tSignal Number\t\tRoute: (%d)\n",sigNotCancelCount);
			for (i=0; i<sigNotCancelCount; i++)				
				printf("\t\t%s\t\t%s\n",sigNotCancel[i],sigNotCancelRoute[i]);


			printf("\n\t Entry Signal Not Cleared and Route is not Set ...\n");
			printf("\t\tSignal Number\t\tRoute: (%d)\n", signalNotClearPtnCount);
			for (i=0; i<signalNotClearPtnCount; i++)
				printf("\t\t%s\t\t%s\n", entSignal[i],entSignalRoute[i]);

			printf("\n\t Entry Signal is Not Cleared but Route is Set...\n")
			printf("\t\tSignal Number\t\tRoute: (%d)\n", signalNotClearRtSetCount);
			for (i=0; i<signalNotClearRtSetCount; i++)
				printf("\t\t%s\t\t%s\n", entSignal1[i],entSignalRoute1[i]);

			printf("\n\t Point neither in correct position nor locked.. \n");	
			printf("\t\tSignal Number\t\tRoute\t\tPoint Number: (%d)\n", pntNolockNopostionCount);	
			for (i=0; i<pntNolockNopostionCount; i++)
				printf("\t\t%s\t\t%s\t%s\n",pntNLNPSignal[i],pntNLNPRoute[i],pntNLNP[i]);
			
			printf("\n\t Point is locked but in wrong position.. \n");	
			printf("\t\tSignal Number\t\tRoute\t\tPoint Number: (%d)\n", pntlockNopostionCount);	
			for (i=0; i<pntlockNopostionCount; i++)
				printf("\t\t%s\t\t%s\t%s\n",pntLNPSignal[i],pntLNPRoute[i],pntLNP[i]);
	
			
			printf("\n\t Route is set, Signal is Clear, Point is in correct position but not locked.. \n");	
			printf("\t\tSignal Number\t\tRoute\t\tPoint Number: (%d)\n", pntNolocCount);	
			for (i=0; i<pntNolocCount; i++)
				printf("\t\t%s\t\t%s\t%s\n",pntNLSetSignal[i],pntNLSetRoute[i],pntSet[i]);

			printf("\n\t Route is set but Entry Signal is not Cleared and Point is in correct position but not locked.. \n");	
			printf("\t\tSignal Number\t\tRoute\t\tPoint Number: (%d)\n", pntNolocNosetCount);	
			for (i=0; i<pntNolocNosetCount; i++)
				printf("\t\t%s\t\t%s\t%s\n",pntNLSignalnotSet[i],pntNLRoutenotSet[i],pntnotSet[i]);
			
		
		}'  >> $resultFile
		
		
		

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
