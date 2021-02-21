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

float TargetStock[Towns]; //Stock visé
float FinalStock[Towns]; // Stock temporaire

float CostBetweenTowns[Towns][Towns]; //Prix de trajet entre 2 villes

int Flots[Towns][Towns]; // nb lot envoyé (expéditeur) vers (destinataire)
int BoolFlots[Towns][Towns]; //y'a t-il un flot ?
float NbPenalty[Towns]; // penalité applique à la diffrence de stock final et stocxk visé ( peut etre décimal)


float TotalCost = 0;

// variables de décision ______________________________________________



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
	  	  	TargetStock[i] = TotalActualStock * DemandPreviousYear[i] / TotalDemandPreviousYear ;
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
	  	  FinalStock[x] = Stock[x];
    	}	  	  
	  	
		var i = 1;
	  	while(i<=NbTowns)
		{	
		  	var temp = BigM;
		  	if(TargetStock[i] > FinalStock[i]) // check si ville à besoin de stock
		  	{  		  	  
		  		write("La ville a besoin : "+i+"\n")
		  	    for(var j = 1 ; j<=NbTowns; j++) // cherche ville qui peut fournir un lot à moindre cout
		  		{   		  	      		
					if(CostBetweenTowns[i][j]<=temp && FinalStock[j]>TargetStock[j] && CostBetweenTowns[i][j]>0)
					{	  	
						write("La ville peut donner à celle qui a besoin : "+j)	  
						temp = CostBetweenTowns[j][i];    
						destinataire =i;
						expediteur = j;	  	   			
					}  		    	  		  	  		  
	   			}
				FinalStock[expediteur] -= 3;
				FinalStock[destinataire] += 3;
				Flots[expediteur][destinataire] += 3;   		
			}  	  	  

//TODO CHANGER CA EN MINIMISER L'ECART
			if(TargetStock[i] <= FinalStock[i]) //si la ville i (destinataire) est satisfaite, on passe à la suivante	  
			{
				i++;
			}	  	  	    	  	   	
		}
		
		
		//Calculer les pénalités des villes
		for(var i = 1 ; i<=NbTowns; i++)
		{
 	  		if(FinalStock[i] < TargetStock[i])
 	  		{
 	  		  NbPenalty[i] = TargetStock[i] - FinalStock[i] ;
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

minimize sum(i in Towns,j in Towns) ((CostBetweenTowns[i][j] * Flots[i][j]) + (PenaltyUnderStockTarget * NbPenalty[i]));


subject to {
  
  //contrainte 1 lot = 3 palette
  

  
	
}