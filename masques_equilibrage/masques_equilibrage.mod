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
 
 //variables de d�cision
 
dvar float+ TotalCost;
dvar float+ CostBetweenTowns[Towns][Towns]; //Prix de trajet entre 2 villes
dvar float FinalStock[Towns]; //Stock final
dvar float TargetStock[Towns]; //Stock vis�
dvar float TotalPreviousYearStock; //N-1
dvar float+ TotalTargetStock; //stock cible total
dvar float TotalFinalStock; //stock final total
dvar boolean HasPenalty[Towns]; //ville a p�nalit�

minimize TotalCost;
 
subject to {
	//Calculer le co�t entre 2 villes
	forall (i in Towns, j in Towns){
		LoadCoast[i] + (TransportCostPerUnitPerKm * Distance[i][j]) == CostBetweenTowns[i][j];
	}
	
	//D�finir le cout total
	sum (i in Towns, j in Towns) CostBetweenTowns[i][j] == TotalCost;
	
	//D�finir le stock demand� total de l'an dernier
	sum (i in Towns) DemandPreviousYear[i] == TotalPreviousYearStock;
	
	//D�finir stock total
	sum (i in Towns) Stock[i] == TotalFinalStock;
	
	
	//D�finir le sock cibl� de la ville
	forall( i in Towns:TotalFinalStock>0) {
		DemandPreviousYear[i] * (TotalPreviousYearStock/TotalStock) == TargetStock[i];
	}
	
	
	// Definir sock cibl� total
	sum (i in Towns) TargetStock[i] == TotalTargetStock;

	 
	// Definir le tableau des villes qui ont une p�nalit� 
	forall (i in Towns){
		if (FinalStock[i]<TargetStock[i]){
	 		HasPenalty[i] == 1;
	  	}
	}
		 
	//Ajouter la p�nalit� au cout total
	forall (i in Towns){
		TotalCost + (TargetStock[i] - Stock[i] * PenaltyUnderStockTarget) == TotalCost;
	}
}