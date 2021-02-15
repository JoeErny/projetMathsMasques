/*********************************************
 * OPL 12.10.0.0 Model
 * Author: groupe
 * Creation Date: 5 févr. 2021 at 16:18:11
 *********************************************/
// constantes données__________________________________________________
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

// variables calcul____________________________________________________
float TotalDemandPreviousYear; //N-1
float TotalActualStock; //stock actuel total
float TargetStock[Towns]; //Stock visé
float CostBetweenTowns[Towns][Towns]; //Prix de trajet entre 2 villes
int HasPenalty[Towns];//ville a pénalité
float TotalCost;
 
// variables de décision ______________________________________________
 


//dvar float totalTargetStock; //stock cible total



//_____________________________________________________________________
execute{
  	
	  	TotalDemandPreviousYear = 0;
	  	TotalActualStock = 0;
  	
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  		TotalDemandPreviousYear+= DemandPreviousYear[i];
	  		TotalActualStock+=  Stock[i];
	  		  	
	  	}
  	
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  	  	TargetStock[i] = TotalActualStock * DemandPreviousYear[i] / TotalDemandPreviousYear ;
	 		if (Stock[i]<TargetStock[i]){
	 			HasPenalty[i] = 1;
	  		}
	 	}  	
 		
		for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  	  	for(var j = 1 ; j<=NbTowns; j++)
	  		{
	  		  	if(Distance[i][j]>0)
	  		  	{
	  		  		CostBetweenTowns[i][j] = LoadCoast[i] + (TransportCostPerUnitPerKm * Distance[i][j]);	  		  		  		  	  
	  		  	}
	  		}  	  
	  	}
	  	
	  	TotalCost = 0;
	  	
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  	  	for(var j = 1 ; j<=NbTowns; j++)
	  		{
	  			TotalCost += CostBetweenTowns[i][j];				  				  	
	  		}  	  
	  		//TotalCost = TotalCost + ((TargetStock[i] - Stock[i]) * PenaltyUnderStockTarget) ;
	  	}
	  		
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  	
	  		 TotalCost = TotalCost + ((TargetStock[i] - Stock[i]) * PenaltyUnderStockTarget);
  		}	  	
	  			 		
}

minimize TotalCost;

//minimize Gap
 
subject to {
	//Calculer le coût entre 2 villes
//	forall (i in Towns, j in Towns){
//		LoadCoast[i] + (TransportCostPerUnitPerKm * Distance[i][j]) == CostBetweenTowns[i][j];
//	}
	
	//Définir le cout total
//	sum (i in Towns, j in Towns) CostBetweenTowns[i][j] == totalCost;
	
//	//Définir le stock demandé total de l'an dernier
//	sum (i in Towns) DemandPreviousYear[i] == TotalDemandPreviousYear;
//	
//	//Définir stock total actuel
//	sum (i in Towns) Stock[i] == TotalActualStock;
//	
	
	//Définir le sock ciblé de la ville
//	forall( i in Towns) {
//		TotalActualStock * DemandPreviousYear[i] / TotalDemandPreviousYear == targetStock[i];
//	}
	
	// Definir sock ciblé total
	//sum (i in Towns) TargetStock[i] == TotalTargetStock;

	 
	// Definir le tableau des villes qui ont une pénalité 
//	forall (i in Towns){
//		if (Stock[i]<TargetStock[i]){
//	 		hasPenalty[i] == 1;
//	  	}
//	}
		 
	//Ajouter la pénalité au cout total
//	forall (i in Towns){
//		TotalCost + (TargetStock[i] - Stock[i] * PenaltyUnderStockTarget) == TotalCost;
//	}
	
	//Variables d'écart du target stock (stock = deficit + surplus target stock)
}