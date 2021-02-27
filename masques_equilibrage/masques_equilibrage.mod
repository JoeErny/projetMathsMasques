/*
	***		TP: Equilibrage des stocks - MASKERO	***
	*** 		Erny Joé & Jolivel Corentin			***
*/

// DONNEES

int NbTowns = ...; //nombre d’entrepôts
range Towns = 1..NbTowns;
float LotSize = ...; //taille lot de transport
float PenaltyUnderStockTarget = ...; //la pénalité appliquée pour chaque unité de stock final inférieur au stock visé.
float TransportCostPerUnitPerKm = ...; //coût de transport par unité transportée par km
string TownsName[Towns]=...; //noms des villes
float Stock[Towns]=...; //stock courant dans l’entrepôt i
float DemandPreviousYear[Towns]=...; //demande de l'année précédente
float LoadCoast[Towns]=...; //coût de chargement, par entrepôt i
float Distance[Towns][Towns]=...; //distance de l’entrepôt i vers j

//VARIABLES DE DECISION

dvar float z; //somme des pénalités, coût de chargement et coût de transport
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
  

  
    //contrainte sur le stock visé par rapport à la demande de l'année précédente
    forall( i in Towns) 
    {
  		 targetStock[i] == DemandPreviousYear[i] * (sum(j in Towns) Stock[j] / sum(j in Towns) DemandPreviousYear[j]);
    }
    
    
    //contrainte sur le stock final par rapport au stock visé et ses écarts
    forall(i in Towns) 
    {
       	 finalStock[i] == targetStock[i] + plusGap[i] - minusGap[i];
    }
    
   	//contrainte sur les flux de palettes
    forall (i in Towns, j in Towns) 
    {      
     	 flow[i][j] == LotSize * quantityPerFlow[i][j];
    } 
   
    //contrainte sur la faisabilité de l'échange 
    forall(i in Towns)
  	{
      	 sum(j in Towns)flow[i][j] <= Stock[i] * doesHaveLoad[i];
  	}
  	
    //contrainte sur le stock final par rapport aux échanges de palettes
	forall(k in Towns) 
	{
	     finalStock[k] == Stock[k] + sum(i in Towns) flow[i][k] - sum(j in Towns) flow[k][j];
	}  
} 
 
 
 