
// constantes donn�es__________________________________________________

int NbTowns = ...; //N le nombre d�entrep�ts
range Towns = 1..NbTowns;
string TownsName[Towns]=...; //Nom des villes

float LotSize = ...; //T la taille lot de transport

float PenaltyUnderStockTarget = ...; //PS  la p�nalit� appliqu�e pour chaque unit� de stock final inf�rieur au stock vis�.
float TransportCostPerUnitPerKm = ...; //CT le co�t de transport par unit� transport�e par km
float DemandPreviousYear[Towns]=...; //P
float LoadCoast[Towns]=...; //CC le co�t de chargement, par entrep�t #i
float Distance[Towns][Towns]=...; //D la distance de l�entrep�t #i vers l�entrep�t #j
float Stock[Towns]=...; //S le stock courant dans l�entrep�t #i


dvar float z;
dvar float+ penalty;
dvar float+ chargementCost;
dvar float+ transportCost;
dvar float+ sMoins[Towns];
dvar float+ sPlus[Towns];
dvar boolean isChargement[Towns][Towns];
dvar float+ flot[Towns][Towns];
dvar float+ targetStock[Towns];
dvar float+ finalStock[Towns];
dvar float+ nbLotsPerFlot[Towns][Towns];

minimize z;

subject to
{
  z == penalty + chargementCost + transportCost;
   
  penalty == sum(i in Towns) sMoins[i] * PenaltyUnderStockTarget;
  
  chargementCost == sum(i in Towns, j in Towns) isChargement[i][j]* LoadCoast[i];
  
  transportCost ==  sum(i in Towns, j in Towns) TransportCostPerUnitPerKm * Distance[i][j] * flot[i][j];
  
 
  
  //stockVise
  forall( i in Towns) {
  	targetStock[i] == DemandPreviousYear[i] * (sum(j in Towns) Stock[j] / sum(j in Towns) DemandPreviousYear[j]);
  }
  
  //finalStock
  forall(i in Towns) {
    finalStock[i] == Stock[i] + sum(j in Towns) flot[i][j] - sum(j in Towns) flot[j][i];
  }
  
  //flots
  forall(i in Towns)
  {
      sum(j in Towns)flot[i][j] <= isChargement[i][j] *Stock[i] ;
  }      
    
  //stock final (physique) 
  forall(i in Towns) {
        finalStock[i] == targetStock[i] + sPlus[i] - sMoins[i];
   }
   
   //taille lots
   forall (i in Towns, j in Towns) {
        flot[i][j] == LotSize * nbLotsPerFlot[i][j];
   }
   
   //lien chargements flux
    forall(i in Towns)
  	{
      sum(j in Towns)flot[i][j] <= Stock[i] * isChargement[i][j];
  	}  
  

  
  
  
 }