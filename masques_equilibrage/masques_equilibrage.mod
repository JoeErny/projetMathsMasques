/*********************************************
 * OPL 12.10.0.0 Model
 * Author: groupe
 * Creation Date: 5 févr. 2021 at 16:18:11
 *********************************************/
// constantes données__________________________________________________
int BigM = 10000;
int NbTowns = ...; //N le nombre d’entrepôts
range Towns = 1..NbTowns;
string TownsName[Towns]=...; //Nom des villes

int LotSize = ...; //T la taille lot de transport

int PenaltyUnderStockTarget = ...; //PS  la pénalité appliquée pour chaque unité de stock final inférieur au stock visé.
int TransportCostPerUnitPerKm = ...; //CT le coût de transport par unité transportée par km
 
float DemandPreviousYear[Towns]=...; //P
float LoadCoast[Towns]=...; //CC le coût de chargement, par entrepôt #i
float Distance[Towns][Towns]=...; //D la distance de l’entrepôt #i vers l’entrepôt #j

float Stock[Towns]=...; //S le stock courant dans l’entrepôt #i

// variables calcul____________________________________________________

float TotalActualStock; //stock actuel total
float TotalDemandPreviousYear; //stock de l'année derniere au total

//float targetStock[Towns]; //Stock visé
//float finalStock[Towns]; // Stock temporaire

float CostBetweenTowns[Towns][Towns]; //Prix de trajet entre 2 villes

int Flots[Towns][Towns]; // nb lot envoyé (expéditeur) vers (destinataire)
int BoolFlots[Towns][Towns]; //y'a t-il un flot ?
float NbPenalty[Towns]; // penalité applique à la diffrence de stock final et stocxk visé ( peut etre décimal)





float TotalCost = 0;



// variables de décision ____________________________________________________________________

dvar float totalPenalties;

dvar float totalLoadCost;

dvar float totalTransportCost;

dvar float z;

dvar float finalStock[Towns];

dvar float targetStock[Towns];

dvar boolean canGive[Towns][Towns];


dvar float gapPlusTargetStockFinalStock[i];
dvar float gapMinusTargetStockFinalStock[i];



//_____________________________________________________________________
execute{
  	  
  		//Stock Actuel Total
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  		TotalDemandPreviousYear+= DemandPreviousYear[i];
	  		TotalActualStock+=  Stock[i];
	  		  	
	  	}  	
	  	
  		//Stock visé
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  	  	targetStock[i] = TotalActualStock * DemandPreviousYear[i] / TotalDemandPreviousYear ;
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
	  	
	  
	  	//flots choix
	  	
  		var destinataire = 1;
	  	var expediteur = 1;
	 
	  	for(var x = 1 ; x<=NbTowns; x++)
	  	{
	  	  finalStock[x] = Stock[x];
    	}	  	  
	  	
		var i = 1;
	  	while(i<=NbTowns)
		{	
		  	var temp = BigM;
		  	if(targetStock[i] > finalStock[i]) // check si ville à besoin de stock
		  	{  		  	  
		  		write("La ville a besoin : "+i+"\n")
		  	    for(var j = 1 ; j<=NbTowns; j++) // cherche ville qui peut fournir un lot à moindre cout
		  		{   		  	      		
					if(CostBetweenTowns[i][j]<=temp && finalStock[j]>targetStock[j] && CostBetweenTowns[i][j]>0)
					{	  	
						write("La ville peut donner à celle qui a besoin : "+j)	  
						temp = CostBetweenTowns[j][i];    
						destinataire =i;
						expediteur = j;	  	   			
					}  		    	  		  	  		  
	   			}
				finalStock[expediteur] -= 3;
				finalStock[destinataire] += 3;
				Flots[expediteur][destinataire] += 3;   		
			}  	  	  

		//TODO CHANGER CA EN MINIMISER L'ECART
			if(targetStock[i] <= finalStock[i]) //si la ville i (destinataire) est satisfaite, on passe à la suivante	  
			{
				i++;
			}	  	  	    	  	   	
		}
		
		
		//Calculer les pénalités des villes
		for(var i = 1 ; i<=NbTowns; i++)
		{
 	  		if(finalStock[i] < targetStock[i])
 	  		{
 	  		  NbPenalty[i] = targetStock[i] - finalStock[i] ;
 	  		}
		}
		
		
		
	
		//Calculer coût total
		for(var i = 1 ; i<=NbTowns; i++)
		{
		  for(var j = 1 ; j<=NbTowns; j++)
		  {
		    
		    if(Flots[i][j]>0)
		    {
		      BoolFlots[i][j] = 1;
		    }		    		
		    	 TotalCost += (Flots[i][j] *Distance[i][j] *TransportCostPerUnitPerKm +  BoolFlots[i][j]*LoadCoast[i]);
		  }
		 
		  TotalCost += (PenaltyUnderStockTarget * NbPenalty[i]);
		}
		
}

//minimize sum(i in Towns,j in Towns) ((CostBetweenTowns[i][j] * Flots[i][j]) + (PenaltyUnderStockTarget * NbPenalty[i]));

minimize z;


subject to {
  
  	//Total des pénalitées
 	totalPenalties == sum(i in Towns) PenaltyUnderStockTarget * NbPenalty[i];
 	
 	
 	
 	//Total cout de chargement
    totalLoadCost == sum(i in Towns, j in Towns) BoolFlots[i][j]*LoadCoast[i];
    
    
    
    
    
    
    //Total cout de transport
    totalTransportCost == sum(i in Towns, j in Towns)  Flots[i][j] *Distance[i][j] *TransportCostPerUnitPerKm;
    
   
    //fonx objectif
    z == totalPenalties + totalLoadCost + totalTransportCost;
    
    
 
    
	TotalDemandPreviousYear == sum(i in Towns)DemandPreviousYear[i];
	TotalActualStock ==  sum(i in Towns)Stock[i];
  
    //Stock visé par ville
    forall( i in Towns) {
        targetStock[i] == TotalActualStock * DemandPreviousYear[i] / TotalDemandPreviousYear ;
    }
    
    //Final stock par ville
     forall(i in Towns)
     {
       finalStock[i] == Stock[i] + sum(x in Towns) Flots[x][i] - sum(x in Towns) Flots[i][x];
     }
    
    
        //Ecarts + et - entre stock final et stock visé pour chaque ville
    forall(i in Towns)
    {         
      	if (TargetStock[i] > FinalStock[i]) {gapPlusTargetStockFinalStock[i] == TargetStock[i] - FinalStock[i];   }  	     	
      	else {gapMinusTargetStockFinalStock[i] == TargetStock[i] - FinalStock[i];}      	
    }
    
    
    
    //Contrainte final stock
    forall(i in Towns) {
        finalStock[i] == targetStock[i] + gapPlusTargetStockFinalStock[i] - gapMinusTargetStockFinalStock[i];
    }
   
//    var i = 1;
//	  	while(i<=NbTowns)
//		{	
//		  	var temp = BigM;
//		  	if(targetStock[i] > finalStock[i]) // check si ville à besoin de stock
//		  	{  		  	  
//		  		write("La ville a besoin : "+i+"\n")
//		  	    for(var j = 1 ; j<=NbTowns; j++) // cherche ville qui peut fournir un lot à moindre cout
//		  		{   		  	      		
//					if(CostBetweenTowns[i][j]<=temp && finalStock[j]>targetStock[j] && CostBetweenTowns[i][j]>0)
//					{	  	
//						write("La ville peut donner à celle qui a besoin : "+j)	  
//						temp = CostBetweenTowns[j][i];    
//						destinataire =i;
//						expediteur = j;	  	   			
//					}  		    	  		  	  		  
//	   			}
//				finalStock[expediteur] -= 3;
//				finalStock[destinataire] += 3;
//				Flots[expediteur][destinataire] += 3;   		
//			}  	  	  
//
//		//TODO CHANGER CA EN MINIMISER L'ECART
//			if(targetStock[i] <= finalStock[i]) //si la ville i (destinataire) est satisfaite, on passe à la suivante	  
//			{
//				i++;
//			}	  	  	    	  	   	
//		}
//    
//   
   
    
    

    
    //contrainte sir ma taille de lots
    forall (i in Towns, j in Towns) {
        flot[i][j] == LotSize * lotFlot[i][j];
    }
    
    //contrainte chargementCost
    forall (i in Towns, j in Towns){
        flot[i][j] <= BigM * IsPossedeChargement[i][j];
        
        //le flot de A vers B ne peut JAMAIS se faire si A ne possède pas ce qu'il faut pour B
        // Car (10000*0) = 0  et  (10000*1) = 10000
        
    }
    
     forall (i in Towns, j in Towns){

			if(	(finalStock[j] > targetStock[j])  >= StockDemandé[i] ) //TODO 
			{
			  canGive[i][j] == true;
			}
			else
			{
			  canGive[i][j] == false;
			}
       
     }

	
}