/*********************************************
 * OPL 12.10.0.0 Model
 * Author: groupe
 * Creation Date: 5 f�vr. 2021 at 16:18:11
 *********************************************/
// constantes donn�es__________________________________________________
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

float TargetStock[Towns]; //Stock vis�
float FinalStock[Towns]; //Stock final

float CostBetweenTowns[Towns][Towns]; //Prix de trajet entre 2 villes

int Flots[Towns][Towns]; // nb lot envoy� (exp�diteur) vers (destinataire)
float NbPenality[Towns]; // penalit� applique � la diffrence de stock final et stocxk vis� ( peut etre d�cimal)


// variables de d�cision ______________________________________________



//_____________________________________________________________________
execute{
  	
	  	var TotalDemandPreviousYear = 0;
	  	var TotalActualStock = 0;
	  	
	
	  	
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
	  	var temp = 100;
  		var destinataire = 1;
	  	var expediteur = 1;
	  	
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	
	  	  if(TargetStock[i] > Stock[i]) // check si ville � besoin de stock
	  	  {
	  	    for(var j = 1 ; j<=NbTowns; j++) // cherche ville qui peut fournir un lot � moindre cout
	  		{  		  
	  		  if(CostBetweenTowns[i][j]<temp && Stock[i]>TargetStock[i])
	  		  {
	  		    temp = CostBetweenTowns[i][j];
	  		    
	  		   	expediteur  =i;
	  		   	destinataire = j;
	  		  
	  		    
	   			
	  		  }
	  		  
   		  	  		  	  		  
   			}
   				Flots[expediteur][destinataire] = 3; 
   		
   			
	  	  }  	    
	  	   	
	  	}
	  	
	  	//Avoir le final stock de chaque ville
        for(var i = 1 ; i<=NbTowns; i++)
        {
            var ajout;
            var debit;
            for(var x in Towns)
              {
                ajout += Flots[x][i];
                debit += Flots[i][x];
              }
         
            FinalStock[i] = Stock[i] + ajout - debit;
        }

}

minimize sum(i in Towns,j in Towns) ((CostBetweenTowns[i][j] * Flots[i][j]) + (PenaltyUnderStockTarget * NbPenality[i]));


subject to {
  
  //contrainte 1 lot = 3 palette
  

  
	
}