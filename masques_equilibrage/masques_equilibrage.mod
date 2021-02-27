/*
	***		TP: Equilibrage des stocks - MASKERO	***
	*** 		Erny Jo� & Jolivel Corentin			***
*/

// DONNEES

int NbTowns = ...; //nombre d�entrep�ts
range Towns = 1..NbTowns;
float LotSize = ...; //taille lot de transport
float PenaltyUnderStockTarget = ...; //la p�nalit� appliqu�e pour chaque unit� de stock final inf�rieur au stock vis�.
float TransportCostPerUnitPerKm = ...; //co�t de transport par unit� transport�e par km
string TownsName[Towns]=...; //noms des villes
float Stock[Towns]=...; //stock courant dans l�entrep�t i
float DemandPreviousYear[Towns]=...; //demande de l'ann�e pr�c�dente
float LoadCoast[Towns]=...; //co�t de chargement, par entrep�t i
float Distance[Towns][Towns]=...; //distance de l�entrep�t i vers j

//VARIABLES DE DECISION

dvar float z; //somme des p�nalit�s, co�t de chargement et co�t de transport
dvar float+ totalLoadCost;
dvar float+ totalTransportCost;
dvar float+ totalPenalties;
dvar boolean doesHaveLoad[Towns];
dvar float+ targetStock[Towns];
dvar float+ finalStock[Towns];
dvar float+ minusGap[Towns];
dvar float+ plusGap[Towns];
dvar int+ flow[Towns][Towns];
dvar int+ quantityPerFlow[Towns][Towns];

minimize z;

subject to
{
  	z == totalPenalties + totalLoadCost + totalTransportCost;
    
  	totalLoadCost == sum(i in Towns) doesHaveLoad[i]* LoadCoast[i];
  
 	totalTransportCost ==  sum(i in Towns, j in Towns) TransportCostPerUnitPerKm * Distance[i][j] * flow[i][j];
  
  	totalPenalties == sum(i in Towns) minusGap[i] * PenaltyUnderStockTarget;
  

  
    //contrainte sur le stock vis� par rapport � la demande de l'ann�e pr�c�dente
    forall( i in Towns) 
    {
  		 targetStock[i] == DemandPreviousYear[i] * (sum(j in Towns) Stock[j] / sum(j in Towns) DemandPreviousYear[j]);
    }
    
    
    //contrainte sur le stock final par rapport au stock vis� et ses �carts
    forall(i in Towns) 
    {
       	 finalStock[i] == targetStock[i] + plusGap[i] - minusGap[i];
    }
    
   	//contrainte sur les flux de palettes
    forall (i in Towns, j in Towns) 
    {      
     	 flow[i][j] == LotSize * quantityPerFlow[i][j];
    } 
   
    //contrainte sur la faisabilit� de l'�change 
    forall(i in Towns)
  	{
      	 sum(j in Towns)flow[i][j] <= Stock[i] * doesHaveLoad[i];
  	}
  	
    //contrainte sur le stock final par rapport aux �changes de palettes
	forall(k in Towns) 
	{
	     finalStock[k] == Stock[k] + sum(i in Towns) flow[i][k] - sum(j in Towns) flow[k][j];
	}  
} 
 
 
 