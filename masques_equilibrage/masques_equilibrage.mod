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
float TotalDemandPreviousYear; //N-1
float TotalActualStock; //stock actuel total
 
 //variables de décision
 
dvar float totalCost;
dvar float costBetweenTowns[Towns][Towns]; //Prix de trajet entre 2 villes
dvar float finalStock[Towns]; //Stock final
dvar float targetStock[Towns]; //Stock visé
dvar float totalTargetStock; //stock cible total
dvar float totalFinalStock; //stock final total
dvar boolean hasPenalty[Towns]; //ville a pénalité

execute{
  	
  	
  	TotalDemandPreviousYear = 0;
  	TotalActualStock = 0;
  	
  	for(var i = 1 ; i<NbTowns; i++)
  	{
  		TotalDemandPreviousYear+= DemandPreviousYear[i];
  		TotalActualStock+=  Stock[i];
  	
  	}
  	
  	for(var i = 1 ; i<NbTowns; i++)
  	{
  	  	TotalActualStock * DemandPreviousYear[i] / TotalDemandPreviousYear == targetStock[i];
 	}  	
  		
  	
}


minimize totalCost;

//minimize Gap
 
subject to {
	//Calculer le coût entre 2 villes
	forall (i in Towns, j in Towns){
		LoadCoast[i] + (TransportCostPerUnitPerKm * Distance[i][j]) == costBetweenTowns[i][j];
	}
	
	//Définir le cout total
	sum (i in Towns, j in Towns) costBetweenTowns[i][j] == totalCost;
	
//	//Définir le stock demandé total de l'an dernier
//	sum (i in Towns) DemandPreviousYear[i] == TotalDemandPreviousYear;
//	
//	//Définir stock total actuel
//	sum (i in Towns) Stock[i] == TotalActualStock;
//	
	
	//Définir le sock ciblé de la ville
	forall( i in Towns) {
		TotalActualStock * DemandPreviousYear[i] / TotalDemandPreviousYear == targetStock[i];
	}
	
	// Definir sock ciblé total
	//sum (i in Towns) TargetStock[i] == TotalTargetStock;

	 
	// Definir le tableau des villes qui ont une pénalité 
	forall (i in Towns){
		if (Stock[i]<targetStock[i]){
	 		hasPenalty[i] == 1;
	  	}
	}
		 
	//Ajouter la pénalité au cout total
	forall (i in Towns){
		totalCost + (targetStock[i] - Stock[i] * PenaltyUnderStockTarget) == totalCost;
	}
	
	//Variables d'écart du target stock (stock = deficit + surplus target stock)
}