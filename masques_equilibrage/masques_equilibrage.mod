/*********************************************
 * OPL 12.10.0.0 Model
 * Author: joeer
 * Creation Date: 5 f�vr. 2021 at 16:18:11
 *********************************************/

int NbTowns = ...; //N le nombre d�entrep�ts
int LotSize = ...; //T la taille lot de transport
int PenaltyUnderStockTarget = ...; //PS  la p�nalit� appliqu�e pour chaque unit� de stock final inf�rieur au stock vis�.
int TransportCostPerUnitPerKm = ...; //CT le co�t de transport par unit� transport�e par km
 
range Towns = 1..NbTowns;
string TownsName[Towns]=...; //Nom des villes
 
float Stock[Towns]=...; //S le stock courant dans l�entrep�t #i
float DemandPreviousYear[Towns]=...; //P
float LoadCoast[Towns]=...; //CC le co�t de chargement, par entrep�t #i
float Distance[Towns][Towns]=...; //D la distance de l�entrep�t #i vers l�entrep�t #j 
 
dvar float+ TotalCost;
dvar float+ CostBetweenTowns[Towns][Towns]; //Prix de trajet entre 2 villes
float FinalStock[Towns]; //Stock final
float TargetStock[Towns]; //Stock vis�
float TotalPreviousYearStock; //N-1
dvar float+ TotalTargetStock; //
float TotalStock;
dvar boolean HasPenalty[Towns];

minimize TotalCost;
 
subject to {
	//Calculed a cost between 2 towns
	forall (i in Towns, j in Towns){
		LoadCoast[i] + (TransportCostPerUnitPerKm * Distance[i][j]) == CostBetweenTowns[i][j];
		}
	//
	sum (i in Towns, j in Towns) CostBetweenTowns[i][j] == TotalCost;
	sum (i in Towns) TargetStock[i] == TotalTargetStock;
	sum (i in Towns) DemandPreviousYear[i] == TotalPreviousYearStock;
	sum (i in Towns) Stock[i] == TotalStock;
	forall( i in Towns) {
		DemandPreviousYear[i] * (TotalPreviousYearStock/TotalStock) == TargetStock[i];
	}
	/*sum (i in Towns){
	  if (FinalStock[i]<TargetStock[i]){
	    write("\n Penalty for " + Towns[i]);
	    ((TargetStock[i]-FinalStock[i]) * 1000 ) + TotalCost == TotalCost;
	  }*/
	  //Set penalty if TargetStock hasn't been reached
	  forall (i in Towns){
	  if (FinalStock[i]<TargetStock[i]){
	 	HasPenalty[i] == 1;
	  }
		}	 
	  //Add penalty(s) to TotalCost
	   forall (i in Towns){
			TotalCost + (TargetStock[i] - Stock[i] * PenaltyUnderStockTarget) == TotalCost;
		}
}