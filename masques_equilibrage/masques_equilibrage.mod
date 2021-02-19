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

int NbLotSend[Towns][Towns]; // nb lot envoyé (expéditeur)
int NbPenality[Towns][Towns];
// variables de décision ______________________________________________



//_____________________________________________________________________
execute{
  	
	  	TotalDemandPreviousYear = 0;
	  	TotalActualStock = 0;
	  	
  		//Stock Actuel Total
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  		TotalDemandPreviousYear+= DemandPreviousYear[i];
	  		TotalActualStock+=  Stock[i];
	  		  	
	  	}
	  		  	
	  	
  		//Stock visé
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  	  	TargetStock[i] = TotalActualStock * DemandPreviousYear[i] / TotalDemandPreviousYear ;
	 		if (Stock[i]<TargetStock[i]){
	  		}
	 	}  
	 		
 		
 		//Cout de transport entre Entrepot
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
			 		
}

minimize sum(i in Towns,j in Towns) ((CostBetweenTowns[i][j] * NbLotSend[i][j]) + (PenaltyUnderStockTarget * NbPenality[i][j]));

 
subject to {
  
  
  
	
}