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
int HasPenalty[Towns];//ville a p�nalit�
float TotalCost;
 
// variables de d�cision ______________________________________________
 


//dvar float totalTargetStock; //stock cible total



//_____________________________________________________________________
execute{
  	
	  	TotalDemandPreviousYear = 0;
	  	TotalActualStock = 0;
  	
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  		TotalDemandPreviousYear+= DemandPreviousYear[i];
	  		TotalActualStock+=  Stock[i];
	  		  	
	  	}
  	
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  	  	TargetStock[i] = TotalActualStock * DemandPreviousYear[i] / TotalDemandPreviousYear ;
	 		if (Stock[i]<TargetStock[i]){
	 			HasPenalty[i] = 1;
	  		}
	 	}  	
 		
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
	  	
	  	TotalCost = 0;
	  	
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  	  	for(var j = 1 ; j<=NbTowns; j++)
	  		{
	  			TotalCost += CostBetweenTowns[i][j];				  				  	
	  		}  	  
	  		//TotalCost = TotalCost + ((TargetStock[i] - Stock[i]) * PenaltyUnderStockTarget) ;
	  	}
	  		
	  	for(var i = 1 ; i<=NbTowns; i++)
	  	{
	  	
	  		 TotalCost = TotalCost + ((TargetStock[i] - Stock[i]) * PenaltyUnderStockTarget);
  		}	  	
	  			 		
}

minimize TotalCost;

//minimize Gap
 
subject to {
	//Calculer le co�t entre 2 villes
//	forall (i in Towns, j in Towns){
//		LoadCoast[i] + (TransportCostPerUnitPerKm * Distance[i][j]) == CostBetweenTowns[i][j];
//	}
	
	//D�finir le cout total
//	sum (i in Towns, j in Towns) CostBetweenTowns[i][j] == totalCost;
	
//	//D�finir le stock demand� total de l'an dernier
//	sum (i in Towns) DemandPreviousYear[i] == TotalDemandPreviousYear;
//	
//	//D�finir stock total actuel
//	sum (i in Towns) Stock[i] == TotalActualStock;
//	
	
	//D�finir le sock cibl� de la ville
//	forall( i in Towns) {
//		TotalActualStock * DemandPreviousYear[i] / TotalDemandPreviousYear == targetStock[i];
//	}
	
	// Definir sock cibl� total
	//sum (i in Towns) TargetStock[i] == TotalTargetStock;

	 
	// Definir le tableau des villes qui ont une p�nalit� 
//	forall (i in Towns){
//		if (Stock[i]<TargetStock[i]){
//	 		hasPenalty[i] == 1;
//	  	}
//	}
		 
	//Ajouter la p�nalit� au cout total
//	forall (i in Towns){
//		TotalCost + (TargetStock[i] - Stock[i] * PenaltyUnderStockTarget) == TotalCost;
//	}
	
	//Variables d'�cart du target stock (stock = deficit + surplus target stock)
}