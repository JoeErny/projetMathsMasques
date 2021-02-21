/*********************************************
 * OPL 12.10.0.0 Model
 * Author: groupe
 * Creation Date: 5 f�vr. 2021 at 16:18:11
 *********************************************/
// constantes donn�es__________________________________________________
int BigM = 10000;
int NbTowns = ...; //N le nombre d�entrep�ts
range Towns = 1..NbTowns;
string TownsName[Towns]=...; //Nom des villes

int LotSize = ...; //T la taille lot de transport

int PenaltyUnderStockTarget = ...; //PS  la p�nalit� appliqu�e pour chaque unit� de stock final inf�rieur au stock vis�.
int TransportCostPerUnitPerKm = ...; //CT le co�t de transport par unit� transport�e par km
 
float DemandPreviousYear[Towns]=...; //P
float LoadCoast[Towns]=...; //CC le co�t de chargement, par entrep�t #i
float Distance[Towns][Towns]=...; //D la distance de l�entrep�t #i vers l�entrep�t #j

float Stock[Towns]=...; //S le stock courant dans l�entrep�t #i
// variables calcul____________________________________________________

float TotalActualStock; //stock actuel total
float TotalDemandPreviousYear; //stock de l'ann�e derniere au total

float TargetStock[Towns]; //Stock vis�
float FinalStock[Towns]; // Stock temporaire

float CostBetweenTowns[Towns][Towns]; //Prix de trajet entre 2 villes

int Flots[Towns][Towns]; // nb lot envoy� (exp�diteur) vers (destinataire)
int BoolFlots[Towns][Towns]; //y'a t-il un flot ?
float NbPenalty[Towns]; // penalit� applique � la diffrence de stock final et stocxk vis� ( peut etre d�cimal)


float TotalCost = 0;

// variables de d�cision ______________________________________________



//_____________________________________________________________________
execute{
  	  
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
		  	if(TargetStock[i] > FinalStock[i]) // check si ville � besoin de stock
		  	{  		  	  
		  		write("La ville a besoin : "+i+"\n")
		  	    for(var j = 1 ; j<=NbTowns; j++) // cherche ville qui peut fournir un lot � moindre cout
		  		{   		  	      		
					if(CostBetweenTowns[i][j]<=temp && FinalStock[j]>TargetStock[j] && CostBetweenTowns[i][j]>0)
					{	  	
						write("La ville peut donner � celle qui a besoin : "+j)	  
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
			if(TargetStock[i] <= FinalStock[i]) //si la ville i (destinataire) est satisfaite, on passe � la suivante	  
			{
				i++;
			}	  	  	    	  	   	
		}
		
		
		//Calculer les p�nalit�s des villes
		for(var i = 1 ; i<=NbTowns; i++)
		{
 	  		if(FinalStock[i] < TargetStock[i])
 	  		{
 	  		  NbPenalty[i] = TargetStock[i] - FinalStock[i] ;
 	  		}
		}
		
		
		
	
		//Calculer co�t total
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