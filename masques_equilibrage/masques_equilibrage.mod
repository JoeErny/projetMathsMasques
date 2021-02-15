/*********************************************
 * OPL 12.10.0.0 Model
 * Author: joeer
 * Creation Date: 5 f�vr. 2021 at 16:18:11
 *********************************************/

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
float TotalDemandPreviousYear; //N-1
float TotalActualStock; //stock actuel total
 
 //variables de d�cision
 
dvar float totalCost;
dvar float costBetweenTowns[Towns][Towns]; //Prix de trajet entre 2 villes
dvar float finalStock[Towns]; //Stock final
dvar float targetStock[Towns]; //Stock vis�
dvar float totalTargetStock; //stock cible total
dvar float totalFinalStock; //stock final total
dvar boolean hasPenalty[Towns]; //ville a p�nalit�

execute{
  	
  	
  	TotalDemandPreviousYear = 0;
  	TotalActualStock = 0;
  	
  	for(var i = 1 ; i<NbTowns; i++)
  	{
  		TotalDemandPreviousYear+= DemandPreviousYear[i];
  		TotalActualStock+=  Stock[i];
  	
  	}
  	
  	for(var i = 1 ; i<NbTowns; i++)
  	{
  	  	TotalActualStock * DemandPreviousYear[i] / TotalDemandPreviousYear == targetStock[i];
 	}  	
  		
  	
}


minimize totalCost;

//minimize Gap
 
subject to {
	//Calculer le co�t entre 2 villes
	forall (i in Towns, j in Towns){
		LoadCoast[i] + (TransportCostPerUnitPerKm * Distance[i][j]) == costBetweenTowns[i][j];
	}
	
	//D�finir le cout total
	sum (i in Towns, j in Towns) costBetweenTowns[i][j] == totalCost;
	
//	//D�finir le stock demand� total de l'an dernier
//	sum (i in Towns) DemandPreviousYear[i] == TotalDemandPreviousYear;
//	
//	//D�finir stock total actuel
//	sum (i in Towns) Stock[i] == TotalActualStock;
//	
	
	//D�finir le sock cibl� de la ville
	forall( i in Towns) {
		TotalActualStock * DemandPreviousYear[i] / TotalDemandPreviousYear == targetStock[i];
	}
	
	// Definir sock cibl� total
	//sum (i in Towns) TargetStock[i] == TotalTargetStock;

	 
	// Definir le tableau des villes qui ont une p�nalit� 
	forall (i in Towns){
		if (Stock[i]<targetStock[i]){
	 		hasPenalty[i] == 1;
	  	}
	}
		 
	//Ajouter la p�nalit� au cout total
	forall (i in Towns){
		totalCost + (targetStock[i] - Stock[i] * PenaltyUnderStockTarget) == totalCost;
	}
	
	//Variables d'�cart du target stock (stock = deficit + surplus target stock)
}