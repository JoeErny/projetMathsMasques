/*********************************************
 * OPL 12.10.0.0 Model
 * Author: joeer
 * Creation Date: 7 févr. 2021 at 11:06:01
 *********************************************/
int nbVilles = ...;
int nbAntennes = ...;
range Villes = 1..nbVilles;
string NomsVilles[Villes] = ...;

float Distances[Villes][Villes] = ...;

dvar boolean x[Villes][Villes];
dvar boolean y[Villes];
dvar float+ z;

//Minimiser "rayon" (le rayon est la distance max d'un Entreprot vers un Client livrÃ© par cet entreprot)
minimize z;

subject to {

  sum(i in Villes) y[i] <= nbAntennes;

  forall(j in Villes) {
    sum(i in Villes) x[i][j] == 1;
  }

  forall(i in Villes, j in Villes) {
      Distances[i][j]x[i][j] <= z;
  }

  forall(i in Villes, j in Villes) {
      x[i][j] <= y[i];
  }

}

execute {
    write("Solution : ");
    for (var i = 1; i <= nbVilles; i++) {
        if (y[i]==1) {
            write("\n Antenne de " + NomsVilles[i] + " :");
            for (var j = 1; j <= nbVilles; j++) {
                if (x[i][j] == 1) {
                    write(" " + NomsVilles[j]);
                }
           }
        }
    }
}