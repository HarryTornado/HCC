#!/bin/bash

function usage {
echo -e "#==================================================================================================================================="
echo -e "#"
echo -e "#"
echo -e "# 	For each of the interlockings the summary of RV test would include the following section"	
echo -e "#"
echo -e "#	Report:"
echo -e "#"
echo -e "#		1. Route set, Time taken to Route Set, Average time taken to set, Maximum and Minimum time to Set route in each interlocking."
echo -e "#"
echo -e "#		2. Route Set but Entry Signal Not Cleared."	
echo -e "#"
echo -e "# 		3. Routes Successfully Cancelled."
echo -e "#"
echo -e "# 		4. Signal Failed to Cancel"
echo -e "#"
echo -e "#		5. Routes failed to set but stored in StoredRouteList."
echo -e "#"
echo -e "# 		6. Routes failed to set and not stored in StoredRouteList."
echo -e "#"
echo -e "# 		7. Point neither in correct position nor Locked."
echo -e "#"
echo -e "# 		8. Point is locked but in Wrong position."
echo -e "#"
echo -e "#		9. Point is in correct position but not locked"
echo -e "#===================================================================================================================================="
}

function sumDICInterlocking {
 it=$1
 type=$2
	#echo -e "\n============================================================================================================================" >> $resultFile
	#echo -e "\n \nRV test summary for ${type} interlocking ${it}.... ">> $resultFile
	
	
	#creation of patterns	
	cat results/rv_routes/$it.txt | sed 's/->/ -> /' | sed 's/:/ :/' | awk -v interlocking="${it}" -v intType="${type}" ' 
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
		signalNotClearbutStoredCount=0;
		routefound="false";
		cancelsignal="false";		
		}

		/testing route/ {
                	route = $3;
                	entrySignal = $5;
			totalRouteCount++;
			{getline;gsub(/can/,"caan")}
			rtClear="null"
			meaningfulcancel="no";
			storedRoute="false";
	##----------------------------------------------------------------------------------------------------------------------------------------##
                	setRouteOkPtn = "Spent.*seconds to set route " route".*";
			signalNotClearRtSet = "Error : the entry signal.* " entrySignal ".*" route ".*not cleared. But the route is set";	
	##----------------------------------------------------------------------------------------------------------------------------------------##
			cancelRouteOkPtn = "Spent.*seconds to cancel signal "entrySignal;
			cancelRouteNotOkptn = "Error : can not cancel signal "entrySignal;
	##----------------------------------------------------------------------------------------------------------------------------------------##
			signalNotClearbutStoredPtn = "Error : the entry signal.*" entrySignal ".*" route ".*not cleared. The route is not set at all. However, the route is stored.";		
			signalNotClearPtn = "Error : the entry signal.*" entrySignal ".*" route ".*not cleared. The route is not set at all";
	##----------------------------------------------------------------------------------------------------------------------------------------##
                	pntNolockNopostion = "Neither in correct position nor locked";
			pntlockNoposition = "Locked but in wrong position";
			pntNoloc = "checking that point.*has been locked.*In correct position but not locked";
	##----------------------------------------------------------------------------------------------------------------------------------------##	
			 
        	}

		##Successfully Route Set...
		 $0 ~ setRouteOkPtn {	
			meaningfulcancel="yes";													
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
			if ( meaningfulcancel == "yes") {											
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
				if ( meaningfulcancel == "yes") {
					sigNotCancel[sigNotCancelCount]=entrySignal;
					sigNotCancelRoute[sigNotCancelCount]=route;
					sigNotCancelCount++;												
				}
			}

		##Entry Signal Not Cleared and Route not Set but stored ...
		$0 ~ signalNotClearbutStoredPtn {			
			signalNotClearbutStoredSig[signalNotClearbutStoredCount] = entrySignal;
			signalNotClearbutStoredRoute[signalNotClearbutStoredCount] = route;
			signalNotClearbutStoredCount++;
			rtClear="null"
			storedRoute="true"
			
			}

		##Entry Signal Not Cleared, Route not Set and not Stored ...		
		$0 ~ signalNotClearPtn {
			if( storedRoute == "false")
				{			
				entSignal[signalNotClearPtnCount] = entrySignal;
				entSignalRoute[signalNotClearPtnCount]=route;
				signalNotClearPtnCount++;
				rtClear="null"
				}
			}

		

		##Entry Signal is Not Cleared but Route is Set...
		$0 ~ signalNotClearRtSet {
				meaningfulcancel="yes";							
				entSignalNotClear[signalNotClearRtSetCount]=entrySignal;
				entSignalNotClearRouteSet[signalNotClearRtSetCount]=route;
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

		##Point is in correct position but not locked..
		$0 ~ pntNoloc {		
			
				pntNLSetSignal[pntNolocCount]=entrySignal;	
				pntNLSetRoute[pntNolocCount]=route;
				pntSet[pntNolocCount]=$4;
				pntNolocCount++;						
			}
		
		END {

	printf("\n============================================================================================================================\n");
			printf("\nRV route tests summary for %s interlocking %s (%d routes in total)....\n", intType, interlocking, totalRouteCount);
			printf("\n\t 1.  Routes Successfully Set (%d)...\n",routeSetOkCount);
			printf("\t\tRoute \t\t\tTime: \n");
			for (i = 0; i<routeSetOkCount;i++)			
				printf("\t\t%s\t\t%0.4f\n",rtSet[i],rtSetTm[i]);
			if(routeSetOkCount!=0)
			printf("\n\t\t Average Time : %0.4f\t Max : %0.4f\t Min : %0.4f\n", sumSetRoute/routeSetOkCount,maxSetRoute,minSetRoute);


			printf("\n\t 2. Route Set but Entry Signal Not Cleared (%d)..\n", signalNotClearRtSetCount)
			printf("\t\tSignal \t\t\tRoute: \n");
			for (i=0; i<signalNotClearRtSetCount; i++)
				printf("\t\t%s\t\t%s\n", entSignalNotClear[i],entSignalNotClearRouteSet[i]);
	##----------------------------------------------------------------------------------------------------------------------------------------##
			printf("\n\t 3. Routes Successfully Cancelled (%d)...\n", routeCancelFailedCount);
			printf("\t\tRoute \t\t\tTime: \n");
			for (i = 0; i<routeCancelFailedCount;i++)
				printf("\t\t%s\t\t%0.4f\n",rtcancel[i],rtcanceltm[i]);
			if(routeCancelFailedCount!=0)
			printf("\n\t\t Average Time : %0.4f\t Max : %0.4f\t Min : %0.4f\n", sumCanRoute/routeCancelFailedCount,maxCanRoute,minCanRoute);

			printf("\n\t 4. Signal failed to cancel (%d)...\n", sigNotCancelCount);
			printf("\t\tSignal \t\t\tRoute: \n");
			for (i=0; i<sigNotCancelCount; i++)				
				printf("\t\t%s\t\t%s\n",sigNotCancel[i],sigNotCancelRoute[i]);
	##----------------------------------------------------------------------------------------------------------------------------------------##
	
			printf("\n\t 5. Routes failed to set but stored in StoredRouteList (%d)...\n", signalNotClearbutStoredCount);
			printf("\t\tSignal \t\t\tRoute: \n");
			for (i=0; i<signalNotClearbutStoredCount; i++)
				printf("\t\t%s\t\t%s\n", signalNotClearbutStoredSig[i], signalNotClearbutStoredRoute[i]);

			printf("\n\t 6. Routes failed to Set and not stored in StoredRouteList (%d) ...\n", signalNotClearPtnCount);
			printf("\t\tSignal \t\t\tRoute: \n");
			for (i=0; i<signalNotClearPtnCount; i++)
				printf("\t\t%s\t\t%s\n", entSignal[i],entSignalRoute[i]);

			
	##----------------------------------------------------------------------------------------------------------------------------------------##
			printf("\n\t 7. Point neither in correct position Nor locked(%d)... \n", pntNolockNopostionCount);	
			printf("\t\tSignal \t\tRoute\t\tPoint Number: \n");	
			for (i=0; i<pntNolockNopostionCount; i++)
				printf("\t\t%s\t\t%s\t%s\n",pntNLNPSignal[i],pntNLNPRoute[i],pntNLNP[i]);
			
			printf("\n\t 8. Point is locked but in Wrong position (%d).. \n", pntlockNopostionCount);	
			printf("\t\tSignal \t\tRoute\t\tPoint Number: \n");	
			for (i=0; i<pntlockNopostionCount; i++)
				printf("\t\t%s\t\t%s\t%s\n",pntLNPSignal[i],pntLNPRoute[i],pntLNP[i]);
	
			
			printf("\n\t 9. Point is in correct position but not locked (%d)... \n", pntNolocCount);	
			printf("\t\tSignal \t\tRoute \t\tPoint Number: \n");	
			for (i=0; i<pntNolocCount; i++)
				printf("\t\t%s\t\t%s\t%s\n",pntNLSetSignal[i],pntNLSetRoute[i],pntSet[i]);
	##----------------------------------------------------------------------------------------------------------------------------------------##
			
			
		
		}'  >> $resultFile
		
		
		

}



resultFile="results/rv_routes/summary_RV_Route_at_`date +%H%M`_on_`date +%d-%B-%Y`.txt"
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
RV test result summarised in file $resultFile

Cheers!"
