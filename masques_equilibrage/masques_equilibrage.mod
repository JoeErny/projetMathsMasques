/*********************************************
 * OPL 12.10.0.0 Model
 * Author: joeer
 * Creation Date: 5 févr. 2021 at 16:18:11
 *********************************************/

int NbTowns = ...; //N le nombre d’entrepôts
int LotSize = ...; //T la taille lot de transport
int PenaltyUnderStockTarget = ...; //PS  la pénalité appliquée pour chaque unité de stock final inférieur au stock visé.
int TransportCostPerUnitPerKm = ...; //CT le coût de transport par unité transportée par km
 
range Towns = 1..NbTowns;
string TownsName[Towns]=...; //Nom des villes
 
float Stock[Towns]=...; //S le stock courant dans l’entrepôt #i
float DemandPreviousYear[Towns]=...; //P
float LoadCoast[Towns]=...; //CC le coût de chargement, par entrepôt #i
float Distance[Towns][Towns]=...; //D la distance de l’entrepôt #i vers l’entrepôt #j 
 
dvar float+ TotalCost;
dvar float+ CostBetweenTowns[Towns][Towns]; //Prix de trajet entre 2 villes
float FinalStock[Towns]; //Stock final
float TargetStock[Towns]; //Stock visé
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