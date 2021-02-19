/*********************************************
 * OPL 12.10.0.0 Model
 * Author: groupe
 * Creation Date: 5 f�vr. 2021 at 16:18:11
 *********************************************/
// constantes donn�es__________________________________________________
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

// variables calcul____________________________________________________
float TotalDemandPreviousYear; //N-1
float TotalActualStock; //stock actuel total
float TargetStock[Towns]; //Stock vis�
float CostBetweenTowns[Towns][Towns]; //Prix de trajet entre 2 villes

int NbLotSend[Towns][Towns]; // nb lot envoy� (exp�diteur)
int NbPenality[Towns][Towns];
// variables de d�cision ______________________________________________



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
	  		  	
	  	
  		//Stock vis�
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