LIBNAME TER "C:\Users\Lokman\Desktop\TER\Données+Codes SAS";
options fmtsearch=(TER);

/* On filtre les individus selon le critère : phdip > BAC+2 */
DATA TER.individu;
SET TER.individu_completv31sspi_nef;
if phdip="01"    then delete;
if phdip="02"    then delete;
if phdip="03"    then delete;
if phdip="04"    then delete;
if phdip="05"    then delete;
if phdip="06"    then delete;

ctypotraj = put(typotraj,$1.);			/****On rend typotraj (numérique) en ctypotraj (caractère). Je ne comprends pas le WARNING****/
drop typotraj;

LABEL
ctypotraj="Typologie de trajectoire"
op2="Opinion sur le parcours et l'avenir professionnel";

RUN;

/* On filtre les emplois selon les critères : cal =/= 20 et dernier emploi seulement */
DATA TER.emploi;
SET TER.seqentr_completv25sspi_nef;
if cal="20" then delete;
RUN;
PROC SORT DATA=TER.emploi NODUPKEY;
BY IDENT DESCENDING NSEQ;
RUN;
PROC SORT DATA=TER.emploi NODUPKEY;
BY IDENT;
RUN;

/* On fusionne la table individu et la table emploi. 
Comme il y a toujours des IDENT n'ayant pas de diplôme du supérieur dans la table des emploi on ne veut que les IDENT de la table individu donc il a fallu faire (in=in1) 
( pas trop compris, trouvé sur https://communities.sas.com/t5/Base-SAS-Programming/Merge-One-to-Many-Problems/td-p/288274 ) */
DATA TER.individu_emploi;
MERGE TER.individu (in=in1) TER.emploi;
BY IDENT;
if in1;
RUN;

/****** DESCRIPTION DE LA TABLE individu_emploi ******/
PROC CONTENTS DATA=TER.individu_emploi ORDER=VARNUM;
RUN;	




  /****************************************************************************************/
 /*				TRIS A PLAT POUR RESOUDRE DES PROBLEMES DE TABLE						 */
/****************************************************************************************/

/*Tris à plat pour les variables concernant les individus*/
PROC FREQ DATA=TER.individu_emploi;
TABLE q35new sitde nmemp nmcho ctypotraj op2;		
/*FORMAT sitde $sitde_f. ctypotraj $typo. op2 $op2_f. q35new $q35new_f.;*/
RUN;

/*Tris à plat pour les variables concernant la derniere séquence d'entreprise*/
PROC FREQ DATA=TER.individu_emploi;
TABLE pcs_fin ep70 ep49;
/*FORMAT pcs_fin $PCS. ep70 $ep70_f. ep49 $ep49_f.;*/
RUN;



  /*******************************************************/
 /*				APRES TRIS A PLAT						*/
/*******************************************************/

/*Pour la variable Baccalauréat certains avaient plusieurs BAC.
Nous allons seulement prendre en compte que le Bac qui, selon nous, a le plus d'impact sur la réussite professionnelle*/
/****C'est tout de même une justification assez arbitraire et le résultat peut être biaisé non ?****/
PROC FREQ DATA=TER.individu_emploi;
TABLE q35new;		
FORMAT q35new $q35new_f.;
RUN;
PROC FREQ DATA=TER.individu_emploi;
TABLE sitde;		
FORMAT sitde $sitde_f.;
RUN;
PROC FREQ DATA=TER.individu_emploi;
TABLE ctypotraj;		
FORMAT ctypotraj $ctypotraj_f.;
RUN;
PROC FREQ DATA=TER.individu_emploi;
TABLE OP2;		
FORMAT OP2 $OP2_f.;
RUN;
PROC FREQ DATA=TER.individu_emploi;
TABLE EP70;		
FORMAT EP70 $EP70_f.;
RUN;
PROC FREQ DATA=TER.individu_emploi;
TABLE EP49;		
FORMAT EP49 $EP49_f.;
RUN;
PROC FREQ DATA=TER.individu_emploi;
TABLE PHDIP;		
FORMAT PHDIP $PHDIP_f.;
RUN;
PROC FREQ DATA=TER.individu_emploi;
TABLE Q1;		
FORMAT Q1 $Q1_f.;
RUN;
PROC FREQ DATA=TER.individu_emploi;
TABLE LIEUNPER;		
FORMAT LIEUNPER $LIEUNPER_f.;
RUN;
PROC FREQ DATA=TER.individu_emploi;
TABLE PCS_FIN;		
FORMAT PCS_FIN $PCS_FIN_f.;
RUN;
PROC FREQ DATA=TER.individu_emploi;
TABLE STAT_FIN;		
FORMAT STAT_FIN $STAT_FIN_f.;
RUN;
PROC FREQ DATA=TER.individu_emploi;
TABLE salprfin;		
FORMAT salprfin salprfin_f.;
RUN;



DATA TER.non_diplome;
SET TER.individu_completv31sspi_nef;
if phdip="07"    then delete;
if phdip="08"    then delete;
if phdip="09"    then delete;
if phdip="10"    then delete;
if phdip="11"    then delete;
if phdip="12"    then delete;
if phdip="13"    then delete;
if phdip="14"    then delete;
if phdip="15"    then delete;
if phdip="16"    then delete;
if phdip="17"    then delete;
if phdip="18"    then delete;

ctypotraj = put(typotraj,$1.);			/****On rend typotraj (numérique) en ctypotraj (caractère). Je ne comprends pas le WARNING****/
drop typotraj;
LABEL
ctypotraj="Typologie de trajectoire"
op2="Opinion sur le parcours et l'avenir professionnel";
RUN;

/*OK*/
PROC FREQ DATA = TER.non_diplome(where=(IDENT="W0322185"));
TABLES phdip;
FORMAT phdip $phdip_fs.;
RUN;
/*OK*/

PROC FREQ DATA = TER.non_diplome;
TABLES OP2;
FORMAT OP2 $OP2_fs.;
WEIGHT PONDEF;
RUN;

PROC FREQ DATA = TER.individu_completv31sspi_nef;
TABLES OP2;
FORMAT OP2 $OP2_fs.;
WEIGHT PONDEF;
RUN;

DATA TER.individu_emploi;
SET TER.individu_emploi;
PART_EMP=nmemp/durobs; 	/*Part de temps passé en emploi*/
RUN;
