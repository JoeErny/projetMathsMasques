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
 
 //variables de décision
 
dvar float+ TotalCost;
dvar float+ CostBetweenTowns[Towns][Towns]; //Prix de trajet entre 2 villes
dvar float FinalStock[Towns]; //Stock final
dvar float TargetStock[Towns]; //Stock visé
dvar float TotalPreviousYearStock; //N-1
dvar float+ TotalTargetStock; //stock cible total
dvar float TotalFinalStock; //stock final total
dvar boolean HasPenalty[Towns]; //ville a pénalité

minimize TotalCost;
 
subject to {
	//Calculer le coût entre 2 villes
	forall (i in Towns, j in Towns){
		LoadCoast[i] + (TransportCostPerUnitPerKm * Distance[i][j]) == CostBetweenTowns[i][j];
	}
	
	//Définir le cout total
	sum (i in Towns, j in Towns) CostBetweenTowns[i][j] == TotalCost;
	
	//Définir le stock demandé total de l'an dernier
	sum (i in Towns) DemandPreviousYear[i] == TotalPreviousYearStock;
	
	//Définir stock total
	sum (i in Towns) Stock[i] == TotalFinalStock;
	
	
	//Définir le sock ciblé de la ville
	forall( i in Towns:TotalFinalStock>0) {
		DemandPreviousYear[i] * (TotalPreviousYearStock/TotalStock) == TargetStock[i];
	}
	
	
	// Definir sock ciblé total
	sum (i in Towns) TargetStock[i] == TotalTargetStock;

	 
	// Definir le tableau des villes qui ont une pénalité 
	forall (i in Towns){
		if (FinalStock[i]<TargetStock[i]){
	 		HasPenalty[i] == 1;
	  	}
	}
		 
	//Ajouter la pénalité au cout total
	forall (i in Towns){
		TotalCost + (TargetStock[i] - Stock[i] * PenaltyUnderStockTarget) == TotalCost;
	}
}