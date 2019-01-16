LIBNAME TER "C:\Users\Lokman\Desktop\TER\Données+Codes SAS";
options fmtsearch=(TER);

  /***************************************************************************/
 /*		VARIABLES DE CONSTRUCTION DU SCORE DE REUSSITE PROFESSIONNELLE		*/
/***************************************************************************/


/*OP2*/
PROC FREQ DATA=TER.individu_emploi;		/*Et ici on prend les pourcentages (représentatifs des diplômés du supérieur en France*/
TABLE OP2;
FORMAT OP2 $OP2_fs.;
WEIGHT PONDEF;
RUN;

/*PCS_FIN*/
PROC FREQ DATA=TER.individu_emploi;
TABLE op2*pcs_fin / expected chisq deviation cellchi2;
FORMAT pcs_fin $Pcs_fs. op2 $op2_fs.;
WEIGHT PONDEF;
RUN;

PROC FREQ DATA=TER.individu_emploi;
TABLE pcs_fin;
FORMAT pcs_fin $Pcs_fin_f.;
WEIGHT PONDEF;
RUN;

/*STAT_FIN (cdi or STAT_FIN =  cdd)*/
PROC FREQ DATA=TER.individu_emploi;
TABLE STAT_FIN;
FORMAT STAT_FIN $STAT_FIN_f.;
WEIGHT PONDEF;
RUN;

/*EP70 (nombre d'employés dirigés)*/

PROC FREQ DATA=TER.individu_emploi;
TABLE EP70;
FORMAT EP70 $EP70_f.;
WEIGHT PONDEF;
RUN;

/*SALPRFIN (salaire net + primes)*/
PROC SGPLOT DATA=TER.individu_emploi;	/*BOX PLOT ECRASÉ/ILLISIBLE or STAT_FIN =  ON VA SUPPRIMER TEMPORAIREMENT LES 99% LES PLUS RICHES ET LES 99% LES PLUS PAUVRES*/
VBOX SALPRFIN;
RUN;




PROC UNIVARIATE DATA=TER.individu_emploi;	/*Les 99% des plus hauts revenus = 4000. Les 99% des plus bas revenus = 490*/
VAR SALPRFIN;
RUN;

DATA salaire;	/*JUSTE POUR AVOIR UN BOXPLOT LISIBLE*/
SET TER.individu_emploi;
if salprfin>4000 then delete;
if salprfin<490 then delete;
RUN;

PROC SGPLOT DATA=salaire;	/*On utilisera ce graphique pour décrire les hauts revenus sans oublier de mentionner qu'il y a les 1% plus riches et les 1% plus pauvres*/
VBOX SALPRFIN;				/*tout en décrivant leurs valeurs*/
RUN;

PROC FREQ DATA=TER.individu_emploi;
TABLE salprfin;
FORMAT salprfin Salprfin_f.;
WEIGHT PONDEF;
RUN;

PROC UNIVARIATE DATA=TER.individu_emploi;
VAR salprfin;
WEIGHT PONDEF;
RUN;

DATA salaire;
SET TER.individu_emploi (keep=IDENT CLASSE DIS03 salprfin EMPL_emb EMPL_fin) ;
if salprfin < 4001 then delete;
RUN;
PROC SORT DATA=salaire;
BY DESCENDING salprfin;
RUN;

DATA test;
SET TER.individu_emploi;
if salprfin < 4001 then delete;
RUN;
PROC SORT DATA=test;
BY DESCENDING salprfin;
RUN;

PROC CORR DATA=TER.individu_emploi;
VAR salprfin part_emp;
RUN;
PROC GPLOT DATA=TER.individu_emploi;
PLOT salprfin*part_emp;
SYMBOL INTERPOL=rl value=plus CI=RED CV=MOB;
RUN;


/*PART_EMP (part de temps passée en emploi entre la sortie du système scolaire et la date de l'interrogation*/
PROC UNIVARIATE DATA=TER.individu_emploi;
VAR PART_EMP;
RUN;
PROC SGPLOT DATA=TER.individu_emploi;
VBAR PART_EMP ;
RUN;
PROC PRINT DATA=TER.individu_emploi;
VAR PART_EMP;
RUN;

PROC FREQ DATA=TER.individu_emploi;
TABLE PART_EMP;
FORMAT PART_EMP PART_EMP_fs.;
RUN;
PROC FREQ DATA=TER.individu_emploi;
TABLE PART_EMP;
FORMAT PART_EMP PART_EMP_fs.;
WEIGHT PONDEF;
RUN;



    /************************************************************************/
   /****                                                                ****/
  /*                                ACM                                   */
 /****                                                                ****/
/************************************************************************/

/* 		POUR L'ACM or STAT_FIN =  UTILISER LES FORMATS SIMPLIFIÉS "_fs" 	*/
/*		Fait dans le programme code_sas_format.sas			*/


/* TRIS A PLAT POUR VOIR SI CA FONCTIONNE COMME ON LE VEUT */

PROC FREQ DATA=TER.individu_emploi;
TABLE OP2 PCS_FIN STAT_FIN EP49 EP70 SALPRFIN;
FORMAT OP2 $OP2_fs. PCS_FIN $PCS_fs. STAT_FIN $STAT_fs. EP49 $EP49_fs. EP70 $EP70_fs. SALPRFIN SALPRFIN_fs.;
RUN;

/*ACM POUR LA CONSTRUCTION DE SCORE*/
PROC CORRESP data=TER.individu_emploi mca out=resul;
tables OP2 PCS_FIN STAT_FIN EP49 EP70 SALPRFIN	;
FORMAT OP2 $OP2_fs. PCS_FIN $PCS_fs. STAT_FIN $STAT_fs. EP49 $EP49_fs. EP70 $EP70_fs. SALPRFIN SALPRFIN_fs.	;
WEIGHT PONDEF;
RUN;

ods graphics / height=1200 width = 1200;
PROC CORRESP data=TER.individu_emploi mca out=resul PLOTS=all DIMENS=2 ;
tables OP2 PCS_FIN STAT_FIN EP49 EP70 SALPRFIN	;
FORMAT OP2 $OP2_fs. PCS_FIN $PCS_fs. STAT_FIN $STAT_fs. EP49 $EP49_fs. EP70 $EP70_fs. SALPRFIN SALPRFIN_fs.	;
WEIGHT PONDEF;
RUN;



/* ACM POUR METTRE EN RELATION AVEC VARIABLES EXPLICATIVES */

ods graphics / height=1200 width = 1200;
PROC CORRESP data=TER.individu_emploi mca out=resul PLOTS=all DIMENS=2 ;
tables OP2 PCS_FIN STAT_FIN EP49 EP70 SALPRFIN	Q1 PART_EMP;
FORMAT OP2 $OP2_fs. PCS_FIN $PCS_fs. STAT_FIN $STAT_fs. EP49 $EP49_fs. EP70 $EP70_fs. SALPRFIN SALPRFIN_fs. PART_EMP PART_EMP_fs.	
/*SUPPLEMENTARY*/	Q1 $Q1_fs.;

SUPPLEMENTARY Q1;

WEIGHT PONDEF;
RUN;

PROC CORRESP data=TER.individu_emploi mca out=resul PLOTS=all DIMENS=2 ;
tables OP2 PCS_FIN STAT_FIN EP49 EP70 SALPRFIN	PHDIP PART_EMP;
FORMAT OP2 $OP2_fs. PCS_FIN $PCS_fs. STAT_FIN $STAT_fs. EP49 $EP49_fs. EP70 $EP70_fs. SALPRFIN SALPRFIN_fs.	PART_EMP PART_EMP_fs.	
/*SUPPLEMENTARY*/	PHDIP  $PHDIP_fs.;

SUPPLEMENTARY PHDIP ;

WEIGHT PONDEF;
RUN;

PROC CORRESP data=TER.individu_emploi mca out=resul PLOTS=all DIMENS=2 ;
tables OP2 PCS_FIN STAT_FIN EP49 EP70 SALPRFIN	Q35NEW PART_EMP;
FORMAT OP2 $OP2_fs. PCS_FIN $PCS_fs. STAT_FIN $STAT_fs. EP49 $EP49_fs. EP70 $EP70_fs. SALPRFIN SALPRFIN_fs.	PART_EMP PART_EMP_fs.	
/*SUPPLEMENTARY*/	Q35NEW  $Q35NEW_FS.;

SUPPLEMENTARY Q35NEW ;

WEIGHT PONDEF;
RUN;

PROC CORRESP data=TER.individu_emploi mca out=resul PLOTS=all DIMENS=2 ;
tables OP2 PCS_FIN STAT_FIN EP49 EP70 SALPRFIN	q38e PART_EMP;
FORMAT OP2 $OP2_fs. PCS_FIN $PCS_fs. STAT_FIN $STAT_fs. EP49 $EP49_fs. EP70 $EP70_fs. SALPRFIN SALPRFIN_fs.	PART_EMP PART_EMP_fs.	
/*SUPPLEMENTARY*/	q38e  $ouiNONnsp.;

SUPPLEMENTARY q38e ;

WEIGHT PONDEF;
RUN;

PROC CORRESP data=TER.individu_emploi mca out=resul PLOTS=all DIMENS=2 ;
tables OP2 PCS_FIN STAT_FIN EP49 EP70 SALPRFIN	ERA1   PART_EMP ;
FORMAT OP2 $OP2_fs. PCS_FIN $PCS_fs. STAT_FIN $STAT_fs. EP49 $EP49_fs. EP70 $EP70_fs. SALPRFIN SALPRFIN_fs.	PART_EMP PART_EMP_fs.
/*SUPPLEMENTARY*/	ERA1    $ouiNONnsp.;

SUPPLEMENTARY ERA1    ;

WEIGHT PONDEF;
RUN;

/*CONSTRUCTION VARIABLE SCORE*/

DATA TER.score;
SET TER.individu_emploi;

if OP2 = "1" then OP2_score = 31;
if OP2 = "2" then OP2_score = -87;

if PCS_FIN = "111A" or PCS_FIN =  "111a" or PCS_FIN =  "111B" or PCS_FIN =  "111b" or PCS_FIN =  "111C" or PCS_FIN =  "111c" or PCS_FIN =  "111D" or PCS_FIN =  "111d" or PCS_FIN =  "111E" or PCS_FIN =   "111e" or PCS_FIN =  "111F" or PCS_FIN =  "111f" or PCS_FIN =  "121A" or PCS_FIN =  "121a" or PCS_FIN =  "121B" or PCS_FIN =  "121b" or PCS_FIN =  "121C" or PCS_FIN =  "121c" or PCS_FIN =  "121D" or PCS_FIN =  "121d" or PCS_FIN =  "121E" or PCS_FIN =  "121e" or PCS_FIN =  "121F" or PCS_FIN =  "121f" or PCS_FIN =  "122A" or PCS_FIN =  "122a" or PCS_FIN =  "122B" or PCS_FIN =  "122b" or PCS_FIN =  "122C" or PCS_FIN =  "122c" or PCS_FIN =  "131A" or PCS_FIN =  "131a" or PCS_FIN =  "131B" or PCS_FIN =  "131b" or PCS_FIN =  "131C" or PCS_FIN =  "131c" or PCS_FIN =  "131D" or PCS_FIN =  "131d" or PCS_FIN =  "131E" or PCS_FIN =  "131e" or PCS_FIN =  "131F" or PCS_FIN =  "131f" 
	then PCS_FIN_score = 63;
if PCS_FIN = "241F" or PCS_FIN = "211A" or PCS_FIN = "211a" or PCS_FIN = "211B" or PCS_FIN = "211b" or PCS_FIN = "211C" or PCS_FIN = "211c" or PCS_FIN = "211D" or PCS_FIN = "211d" or PCS_FIN = "211E" or PCS_FIN = "211e" or PCS_FIN = "211F" or PCS_FIN = "211f" or PCS_FIN = "211G" or PCS_FIN = "211g" or PCS_FIN = "211H" or PCS_FIN = "211h" or PCS_FIN = "211J" or PCS_FIN = "211j" or PCS_FIN = "212A" or PCS_FIN = "212a" or PCS_FIN = "212B" or PCS_FIN = "212b" or PCS_FIN = "212C" or PCS_FIN = "212c" or PCS_FIN = "212D" or PCS_FIN = "212d" or PCS_FIN = "213A" or PCS_FIN = "213a" or PCS_FIN = "214A" or PCS_FIN = "214a" or PCS_FIN = "214B" or PCS_FIN = "214b" or PCS_FIN = "214C" or PCS_FIN = "214c" or PCS_FIN = "214D" or PCS_FIN = "214d" or PCS_FIN = "214E" or PCS_FIN = "214e" or PCS_FIN = "214F" or PCS_FIN = "214f" or PCS_FIN = "215A" or PCS_FIN = "215a" or PCS_FIN = "215B" or PCS_FIN = "215b" or PCS_FIN = "215C" or PCS_FIN = "215c" or PCS_FIN = "215D" or PCS_FIN = "215d" or PCS_FIN = "216A" or PCS_FIN = "216a" or PCS_FIN = "216B" or PCS_FIN = "216b" or PCS_FIN = "216C" or PCS_FIN = "216c" or PCS_FIN = "217A" or PCS_FIN = "217a" or PCS_FIN = "217B" or PCS_FIN = "217b" or PCS_FIN = "217C" or PCS_FIN = "217c" or PCS_FIN = "217D" or PCS_FIN = 
"217d" or PCS_FIN = "217E" or PCS_FIN = "217e" or PCS_FIN = "218A" or PCS_FIN = "218a" or PCS_FIN = "219A" or PCS_FIN = "219a" or PCS_FIN = "221A" or PCS_FIN = "221a" or PCS_FIN = "221B" or PCS_FIN = "221b" or PCS_FIN = "222A" or PCS_FIN = "222a" or PCS_FIN = "222B" or PCS_FIN = "222b" or PCS_FIN = "223A" or PCS_FIN = "223a" or PCS_FIN = "223B" or PCS_FIN = "223b" or PCS_FIN = "223C" or PCS_FIN = "223c" or PCS_FIN = "223D" or PCS_FIN = "223d" or PCS_FIN = "223E" or PCS_FIN = "223e" or PCS_FIN = "223F" or PCS_FIN = "223f" or PCS_FIN = "223G" or PCS_FIN = "223g" or PCS_FIN = "223H" or PCS_FIN = "223h" or PCS_FIN = "224A" or PCS_FIN = "224a" or PCS_FIN = "224B" or PCS_FIN = "224b" or PCS_FIN = "224C" or PCS_FIN = "224c" or PCS_FIN = "224D" or PCS_FIN = "224d" or PCS_FIN = "225A" or PCS_FIN = "225a" or PCS_FIN = "226A" or PCS_FIN = "226a" or PCS_FIN = "226B" or PCS_FIN = "226b" or PCS_FIN = "226C" or PCS_FIN = "226c" or PCS_FIN = "227A" or PCS_FIN = "227a" or PCS_FIN = "227B" or PCS_FIN = "227b" or PCS_FIN = "227C" or PCS_FIN = "227c" or PCS_FIN = "227D" or PCS_FIN = "227d" or PCS_FIN = "231A" or PCS_FIN = "231a" or PCS_FIN = "232A" or PCS_FIN = "232a" or PCS_FIN = "233A" or PCS_FIN = "233a" or PCS_FIN = 
"233B" or PCS_FIN = "233b" or PCS_FIN = "233C" or PCS_FIN = "233c" or PCS_FIN = "233D" or PCS_FIN = "233d"
	then PCS_FIN_score = 63;
if PCS_FIN = "332F" or PCS_FIN =  "352E" or PCS_FIN = "311A" or PCS_FIN = "311a" or PCS_FIN = "311B" or PCS_FIN = "311b" or PCS_FIN = "311C" or PCS_FIN = "311c" or PCS_FIN = "311D" or PCS_FIN = "311d" or PCS_FIN = "311E" or PCS_FIN = "311e" or PCS_FIN = "311F" or PCS_FIN = "311f" or PCS_FIN = "312A" or PCS_FIN = "312a" or PCS_FIN = "312B" or PCS_FIN = "312b" or PCS_FIN = "312C" or PCS_FIN = "312c" or PCS_FIN = "312D" or PCS_FIN = "312d" or PCS_FIN = "312E" or PCS_FIN = "312e" or PCS_FIN = "312F" or PCS_FIN = "312f" or PCS_FIN = "312G" or PCS_FIN = "312g" or PCS_FIN = "313A" or PCS_FIN = "313a" or PCS_FIN = "331A" or PCS_FIN = '331a' or PCS_FIN = "332A" or PCS_FIN = "332a" or PCS_FIN = "332B" or PCS_FIN = "332b" or PCS_FIN = "333A" or PCS_FIN = "333a" or PCS_FIN = "333B" or PCS_FIN = "333b" or PCS_FIN = "333C" or PCS_FIN = "333c" or PCS_FIN = "333D" or PCS_FIN = "333d" or PCS_FIN = "333E" or PCS_FIN = "333e" or PCS_FIN = "333F" or PCS_FIN = "333f" or PCS_FIN = "334A" or PCS_FIN = "334a" or PCS_FIN = "335A" or PCS_FIN = "335a" or PCS_FIN = "341A" or PCS_FIN = "341a" or PCS_FIN = "341B" or PCS_FIN = "341b" or PCS_FIN = "342A" or PCS_FIN = "342a" or PCS_FIN = "342E" or PCS_FIN = "342e" or PCS_FIN = "343A" or PCS_FIN = "343a" or PCS_FIN = "344A" or PCS_FIN = 
"342B" or PCS_FIN =  "342b" or PCS_FIN = "342C" or PCS_FIN =  "342c" or PCS_FIN = "342D" or PCS_FIN =  "342d" or PCS_FIN = "342F" or PCS_FIN =  "342f" or PCS_FIN = "342G" or PCS_FIN =  "342g" or PCS_FIN = "342H" or PCS_FIN =  "342h" or PCS_FIN = "354E" or PCS_FIN =  "354e" or PCS_FIN = "354F" or PCS_FIN =  "354f" or PCS_FIN = "381B" or PCS_FIN =  "381b" or PCS_FIN = "381C" or PCS_FIN =  "381c" or PCS_FIN = "386B" or PCS_FIN =  "386b" or PCS_FIN = "386C" or PCS_FIN =  "386c" or PCS_FIN = 
"344a" or PCS_FIN = "344B" or PCS_FIN = "344b" or PCS_FIN = "344C" or PCS_FIN = "344c" or PCS_FIN = "344D" or PCS_FIN = "344d" or PCS_FIN = "351A" or PCS_FIN = "351a" or PCS_FIN = "352A" or PCS_FIN = "352a" or PCS_FIN = "352B" or PCS_FIN = "352b" or PCS_FIN = "353A" or PCS_FIN = "353a" or PCS_FIN = "353B" or PCS_FIN = "353b" or PCS_FIN = "353C" or PCS_FIN = "353c" or PCS_FIN = "354A" or PCS_FIN = "354a" or PCS_FIN = "354B" or PCS_FIN = "354b" or PCS_FIN = "354C" or PCS_FIN = "354c" or PCS_FIN = "354D" or PCS_FIN = "354d" or PCS_FIN = "354G" or PCS_FIN = "354g" or PCS_FIN = "371A" or PCS_FIN = "371a" or PCS_FIN = "372A" or PCS_FIN = "372a" or PCS_FIN = "372B" or PCS_FIN = "372b" or PCS_FIN = "372C" or PCS_FIN = "372c" or PCS_FIN = "372D" or PCS_FIN = "372d" or PCS_FIN = "372E" or PCS_FIN = "372e" or PCS_FIN = "372F" or PCS_FIN = "372f" or PCS_FIN = "373A" or PCS_FIN = "373a" or PCS_FIN = "373B" or PCS_FIN = "373b" or PCS_FIN = "373C" or PCS_FIN = "373c" or PCS_FIN = "373D" or PCS_FIN = "373d" or PCS_FIN = "374A" or PCS_FIN = "374a" or PCS_FIN = "374B" or PCS_FIN = "374b" or PCS_FIN = "374C" or PCS_FIN = "374c" or PCS_FIN = "374D" or PCS_FIN = "374d" or PCS_FIN = "375A" or PCS_FIN = "375a" or PCS_FIN = 
"375B" or PCS_FIN = "375b" or PCS_FIN = "376A" or PCS_FIN = "376a" or PCS_FIN = "376B" or PCS_FIN = "376b" or PCS_FIN = "376C" or PCS_FIN = "376c" or PCS_FIN = "376D" or PCS_FIN = "376d" or PCS_FIN = "376E" or PCS_FIN = "376e" or PCS_FIN = "376F" or PCS_FIN = "376f" or PCS_FIN = "376G" or PCS_FIN = "376g" or PCS_FIN = "377A" or PCS_FIN = "377a" or PCS_FIN = "380A" or PCS_FIN = "380a" or PCS_FIN = "381A" or PCS_FIN = "381a" or PCS_FIN = 
"382A" or PCS_FIN = "382a" or PCS_FIN = "382B" or PCS_FIN = "382b" or PCS_FIN = "382C" or PCS_FIN = "382c" or PCS_FIN = "382D" or PCS_FIN = "382d" or PCS_FIN = "383A" or PCS_FIN = "383a" or PCS_FIN = "383B" or PCS_FIN = "383b" or PCS_FIN = "383C" or PCS_FIN = "383c" or PCS_FIN = "384A" or PCS_FIN = "384a" or PCS_FIN = "384B" or PCS_FIN = "384b" or PCS_FIN = "384C" or PCS_FIN = "384c" or PCS_FIN = "385A" or PCS_FIN = "385a" or PCS_FIN = "385B" or PCS_FIN = "385b" or PCS_FIN = "385C" or PCS_FIN = "385c" or PCS_FIN = "386A" or PCS_FIN = "386a" or PCS_FIN = "386D" or PCS_FIN = "386d" or PCS_FIN = "386E" or PCS_FIN = "386e" or PCS_FIN = "387A" or PCS_FIN = "387a" or PCS_FIN = "387B" or PCS_FIN = "387b" or PCS_FIN = "387C" or PCS_FIN = "387c" or PCS_FIN = "387D" or PCS_FIN = "387d" or PCS_FIN = "387E" or PCS_FIN = "387e" or PCS_FIN = "387F" or PCS_FIN = "387f" or PCS_FIN = "388A" or PCS_FIN = "388a" or PCS_FIN = "388B" or PCS_FIN = "388b" or PCS_FIN = "388C" or PCS_FIN = "388c" or PCS_FIN = "388D" or PCS_FIN = "388d" or PCS_FIN = "388E" or PCS_FIN = "388e" or PCS_FIN = "389A" or PCS_FIN = "389a" or PCS_FIN = "389B" or PCS_FIN = "389b" or PCS_FIN = "389C" or PCS_FIN = "389c"
	then PCS_FIN_score = 85;
if PCS_FIN = "421E" or PCS_FIN =  "432E" or PCS_FIN =  "442D" or PCS_FIN =  "454A" or PCS_FIN =  "454B" or PCS_FIN =  "455D" or PCS_FIN =  "474D" or PCS_FIN =  "479D" or PCS_FIN = 
"421A" or PCS_FIN = "421a" or PCS_FIN = "421B" or PCS_FIN = "421b" or PCS_FIN = "422A" or PCS_FIN = "422a" or PCS_FIN = "422B" or PCS_FIN = "422b" or PCS_FIN = "422C" or PCS_FIN = "422c" or PCS_FIN = "422D" or PCS_FIN = "422d" or PCS_FIN = "422E" or PCS_FIN = "422e" or PCS_FIN = "423A" or PCS_FIN = "423a" or PCS_FIN = "423B" or PCS_FIN = "423b" or PCS_FIN = "424A" or PCS_FIN = "424a" or PCS_FIN = "425A" or PCS_FIN = "425a" or PCS_FIN = "431A" or PCS_FIN = "431a" or PCS_FIN = "431B" or PCS_FIN = "431b" or PCS_FIN = "431C" or PCS_FIN = "431c" or PCS_FIN = "431D" or PCS_FIN = "431d" or PCS_FIN = "431E" or PCS_FIN = "431e" or PCS_FIN = "431F" or PCS_FIN = "431f" or PCS_FIN = "431G" or PCS_FIN = "431g" or PCS_FIN = "432A" or PCS_FIN = "432a" or PCS_FIN = "432B" or PCS_FIN = "432b" or PCS_FIN = "432C" or PCS_FIN = "432c" or PCS_FIN = "432D" or PCS_FIN = "432d" or PCS_FIN = "433A" or PCS_FIN = "433a" or PCS_FIN = "433B" or PCS_FIN = "433b" or PCS_FIN = "433C" or PCS_FIN = "433c" or PCS_FIN = "433D" or PCS_FIN = "433d" or PCS_FIN = "434A" or PCS_FIN = "434a" or PCS_FIN = "434B" or PCS_FIN = "434b" or PCS_FIN = "434C" or PCS_FIN = "434c" or PCS_FIN = "434D" or PCS_FIN = "434d" or PCS_FIN = "434E" or PCS_FIN = 
"434e" or PCS_FIN = "434F" or PCS_FIN = "434f" or PCS_FIN = "434G" or PCS_FIN = "434g" or PCS_FIN = "435A" or PCS_FIN = "435a" or PCS_FIN = "435B" or PCS_FIN = "435b" or PCS_FIN = "441A" or PCS_FIN = "441a" or PCS_FIN = "441B" or PCS_FIN = "441b" or PCS_FIN = "451A" or PCS_FIN = "451a" or PCS_FIN = "451B" or PCS_FIN = "451b" or PCS_FIN = "451C" or PCS_FIN = "451c" or PCS_FIN = "451D" or PCS_FIN = "451d" or PCS_FIN = "451E" or PCS_FIN = "451e" or PCS_FIN = "451F" or PCS_FIN = "451f" or PCS_FIN = "452A" or PCS_FIN = "452a" or PCS_FIN = "452B" or PCS_FIN = "452b" or PCS_FIN = "461A" or PCS_FIN = "461a" or PCS_FIN = "461D" or PCS_FIN = "461d" or PCS_FIN = "461E" or PCS_FIN = "461e" or PCS_FIN = "461F" or PCS_FIN = "461f" or PCS_FIN = "462A" or PCS_FIN = "462a" or PCS_FIN = "462B" or PCS_FIN = "462b" or PCS_FIN = "462C" or PCS_FIN = "462c" or PCS_FIN = "462D" or PCS_FIN = "462d" or PCS_FIN = "462E" or PCS_FIN = "462e" or PCS_FIN = "463A" or PCS_FIN = "463a" or PCS_FIN = "463B" or PCS_FIN = "463b" or PCS_FIN = "463C" or PCS_FIN = "463c" or PCS_FIN = "463D" or PCS_FIN = "463d" or PCS_FIN = "463E" or PCS_FIN = "463e" or PCS_FIN = "464A" or PCS_FIN = "464a" or PCS_FIN = "464B" or PCS_FIN = "464b" or PCS_FIN = 
"451G" or PCS_FIN =  "451g" or PCS_FIN = "451H" or PCS_FIN =  "451h" or PCS_FIN = "461B" or PCS_FIN =  "461b" or PCS_FIN = "461C" or PCS_FIN =  "461c" or PCS_FIN = "486B" or PCS_FIN =  "486b" or PCS_FIN = "486C" or PCS_FIN =  "486c" or PCS_FIN = 
"465A" or PCS_FIN = "465a" or PCS_FIN = "465B" or PCS_FIN = "465b" or PCS_FIN = "465C" or PCS_FIN = "465c" or PCS_FIN = "466A" or PCS_FIN = "466a" or PCS_FIN = "466B" or PCS_FIN = "466b" or PCS_FIN = "466C" or PCS_FIN = "466c" or PCS_FIN = "467A" or PCS_FIN = "467a" or PCS_FIN = "467B" or PCS_FIN = "467b" or PCS_FIN = "467C" or PCS_FIN = "467c" or PCS_FIN = "467D" or PCS_FIN = "467d" or PCS_FIN = "468A" or PCS_FIN = "468a" or PCS_FIN = "468B" or PCS_FIN = "468b" or PCS_FIN = "471A" or PCS_FIN = "471a" or PCS_FIN = "471B" or PCS_FIN = "471b" or PCS_FIN = "472A" or PCS_FIN = "472a" or PCS_FIN = "472B" or PCS_FIN = "472b" or PCS_FIN = "472C" or PCS_FIN = "472c" or PCS_FIN = "472D" or PCS_FIN = "472d" or PCS_FIN = "473A" or PCS_FIN = "473a" or PCS_FIN = "473B" or PCS_FIN = "473b" or PCS_FIN = "473C" or PCS_FIN = "473c" or PCS_FIN = "474A" or PCS_FIN = "474a" or PCS_FIN = "474B" or PCS_FIN = "474b" or PCS_FIN = "474C" or PCS_FIN = "474c" or PCS_FIN = "475A" or PCS_FIN = "475a" or PCS_FIN = "475B" or PCS_FIN = "475b" or PCS_FIN = "476A" or PCS_FIN = "476a" or PCS_FIN = "476B" or PCS_FIN = "476b" or PCS_FIN = "477A" or PCS_FIN = "477a" or PCS_FIN = "477B" or PCS_FIN = "477b" or PCS_FIN = "477C" or PCS_FIN = 
"477c" or PCS_FIN = "477D" or PCS_FIN = "477d" or PCS_FIN = "478A" or PCS_FIN = "478a" or PCS_FIN = "478B" or PCS_FIN = "478b" or PCS_FIN = "478C" or PCS_FIN = "478c" or PCS_FIN = "478D" or PCS_FIN = "478d" or PCS_FIN = "479A" or PCS_FIN = "479a" or PCS_FIN = "479B" or PCS_FIN = "479b" or PCS_FIN = "480A" or PCS_FIN = "480a" or PCS_FIN = "480B" or PCS_FIN = "480b" or PCS_FIN = "481A" or PCS_FIN = "481a" or PCS_FIN = "481B" or PCS_FIN = "481b" or PCS_FIN = "482A" or PCS_FIN = "482a" or PCS_FIN = "483A" or PCS_FIN = "483a" or PCS_FIN = "484A" or PCS_FIN = "484a" or PCS_FIN = "484B" or PCS_FIN = "484b" or PCS_FIN = "485A" or PCS_FIN = "485a" or PCS_FIN = "485B" or PCS_FIN = "485b" or PCS_FIN = "486A" or PCS_FIN = "486a" or PCS_FIN = "486D" or PCS_FIN = "486d" or PCS_FIN = "486E" or PCS_FIN = "486e" or PCS_FIN = "487A" or PCS_FIN = "487a" or PCS_FIN = "487B" or PCS_FIN = "487b" or PCS_FIN = "488A" or PCS_FIN = "488a" or PCS_FIN = "488B" or PCS_FIN = "488b"
	then PCS_FIN_score = -3;
if PCS_FIN = "542D" or PCS_FIN =  "556B" or PCS_FIN = 
"521A" or PCS_FIN = "521a" or PCS_FIN = "521B" or PCS_FIN = "521b" or PCS_FIN = "522A" or PCS_FIN = "522a" or PCS_FIN = "523A" or PCS_FIN = "523a" or PCS_FIN = "524A" or PCS_FIN = "524a" or PCS_FIN = "525A" or PCS_FIN = "525a" or PCS_FIN = "525B" or PCS_FIN = "525b" or PCS_FIN = "525C" or PCS_FIN = "525c" or PCS_FIN = "525D" or PCS_FIN = "525d" or PCS_FIN = "526A" or PCS_FIN = "526a" or PCS_FIN = "526B" or PCS_FIN = "526b" or PCS_FIN = "526C" or PCS_FIN = "526c" or PCS_FIN = "526D" or PCS_FIN = "526d" or PCS_FIN = "526E" or PCS_FIN = "526e" or PCS_FIN = "531A" or PCS_FIN = "531a" or PCS_FIN = "531B" or PCS_FIN = "531b" or PCS_FIN = "531C" or PCS_FIN = "531c" or PCS_FIN = "532A" or PCS_FIN = "532a" or PCS_FIN = "532B" or PCS_FIN = "532b" or PCS_FIN = "532C" or PCS_FIN = "533A" or PCS_FIN = "533a" or PCS_FIN = "533B" or PCS_FIN = "533b" or PCS_FIN = "533C" or PCS_FIN = "533c" or PCS_FIN = "534A" or PCS_FIN = "534a" or PCS_FIN = "534B" or PCS_FIN = "534b" or PCS_FIN = "541A" or PCS_FIN = "541a" or PCS_FIN = "541D" or PCS_FIN = "541d" or PCS_FIN = "542A" or PCS_FIN = "542" or PCS_FIN = "542B" or PCS_FIN = "542b" or PCS_FIN = "543A" or PCS_FIN = "543a" or PCS_FIN = "543D" or PCS_FIN = "543d" or PCS_FIN = "543B" or PCS_FIN =  "543b" or PCS_FIN = "543C" or PCS_FIN =  "543c" or PCS_FIN = "543E" or PCS_FIN =  "543e" or PCS_FIN = "543F" or PCS_FIN =  "543f" or PCS_FIN = "543G" or PCS_FIN =  "543g" or PCS_FIN = "543H" or PCS_FIN =  "543h" or PCS_FIN = 
"523B" or PCS_FIN =  "523b" or PCS_FIN = "523C" or PCS_FIN =  "523c" or PCS_FIN = "523D" or PCS_FIN =  "523d" or PCS_FIN = "524B" or PCS_FIN =  "524b" or PCS_FIN = "524C" or PCS_FIN =  "524c" or PCS_FIN = "524D" or PCS_FIN =  "524d" or PCS_FIN = "541B" or PCS_FIN =  "541b" or PCS_FIN = "541C" or PCS_FIN =  "541c" or PCS_FIN = "544A" or PCS_FIN = "544a" or PCS_FIN = "545A" or PCS_FIN = "545a" or PCS_FIN = "545B" or PCS_FIN = "545b" or PCS_FIN = "545C" or PCS_FIN = "545c" or PCS_FIN = "545D" or PCS_FIN = "545d" or PCS_FIN = "546A" or PCS_FIN = "546a" or PCS_FIN = "546B" or PCS_FIN = "546b" or PCS_FIN = "546C" or PCS_FIN = "546c" or PCS_FIN = "546D" or PCS_FIN = "546d" or PCS_FIN = "546E" or PCS_FIN = "546e" or PCS_FIN = "551A" or PCS_FIN = "551a" or PCS_FIN = "552A" or PCS_FIN = "552a" or PCS_FIN = "553A" or PCS_FIN = "553a" or PCS_FIN = "553B" or PCS_FIN =  "553b" or PCS_FIN = "553C" or PCS_FIN =  "553c" or PCS_FIN = "554A" or PCS_FIN = "554a" or PCS_FIN = "554B" or PCS_FIN = "554b" or PCS_FIN = "554C" or PCS_FIN = "554c" or PCS_FIN = "554D" or PCS_FIN = "554d" or PCS_FIN = "554E" or PCS_FIN = "554e" or PCS_FIN = "554F" or PCS_FIN = "554f" or PCS_FIN = "554G" or PCS_FIN = "554g" or PCS_FIN = "554H" or PCS_FIN = "554h" or PCS_FIN = "554J" or PCS_FIN = "554j" or PCS_FIN = "555A" or PCS_FIN = "555a" or PCS_FIN = "556A" or PCS_FIN = "556a" or PCS_FIN = "561A" or PCS_FIN = "561a" or PCS_FIN = "561B" or PCS_FIN =  "561b" or PCS_FIN = "561C" or PCS_FIN =  "561c" or PCS_FIN = "561D" or PCS_FIN = "561d" or PCS_FIN = "561E" or PCS_FIN = "561e" or PCS_FIN = "561F" or PCS_FIN = "561f" or PCS_FIN = "562A" or PCS_FIN = "562a" or PCS_FIN = "562B" or PCS_FIN = "562b" or PCS_FIN = "563A" or PCS_FIN = "563a" or PCS_FIN = "563B" or PCS_FIN = "563b" or PCS_FIN = "563C" or PCS_FIN = "564A" or PCS_FIN = "564a" or PCS_FIN = "564B" or PCS_FIN = "564b"
	then PCS_FIN_score = -109;
if PCS_FIN = "621A" or PCS_FIN = "621a" or PCS_FIN = "621B" or PCS_FIN = "621b" or PCS_FIN = "621C" or PCS_FIN = "621c" or PCS_FIN = "621D" or PCS_FIN = "621d" or PCS_FIN = "621E" or PCS_FIN = "621e" or PCS_FIN = "621F" or PCS_FIN = "621f" or PCS_FIN = "621G" or PCS_FIN = "621g" or PCS_FIN = "622A" or PCS_FIN = "622a" or PCS_FIN = "622B" or PCS_FIN = "622b" or PCS_FIN = "622G" or PCS_FIN = "622g" or PCS_FIN = "622C" or PCS_FIN =  "622c" or PCS_FIN = "622D" or PCS_FIN =  "622d" or PCS_FIN = "622E" or PCS_FIN =  "622e" or PCS_FIN = "622F" or PCS_FIN =  "622f" or PCS_FIN = "623A" or PCS_FIN = "623a" or PCS_FIN = "623B" or PCS_FIN = "623b" or PCS_FIN = "623C" or PCS_FIN = "623c" or PCS_FIN = "623F" or PCS_FIN = "623f" or PCS_FIN = "623G" or PCS_FIN = "623g" or PCS_FIN = "623D" or PCS_FIN =  "623d" or PCS_FIN = "623E" or PCS_FIN =  "623e" or PCS_FIN = "624A" or PCS_FIN = "624a" or PCS_FIN = "624B" or PCS_FIN =  "624b" or PCS_FIN = "624C" or PCS_FIN =  "624c" or PCS_FIN = "624D" or PCS_FIN = "624d" or PCS_FIN = "624E" or PCS_FIN = "624e" or PCS_FIN = "624F" or PCS_FIN = "624f" or PCS_FIN = "624G" or PCS_FIN = "624g" or PCS_FIN = "625A" or PCS_FIN = "625a" or PCS_FIN = "625B" or PCS_FIN = "625b" or PCS_FIN = "625C" or PCS_FIN = "625c" or PCS_FIN = "625D" or PCS_FIN = "625d" or PCS_FIN = "625E" or PCS_FIN = "625e" or PCS_FIN = "625H" or PCS_FIN = "625h" or PCS_FIN = "625F" or PCS_FIN =  "625f" or PCS_FIN = "625G" or PCS_FIN =  "625g" or PCS_FIN = "626A" or PCS_FIN = "626a" or PCS_FIN = "626B" or PCS_FIN = "626b" or PCS_FIN = "626C" or PCS_FIN = "626c" or PCS_FIN = "627A" or PCS_FIN = "627a" or PCS_FIN = "627B" or PCS_FIN = 
"627b" or PCS_FIN = "627C" or PCS_FIN = "627c" or PCS_FIN = "627D" or PCS_FIN = "627d" or PCS_FIN = "627E" or PCS_FIN = "627e" or PCS_FIN = "627F" or PCS_FIN = "627f" or PCS_FIN = "628A" or PCS_FIN = "628a" or PCS_FIN = "628B" or PCS_FIN = "628b" or PCS_FIN = "628C" or PCS_FIN = "628c" or PCS_FIN = "628D" or PCS_FIN = "628d" or PCS_FIN = "628E" or PCS_FIN = "628e" or PCS_FIN = "628F" or PCS_FIN = "628f" or PCS_FIN = "628G" or PCS_FIN = "628g" or PCS_FIN = "631A" or PCS_FIN = "631a" or PCS_FIN = "632A" or PCS_FIN = "632a" or PCS_FIN = "632B" or PCS_FIN = "632b" or PCS_FIN = "632C" or PCS_FIN = "632c" or PCS_FIN = "632D" or PCS_FIN = "632d" or PCS_FIN = "632E" or PCS_FIN = "632e" or PCS_FIN = "632F" or PCS_FIN = "632f" or PCS_FIN = "632G" or PCS_FIN = "632g" or PCS_FIN = "632H" or PCS_FIN = "632h" or PCS_FIN = "632J" or PCS_FIN = "632j" or PCS_FIN = "632K" or PCS_FIN = "632k" or PCS_FIN = "633A" or PCS_FIN = "633a" or PCS_FIN = "633B" or PCS_FIN = "633b" or PCS_FIN = "633C" or PCS_FIN = "633c" or PCS_FIN = "633D" or PCS_FIN = "633d" or PCS_FIN = "634A" or PCS_FIN = "634a" or PCS_FIN = "634B" or PCS_FIN = "634b" or PCS_FIN = "634C" or PCS_FIN = "634c" or PCS_FIN = "634D" or PCS_FIN = "634d" or PCS_FIN = 
"635A" or PCS_FIN = "635a" or PCS_FIN = "636A" or PCS_FIN = "636a" or PCS_FIN = "636B" or PCS_FIN = "636b" or PCS_FIN = "636C" or PCS_FIN = "636c" or PCS_FIN = "636D" or PCS_FIN = "636d" or PCS_FIN = "637A" or PCS_FIN = "637a" or PCS_FIN = "637B" or PCS_FIN = "637b" or PCS_FIN = "637C" or PCS_FIN = "637c" or PCS_FIN = "637D" or PCS_FIN = "637d" or PCS_FIN = "641A" or PCS_FIN = "641a" or PCS_FIN = "641B" or PCS_FIN = "641b" or PCS_FIN = "642A" or PCS_FIN = "642a" or PCS_FIN = "642B" or PCS_FIN = "642b" or PCS_FIN = "643A" or PCS_FIN = "643a" or PCS_FIN = "644A" or PCS_FIN = "644a" or PCS_FIN = "651A" or PCS_FIN = "651a" or PCS_FIN = "651B" or PCS_FIN = "651b" or PCS_FIN = "652A" or PCS_FIN = "652a" or PCS_FIN = "652B" or PCS_FIN = "652b" or PCS_FIN = "653A" or PCS_FIN = "653a" or PCS_FIN = "654A" or PCS_FIN = "654a" or PCS_FIN = "654B" or PCS_FIN =  "654b" or PCS_FIN = "654C" or PCS_FIN =  "654c" or PCS_FIN = "655A" or PCS_FIN = "655a" or PCS_FIN = "656A" or PCS_FIN = "656a" or PCS_FIN = "656B" or PCS_FIN =  "656b" or PCS_FIN = "656C" or PCS_FIN =  "656c" or PCS_FIN = "671A" or PCS_FIN = "671a" or PCS_FIN = "671B" or PCS_FIN = "671b" or PCS_FIN = "671C" or PCS_FIN =  "671c" or PCS_FIN = "671D" or PCS_FIN =  "671d" or PCS_FIN = "672A" or PCS_FIN = "672a" or PCS_FIN = "673A" or PCS_FIN = "673a" or PCS_FIN = "673B" or PCS_FIN = "673b" or PCS_FIN = "673C" or PCS_FIN = "673c" or PCS_FIN = "674A" or PCS_FIN = "674a" or PCS_FIN = "674B" or PCS_FIN = 
"674b" or PCS_FIN = "674C" or PCS_FIN = "674c" or PCS_FIN = "674D" or PCS_FIN = "674d" or PCS_FIN = "674E" or PCS_FIN = "674e" or PCS_FIN = "675A" or PCS_FIN = "675a" or PCS_FIN = "675B" or PCS_FIN = "675b" or PCS_FIN = "675C" or PCS_FIN = "675c" or PCS_FIN = "676A" or PCS_FIN = "676a" or PCS_FIN = "676B" or PCS_FIN = "676b" or PCS_FIN = "676C" or PCS_FIN = "676c" or PCS_FIN = "676D" or PCS_FIN = "676d" or PCS_FIN = "676E" or PCS_FIN = "676e" or PCS_FIN = "681A" or PCS_FIN = "681a" or PCS_FIN = "681B" or PCS_FIN = "681b" or PCS_FIN = "682A" or PCS_FIN = "682a" or PCS_FIN = "683A" or PCS_FIN = "683a" or PCS_FIN = "684A" or PCS_FIN = "684a" or PCS_FIN = "684B" or PCS_FIN = "684b" or PCS_FIN = "685A" or PCS_FIN = "685a" or PCS_FIN = "691A" or PCS_FIN = "691a" or PCS_FIN = "691B" or PCS_FIN = "691b" or PCS_FIN = "691C" or PCS_FIN = "691c" or PCS_FIN = "691D" or PCS_FIN = "691d" or PCS_FIN = "691E" or PCS_FIN = "691e" or PCS_FIN = "691F" or PCS_FIN = "691f" or PCS_FIN = "692A" or PCS_FIN = "692a"
then PCS_FIN_score = -68;

if STAT_FIN = "01" then STAT_FIN_score = -80;		/*FREELANCE*/
if STAT_FIN = "03" then STAT_FIN_score = 60;		/*FONCTIONNAIRE*/
if STAT_FIN = "04" then STAT_FIN_score = 40;		/*CDI*/
if STAT_FIN = "05" then STAT_FIN_score = -88;		/*CDD*/
if STAT_FIN = "07" then STAT_FIN_score = -90;		/*Intérim*/
if STAT_FIN = "02" or STAT_FIN = "06" or STAT_FIN = "08" or STAT_FIN = "10" or STAT_FIN = "11" or STAT_FIN = "12" or STAT_FIN = "13" 
or STAT_FIN = "14" or STAT_FIN = "16" or STAT_FIN = "18" or STAT_FIN = "20" or STAT_FIN = "21" or STAT_FIN = "22" or STAT_FIN = "23" or STAT_FIN = "24" 
or STAT_FIN = "25" or STAT_FIN = "9" then STAT_FIN_score = -106;		/*Autre*/

if EP49 = "1" then EP49_score = 20;
if EP49 = "2" then EP49_score = -137;
/*else EP49_score = 0;*/

if EP70 = "1" then EP70_score = -18;	
if EP70 = "2" then EP70_score = 73;		
if EP70 = "3" then EP70_score = 75;
if EP70 = "4" then EP70_score = 83;
/*else EP70_score = 0;*/

if SALPRFIN > 0 AND SALPRFIN <= 1200 then SALPRFIN_score = -125;		
else if SALPRFIN > 1200 AND SALPRFIN <= 1500 then SALPRFIN_score = -5;	
else if SALPRFIN > 1500 AND SALPRFIN <= 1900 then SALPRFIN_score = 50;
else if SALPRFIN > 1900 then SALPRFIN_score = 101;

else if SALPRDEB >0 AND SALPRFIN < 1200 then SALPRFIN_score = -125;	

SCORE_FINAL = OP2_score + PCS_FIN_score + STAT_FIN_score + EP49_score + EP70_score + SALPRFIN_score;

RUN;

PROC SGPLOT DATA = TER.score;
HBOX SCORE_FINAL;
*WEIGHT PONDEF;
RUN;

PROC MEANS DATA = TER.score maxdec=2 N MEAN MEDIAN STD MIN MAX ;
VAR SCORE_FINAL;
WEIGHT PONDEF;			/*LA PONDERATION MARCHE PAS ?*/
RUN;

/*METTRE A -583 (min = -582) le score de réussite professionnel de ceux qui n'ont jamais eu d'emploi*/
DATA TER.score;	
SET TER.score;
if nmemp = 0 then SCORE_FINAL = -583;
RUN;

PROC FREQ DATA=TER.score;
where nmemp=0;
TABLES SCORE_FINAL;
*WEIGHT PONDEF;
RUN;

PROC FREQ DATA=TER.score;
TABLES SCORE_FINAL;
*WEIGHT PONDEF;
RUN;

PROC FREQ DATA=TER.score;
TABLES EP49 EP70;
FORMAT EP49 $EP49_fs. EP70 $EP70_fs.;
*WEIGHT PONDEF;
RUN;

*TEST**************************TEST*;

DATA TEST;
SET TER.SCORE;
*if ep49="" then delete;
*if ep70="" then delete;
if SCORE_FINAL NE "" then delete;
RUN;

PROC FREQ DATA=TEST;
TABLES SCORE_FINAL;
*WEIGHT PONDEF;
RUN;

/************EP49 (temps plein/partiel)*************/
PROC FREQ DATA=TER.individu_emploi;
TABLE EP49;
FORMAT EP49 $EP49_fs.;
WEIGHT PONDEF;
RUN;

PROC FREQ DATA=TER.individu_emploi;	/*temps partiel subi*/
TABLE EP52A / MISSING;
FORMAT EP52A $EP52A_fs.;
WEIGHT PONDEF;
RUN;

DATA TER.score;
SET TER.individu_emploi (keep=IDENT PONDEF OP2 PCS_FIN STAT_FIN EP49 EP70 SALPRFIN PART_EMP);
if IDENT = "B0046110" then pcs_fin="421E";
RUN;

PROC FREQ DATA = TER.score;
TABLES OP2 PCS_FIN STAT_FIN EP49 EP70 SALPRFIN PART_EMP;
FORMAT OP2 $OP2_fs. PCS_FIN $PCS_fs. STAT_FIN $STAT_fs. EP49 $EP49_fs. EP70 $EP70_fs. SALPRFIN SALPRFIN_fs. PART_EMP PART_EMP_fs.	;
*WEIGHT PONDEF;
RUN;

DATA test;
SET TER.score;
if stat_fin = "" then delete;
if pcs_fin NE "" then delete;
run;


ods graphics / height=1200 width = 1200;
PROC CORRESP data=TER.score mca out=resul PLOTS=all DIMENS=2 ;
tables OP2 PCS_FIN STAT_FIN EP49 EP70 SALPRFIN PART_EMP;
FORMAT OP2 $OP2_fs. PCS_FIN $PCS_fs. STAT_FIN $STAT_fs. EP49 $EP49_fs. EP70 $EP70_fs. SALPRFIN SALPRFIN_fs. PART_EMP PART_EMP_fs.	;
WEIGHT PONDEF;
RUN;

DATA TER.score;
SET TER.individu_emploi;

if OP2 = "1" then OP2_score = 3;
if OP2 = "2" then OP2_score = -9;

if PCS_FIN = "111A" or PCS_FIN =  "111a" or PCS_FIN =  "111B" or PCS_FIN =  "111b" or PCS_FIN =  "111C" or PCS_FIN =  "111c" or PCS_FIN =  "111D" or PCS_FIN =  "111d" or PCS_FIN =  "111E" or PCS_FIN =   "111e" or PCS_FIN =  "111F" or PCS_FIN =  "111f" or PCS_FIN =  "121A" or PCS_FIN =  "121a" or PCS_FIN =  "121B" or PCS_FIN =  "121b" or PCS_FIN =  "121C" or PCS_FIN =  "121c" or PCS_FIN =  "121D" or PCS_FIN =  "121d" or PCS_FIN =  "121E" or PCS_FIN =  "121e" or PCS_FIN =  "121F" or PCS_FIN =  "121f" or PCS_FIN =  "122A" or PCS_FIN =  "122a" or PCS_FIN =  "122B" or PCS_FIN =  "122b" or PCS_FIN =  "122C" or PCS_FIN =  "122c" or PCS_FIN =  "131A" or PCS_FIN =  "131a" or PCS_FIN =  "131B" or PCS_FIN =  "131b" or PCS_FIN =  "131C" or PCS_FIN =  "131c" or PCS_FIN =  "131D" or PCS_FIN =  "131d" or PCS_FIN =  "131E" or PCS_FIN =  "131e" or PCS_FIN =  "131F" or PCS_FIN =  "131f" 
	then PCS_FIN_score = 3;
if PCS_FIN = "241F" or PCS_FIN = "211A" or PCS_FIN = "211a" or PCS_FIN = "211B" or PCS_FIN = "211b" or PCS_FIN = "211C" or PCS_FIN = "211c" or PCS_FIN = "211D" or PCS_FIN = "211d" or PCS_FIN = "211E" or PCS_FIN = "211e" or PCS_FIN = "211F" or PCS_FIN = "211f" or PCS_FIN = "211G" or PCS_FIN = "211g" or PCS_FIN = "211H" or PCS_FIN = "211h" or PCS_FIN = "211J" or PCS_FIN = "211j" or PCS_FIN = "212A" or PCS_FIN = "212a" or PCS_FIN = "212B" or PCS_FIN = "212b" or PCS_FIN = "212C" or PCS_FIN = "212c" or PCS_FIN = "212D" or PCS_FIN = "212d" or PCS_FIN = "213A" or PCS_FIN = "213a" or PCS_FIN = "214A" or PCS_FIN = "214a" or PCS_FIN = "214B" or PCS_FIN = "214b" or PCS_FIN = "214C" or PCS_FIN = "214c" or PCS_FIN = "214D" or PCS_FIN = "214d" or PCS_FIN = "214E" or PCS_FIN = "214e" or PCS_FIN = "214F" or PCS_FIN = "214f" or PCS_FIN = "215A" or PCS_FIN = "215a" or PCS_FIN = "215B" or PCS_FIN = "215b" or PCS_FIN = "215C" or PCS_FIN = "215c" or PCS_FIN = "215D" or PCS_FIN = "215d" or PCS_FIN = "216A" or PCS_FIN = "216a" or PCS_FIN = "216B" or PCS_FIN = "216b" or PCS_FIN = "216C" or PCS_FIN = "216c" or PCS_FIN = "217A" or PCS_FIN = "217a" or PCS_FIN = "217B" or PCS_FIN = "217b" or PCS_FIN = "217C" or PCS_FIN = "217c" or PCS_FIN = "217D" or PCS_FIN = 
"217d" or PCS_FIN = "217E" or PCS_FIN = "217e" or PCS_FIN = "218A" or PCS_FIN = "218a" or PCS_FIN = "219A" or PCS_FIN = "219a" or PCS_FIN = "221A" or PCS_FIN = "221a" or PCS_FIN = "221B" or PCS_FIN = "221b" or PCS_FIN = "222A" or PCS_FIN = "222a" or PCS_FIN = "222B" or PCS_FIN = "222b" or PCS_FIN = "223A" or PCS_FIN = "223a" or PCS_FIN = "223B" or PCS_FIN = "223b" or PCS_FIN = "223C" or PCS_FIN = "223c" or PCS_FIN = "223D" or PCS_FIN = "223d" or PCS_FIN = "223E" or PCS_FIN = "223e" or PCS_FIN = "223F" or PCS_FIN = "223f" or PCS_FIN = "223G" or PCS_FIN = "223g" or PCS_FIN = "223H" or PCS_FIN = "223h" or PCS_FIN = "224A" or PCS_FIN = "224a" or PCS_FIN = "224B" or PCS_FIN = "224b" or PCS_FIN = "224C" or PCS_FIN = "224c" or PCS_FIN = "224D" or PCS_FIN = "224d" or PCS_FIN = "225A" or PCS_FIN = "225a" or PCS_FIN = "226A" or PCS_FIN = "226a" or PCS_FIN = "226B" or PCS_FIN = "226b" or PCS_FIN = "226C" or PCS_FIN = "226c" or PCS_FIN = "227A" or PCS_FIN = "227a" or PCS_FIN = "227B" or PCS_FIN = "227b" or PCS_FIN = "227C" or PCS_FIN = "227c" or PCS_FIN = "227D" or PCS_FIN = "227d" or PCS_FIN = "231A" or PCS_FIN = "231a" or PCS_FIN = "232A" or PCS_FIN = "232a" or PCS_FIN = "233A" or PCS_FIN = "233a" or PCS_FIN = 
"233B" or PCS_FIN = "233b" or PCS_FIN = "233C" or PCS_FIN = "233c" or PCS_FIN = "233D" or PCS_FIN = "233d"
	then PCS_FIN_score = 3;
if PCS_FIN = "332F" or PCS_FIN =  "352E" or PCS_FIN = "311A" or PCS_FIN = "311a" or PCS_FIN = "311B" or PCS_FIN = "311b" or PCS_FIN = "311C" or PCS_FIN = "311c" or PCS_FIN = "311D" or PCS_FIN = "311d" or PCS_FIN = "311E" or PCS_FIN = "311e" or PCS_FIN = "311F" or PCS_FIN = "311f" or PCS_FIN = "312A" or PCS_FIN = "312a" or PCS_FIN = "312B" or PCS_FIN = "312b" or PCS_FIN = "312C" or PCS_FIN = "312c" or PCS_FIN = "312D" or PCS_FIN = "312d" or PCS_FIN = "312E" or PCS_FIN = "312e" or PCS_FIN = "312F" or PCS_FIN = "312f" or PCS_FIN = "312G" or PCS_FIN = "312g" or PCS_FIN = "313A" or PCS_FIN = "313a" or PCS_FIN = "331A" or PCS_FIN = '331a' or PCS_FIN = "332A" or PCS_FIN = "332a" or PCS_FIN = "332B" or PCS_FIN = "332b" or PCS_FIN = "333A" or PCS_FIN = "333a" or PCS_FIN = "333B" or PCS_FIN = "333b" or PCS_FIN = "333C" or PCS_FIN = "333c" or PCS_FIN = "333D" or PCS_FIN = "333d" or PCS_FIN = "333E" or PCS_FIN = "333e" or PCS_FIN = "333F" or PCS_FIN = "333f" or PCS_FIN = "334A" or PCS_FIN = "334a" or PCS_FIN = "335A" or PCS_FIN = "335a" or PCS_FIN = "341A" or PCS_FIN = "341a" or PCS_FIN = "341B" or PCS_FIN = "341b" or PCS_FIN = "342A" or PCS_FIN = "342a" or PCS_FIN = "342E" or PCS_FIN = "342e" or PCS_FIN = "343A" or PCS_FIN = "343a" or PCS_FIN = "344A" or PCS_FIN = 
"342B" or PCS_FIN =  "342b" or PCS_FIN = "342C" or PCS_FIN =  "342c" or PCS_FIN = "342D" or PCS_FIN =  "342d" or PCS_FIN = "342F" or PCS_FIN =  "342f" or PCS_FIN = "342G" or PCS_FIN =  "342g" or PCS_FIN = "342H" or PCS_FIN =  "342h" or PCS_FIN = "354E" or PCS_FIN =  "354e" or PCS_FIN = "354F" or PCS_FIN =  "354f" or PCS_FIN = "381B" or PCS_FIN =  "381b" or PCS_FIN = "381C" or PCS_FIN =  "381c" or PCS_FIN = "386B" or PCS_FIN =  "386b" or PCS_FIN = "386C" or PCS_FIN =  "386c" or PCS_FIN = 
"344a" or PCS_FIN = "344B" or PCS_FIN = "344b" or PCS_FIN = "344C" or PCS_FIN = "344c" or PCS_FIN = "344D" or PCS_FIN = "344d" or PCS_FIN = "351A" or PCS_FIN = "351a" or PCS_FIN = "352A" or PCS_FIN = "352a" or PCS_FIN = "352B" or PCS_FIN = "352b" or PCS_FIN = "353A" or PCS_FIN = "353a" or PCS_FIN = "353B" or PCS_FIN = "353b" or PCS_FIN = "353C" or PCS_FIN = "353c" or PCS_FIN = "354A" or PCS_FIN = "354a" or PCS_FIN = "354B" or PCS_FIN = "354b" or PCS_FIN = "354C" or PCS_FIN = "354c" or PCS_FIN = "354D" or PCS_FIN = "354d" or PCS_FIN = "354G" or PCS_FIN = "354g" or PCS_FIN = "371A" or PCS_FIN = "371a" or PCS_FIN = "372A" or PCS_FIN = "372a" or PCS_FIN = "372B" or PCS_FIN = "372b" or PCS_FIN = "372C" or PCS_FIN = "372c" or PCS_FIN = "372D" or PCS_FIN = "372d" or PCS_FIN = "372E" or PCS_FIN = "372e" or PCS_FIN = "372F" or PCS_FIN = "372f" or PCS_FIN = "373A" or PCS_FIN = "373a" or PCS_FIN = "373B" or PCS_FIN = "373b" or PCS_FIN = "373C" or PCS_FIN = "373c" or PCS_FIN = "373D" or PCS_FIN = "373d" or PCS_FIN = "374A" or PCS_FIN = "374a" or PCS_FIN = "374B" or PCS_FIN = "374b" or PCS_FIN = "374C" or PCS_FIN = "374c" or PCS_FIN = "374D" or PCS_FIN = "374d" or PCS_FIN = "375A" or PCS_FIN = "375a" or PCS_FIN = 
"375B" or PCS_FIN = "375b" or PCS_FIN = "376A" or PCS_FIN = "376a" or PCS_FIN = "376B" or PCS_FIN = "376b" or PCS_FIN = "376C" or PCS_FIN = "376c" or PCS_FIN = "376D" or PCS_FIN = "376d" or PCS_FIN = "376E" or PCS_FIN = "376e" or PCS_FIN = "376F" or PCS_FIN = "376f" or PCS_FIN = "376G" or PCS_FIN = "376g" or PCS_FIN = "377A" or PCS_FIN = "377a" or PCS_FIN = "380A" or PCS_FIN = "380a" or PCS_FIN = "381A" or PCS_FIN = "381a" or PCS_FIN = 
"382A" or PCS_FIN = "382a" or PCS_FIN = "382B" or PCS_FIN = "382b" or PCS_FIN = "382C" or PCS_FIN = "382c" or PCS_FIN = "382D" or PCS_FIN = "382d" or PCS_FIN = "383A" or PCS_FIN = "383a" or PCS_FIN = "383B" or PCS_FIN = "383b" or PCS_FIN = "383C" or PCS_FIN = "383c" or PCS_FIN = "384A" or PCS_FIN = "384a" or PCS_FIN = "384B" or PCS_FIN = "384b" or PCS_FIN = "384C" or PCS_FIN = "384c" or PCS_FIN = "385A" or PCS_FIN = "385a" or PCS_FIN = "385B" or PCS_FIN = "385b" or PCS_FIN = "385C" or PCS_FIN = "385c" or PCS_FIN = "386A" or PCS_FIN = "386a" or PCS_FIN = "386D" or PCS_FIN = "386d" or PCS_FIN = "386E" or PCS_FIN = "386e" or PCS_FIN = "387A" or PCS_FIN = "387a" or PCS_FIN = "387B" or PCS_FIN = "387b" or PCS_FIN = "387C" or PCS_FIN = "387c" or PCS_FIN = "387D" or PCS_FIN = "387d" or PCS_FIN = "387E" or PCS_FIN = "387e" or PCS_FIN = "387F" or PCS_FIN = "387f" or PCS_FIN = "388A" or PCS_FIN = "388a" or PCS_FIN = "388B" or PCS_FIN = "388b" or PCS_FIN = "388C" or PCS_FIN = "388c" or PCS_FIN = "388D" or PCS_FIN = "388d" or PCS_FIN = "388E" or PCS_FIN = "388e" or PCS_FIN = "389A" or PCS_FIN = "389a" or PCS_FIN = "389B" or PCS_FIN = "389b" or PCS_FIN = "389C" or PCS_FIN = "389c"
	then PCS_FIN_score = 8;
if PCS_FIN = "421E" or PCS_FIN =  "432E" or PCS_FIN =  "442D" or PCS_FIN =  "454A" or PCS_FIN =  "454B" or PCS_FIN =  "455D" or PCS_FIN =  "474D" or PCS_FIN =  "479D" or PCS_FIN = 
"421A" or PCS_FIN = "421a" or PCS_FIN = "421B" or PCS_FIN = "421b" or PCS_FIN = "422A" or PCS_FIN = "422a" or PCS_FIN = "422B" or PCS_FIN = "422b" or PCS_FIN = "422C" or PCS_FIN = "422c" or PCS_FIN = "422D" or PCS_FIN = "422d" or PCS_FIN = "422E" or PCS_FIN = "422e" or PCS_FIN = "423A" or PCS_FIN = "423a" or PCS_FIN = "423B" or PCS_FIN = "423b" or PCS_FIN = "424A" or PCS_FIN = "424a" or PCS_FIN = "425A" or PCS_FIN = "425a" or PCS_FIN = "431A" or PCS_FIN = "431a" or PCS_FIN = "431B" or PCS_FIN = "431b" or PCS_FIN = "431C" or PCS_FIN = "431c" or PCS_FIN = "431D" or PCS_FIN = "431d" or PCS_FIN = "431E" or PCS_FIN = "431e" or PCS_FIN = "431F" or PCS_FIN = "431f" or PCS_FIN = "431G" or PCS_FIN = "431g" or PCS_FIN = "432A" or PCS_FIN = "432a" or PCS_FIN = "432B" or PCS_FIN = "432b" or PCS_FIN = "432C" or PCS_FIN = "432c" or PCS_FIN = "432D" or PCS_FIN = "432d" or PCS_FIN = "433A" or PCS_FIN = "433a" or PCS_FIN = "433B" or PCS_FIN = "433b" or PCS_FIN = "433C" or PCS_FIN = "433c" or PCS_FIN = "433D" or PCS_FIN = "433d" or PCS_FIN = "434A" or PCS_FIN = "434a" or PCS_FIN = "434B" or PCS_FIN = "434b" or PCS_FIN = "434C" or PCS_FIN = "434c" or PCS_FIN = "434D" or PCS_FIN = "434d" or PCS_FIN = "434E" or PCS_FIN = 
"434e" or PCS_FIN = "434F" or PCS_FIN = "434f" or PCS_FIN = "434G" or PCS_FIN = "434g" or PCS_FIN = "435A" or PCS_FIN = "435a" or PCS_FIN = "435B" or PCS_FIN = "435b" or PCS_FIN = "441A" or PCS_FIN = "441a" or PCS_FIN = "441B" or PCS_FIN = "441b" or PCS_FIN = "451A" or PCS_FIN = "451a" or PCS_FIN = "451B" or PCS_FIN = "451b" or PCS_FIN = "451C" or PCS_FIN = "451c" or PCS_FIN = "451D" or PCS_FIN = "451d" or PCS_FIN = "451E" or PCS_FIN = "451e" or PCS_FIN = "451F" or PCS_FIN = "451f" or PCS_FIN = "452A" or PCS_FIN = "452a" or PCS_FIN = "452B" or PCS_FIN = "452b" or PCS_FIN = "461A" or PCS_FIN = "461a" or PCS_FIN = "461D" or PCS_FIN = "461d" or PCS_FIN = "461E" or PCS_FIN = "461e" or PCS_FIN = "461F" or PCS_FIN = "461f" or PCS_FIN = "462A" or PCS_FIN = "462a" or PCS_FIN = "462B" or PCS_FIN = "462b" or PCS_FIN = "462C" or PCS_FIN = "462c" or PCS_FIN = "462D" or PCS_FIN = "462d" or PCS_FIN = "462E" or PCS_FIN = "462e" or PCS_FIN = "463A" or PCS_FIN = "463a" or PCS_FIN = "463B" or PCS_FIN = "463b" or PCS_FIN = "463C" or PCS_FIN = "463c" or PCS_FIN = "463D" or PCS_FIN = "463d" or PCS_FIN = "463E" or PCS_FIN = "463e" or PCS_FIN = "464A" or PCS_FIN = "464a" or PCS_FIN = "464B" or PCS_FIN = "464b" or PCS_FIN = 
"451G" or PCS_FIN =  "451g" or PCS_FIN = "451H" or PCS_FIN =  "451h" or PCS_FIN = "461B" or PCS_FIN =  "461b" or PCS_FIN = "461C" or PCS_FIN =  "461c" or PCS_FIN = "486B" or PCS_FIN =  "486b" or PCS_FIN = "486C" or PCS_FIN =  "486c" or PCS_FIN = 
"465A" or PCS_FIN = "465a" or PCS_FIN = "465B" or PCS_FIN = "465b" or PCS_FIN = "465C" or PCS_FIN = "465c" or PCS_FIN = "466A" or PCS_FIN = "466a" or PCS_FIN = "466B" or PCS_FIN = "466b" or PCS_FIN = "466C" or PCS_FIN = "466c" or PCS_FIN = "467A" or PCS_FIN = "467a" or PCS_FIN = "467B" or PCS_FIN = "467b" or PCS_FIN = "467C" or PCS_FIN = "467c" or PCS_FIN = "467D" or PCS_FIN = "467d" or PCS_FIN = "468A" or PCS_FIN = "468a" or PCS_FIN = "468B" or PCS_FIN = "468b" or PCS_FIN = "471A" or PCS_FIN = "471a" or PCS_FIN = "471B" or PCS_FIN = "471b" or PCS_FIN = "472A" or PCS_FIN = "472a" or PCS_FIN = "472B" or PCS_FIN = "472b" or PCS_FIN = "472C" or PCS_FIN = "472c" or PCS_FIN = "472D" or PCS_FIN = "472d" or PCS_FIN = "473A" or PCS_FIN = "473a" or PCS_FIN = "473B" or PCS_FIN = "473b" or PCS_FIN = "473C" or PCS_FIN = "473c" or PCS_FIN = "474A" or PCS_FIN = "474a" or PCS_FIN = "474B" or PCS_FIN = "474b" or PCS_FIN = "474C" or PCS_FIN = "474c" or PCS_FIN = "475A" or PCS_FIN = "475a" or PCS_FIN = "475B" or PCS_FIN = "475b" or PCS_FIN = "476A" or PCS_FIN = "476a" or PCS_FIN = "476B" or PCS_FIN = "476b" or PCS_FIN = "477A" or PCS_FIN = "477a" or PCS_FIN = "477B" or PCS_FIN = "477b" or PCS_FIN = "477C" or PCS_FIN = 
"477c" or PCS_FIN = "477D" or PCS_FIN = "477d" or PCS_FIN = "478A" or PCS_FIN = "478a" or PCS_FIN = "478B" or PCS_FIN = "478b" or PCS_FIN = "478C" or PCS_FIN = "478c" or PCS_FIN = "478D" or PCS_FIN = "478d" or PCS_FIN = "479A" or PCS_FIN = "479a" or PCS_FIN = "479B" or PCS_FIN = "479b" or PCS_FIN = "480A" or PCS_FIN = "480a" or PCS_FIN = "480B" or PCS_FIN = "480b" or PCS_FIN = "481A" or PCS_FIN = "481a" or PCS_FIN = "481B" or PCS_FIN = "481b" or PCS_FIN = "482A" or PCS_FIN = "482a" or PCS_FIN = "483A" or PCS_FIN = "483a" or PCS_FIN = "484A" or PCS_FIN = "484a" or PCS_FIN = "484B" or PCS_FIN = "484b" or PCS_FIN = "485A" or PCS_FIN = "485a" or PCS_FIN = "485B" or PCS_FIN = "485b" or PCS_FIN = "486A" or PCS_FIN = "486a" or PCS_FIN = "486D" or PCS_FIN = "486d" or PCS_FIN = "486E" or PCS_FIN = "486e" or PCS_FIN = "487A" or PCS_FIN = "487a" or PCS_FIN = "487B" or PCS_FIN = "487b" or PCS_FIN = "488A" or PCS_FIN = "488a" or PCS_FIN = "488B" or PCS_FIN = "488b"
	then PCS_FIN_score = 0;
if PCS_FIN = "542D" or PCS_FIN =  "556B" or PCS_FIN = 
"521A" or PCS_FIN = "521a" or PCS_FIN = "521B" or PCS_FIN = "521b" or PCS_FIN = "522A" or PCS_FIN = "522a" or PCS_FIN = "523A" or PCS_FIN = "523a" or PCS_FIN = "524A" or PCS_FIN = "524a" or PCS_FIN = "525A" or PCS_FIN = "525a" or PCS_FIN = "525B" or PCS_FIN = "525b" or PCS_FIN = "525C" or PCS_FIN = "525c" or PCS_FIN = "525D" or PCS_FIN = "525d" or PCS_FIN = "526A" or PCS_FIN = "526a" or PCS_FIN = "526B" or PCS_FIN = "526b" or PCS_FIN = "526C" or PCS_FIN = "526c" or PCS_FIN = "526D" or PCS_FIN = "526d" or PCS_FIN = "526E" or PCS_FIN = "526e" or PCS_FIN = "531A" or PCS_FIN = "531a" or PCS_FIN = "531B" or PCS_FIN = "531b" or PCS_FIN = "531C" or PCS_FIN = "531c" or PCS_FIN = "532A" or PCS_FIN = "532a" or PCS_FIN = "532B" or PCS_FIN = "532b" or PCS_FIN = "532C" or PCS_FIN = "533A" or PCS_FIN = "533a" or PCS_FIN = "533B" or PCS_FIN = "533b" or PCS_FIN = "533C" or PCS_FIN = "533c" or PCS_FIN = "534A" or PCS_FIN = "534a" or PCS_FIN = "534B" or PCS_FIN = "534b" or PCS_FIN = "541A" or PCS_FIN = "541a" or PCS_FIN = "541D" or PCS_FIN = "541d" or PCS_FIN = "542A" or PCS_FIN = "542" or PCS_FIN = "542B" or PCS_FIN = "542b" or PCS_FIN = "543A" or PCS_FIN = "543a" or PCS_FIN = "543D" or PCS_FIN = "543d" or PCS_FIN = "543B" or PCS_FIN =  "543b" or PCS_FIN = "543C" or PCS_FIN =  "543c" or PCS_FIN = "543E" or PCS_FIN =  "543e" or PCS_FIN = "543F" or PCS_FIN =  "543f" or PCS_FIN = "543G" or PCS_FIN =  "543g" or PCS_FIN = "543H" or PCS_FIN =  "543h" or PCS_FIN = 
"523B" or PCS_FIN =  "523b" or PCS_FIN = "523C" or PCS_FIN =  "523c" or PCS_FIN = "523D" or PCS_FIN =  "523d" or PCS_FIN = "524B" or PCS_FIN =  "524b" or PCS_FIN = "524C" or PCS_FIN =  "524c" or PCS_FIN = "524D" or PCS_FIN =  "524d" or PCS_FIN = "541B" or PCS_FIN =  "541b" or PCS_FIN = "541C" or PCS_FIN =  "541c" or PCS_FIN = "544A" or PCS_FIN = "544a" or PCS_FIN = "545A" or PCS_FIN = "545a" or PCS_FIN = "545B" or PCS_FIN = "545b" or PCS_FIN = "545C" or PCS_FIN = "545c" or PCS_FIN = "545D" or PCS_FIN = "545d" or PCS_FIN = "546A" or PCS_FIN = "546a" or PCS_FIN = "546B" or PCS_FIN = "546b" or PCS_FIN = "546C" or PCS_FIN = "546c" or PCS_FIN = "546D" or PCS_FIN = "546d" or PCS_FIN = "546E" or PCS_FIN = "546e" or PCS_FIN = "551A" or PCS_FIN = "551a" or PCS_FIN = "552A" or PCS_FIN = "552a" or PCS_FIN = "553A" or PCS_FIN = "553a" or PCS_FIN = "553B" or PCS_FIN =  "553b" or PCS_FIN = "553C" or PCS_FIN =  "553c" or PCS_FIN = "554A" or PCS_FIN = "554a" or PCS_FIN = "554B" or PCS_FIN = "554b" or PCS_FIN = "554C" or PCS_FIN = "554c" or PCS_FIN = "554D" or PCS_FIN = "554d" or PCS_FIN = "554E" or PCS_FIN = "554e" or PCS_FIN = "554F" or PCS_FIN = "554f" or PCS_FIN = "554G" or PCS_FIN = "554g" or PCS_FIN = "554H" or PCS_FIN = "554h" or PCS_FIN = "554J" or PCS_FIN = "554j" or PCS_FIN = "555A" or PCS_FIN = "555a" or PCS_FIN = "556A" or PCS_FIN = "556a" or PCS_FIN = "561A" or PCS_FIN = "561a" or PCS_FIN = "561B" or PCS_FIN =  "561b" or PCS_FIN = "561C" or PCS_FIN =  "561c" or PCS_FIN = "561D" or PCS_FIN = "561d" or PCS_FIN = "561E" or PCS_FIN = "561e" or PCS_FIN = "561F" or PCS_FIN = "561f" or PCS_FIN = "562A" or PCS_FIN = "562a" or PCS_FIN = "562B" or PCS_FIN = "562b" or PCS_FIN = "563A" or PCS_FIN = "563a" or PCS_FIN = "563B" or PCS_FIN = "563b" or PCS_FIN = "563C" or PCS_FIN = "564A" or PCS_FIN = "564a" or PCS_FIN = "564B" or PCS_FIN = "564b"
	then PCS_FIN_score = -10;
if PCS_FIN = "621A" or PCS_FIN = "621a" or PCS_FIN = "621B" or PCS_FIN = "621b" or PCS_FIN = "621C" or PCS_FIN = "621c" or PCS_FIN = "621D" or PCS_FIN = "621d" or PCS_FIN = "621E" or PCS_FIN = "621e" or PCS_FIN = "621F" or PCS_FIN = "621f" or PCS_FIN = "621G" or PCS_FIN = "621g" or PCS_FIN = "622A" or PCS_FIN = "622a" or PCS_FIN = "622B" or PCS_FIN = "622b" or PCS_FIN = "622G" or PCS_FIN = "622g" or PCS_FIN = "622C" or PCS_FIN =  "622c" or PCS_FIN = "622D" or PCS_FIN =  "622d" or PCS_FIN = "622E" or PCS_FIN =  "622e" or PCS_FIN = "622F" or PCS_FIN =  "622f" or PCS_FIN = "623A" or PCS_FIN = "623a" or PCS_FIN = "623B" or PCS_FIN = "623b" or PCS_FIN = "623C" or PCS_FIN = "623c" or PCS_FIN = "623F" or PCS_FIN = "623f" or PCS_FIN = "623G" or PCS_FIN = "623g" or PCS_FIN = "623D" or PCS_FIN =  "623d" or PCS_FIN = "623E" or PCS_FIN =  "623e" or PCS_FIN = "624A" or PCS_FIN = "624a" or PCS_FIN = "624B" or PCS_FIN =  "624b" or PCS_FIN = "624C" or PCS_FIN =  "624c" or PCS_FIN = "624D" or PCS_FIN = "624d" or PCS_FIN = "624E" or PCS_FIN = "624e" or PCS_FIN = "624F" or PCS_FIN = "624f" or PCS_FIN = "624G" or PCS_FIN = "624g" or PCS_FIN = "625A" or PCS_FIN = "625a" or PCS_FIN = "625B" or PCS_FIN = "625b" or PCS_FIN = "625C" or PCS_FIN = "625c" or PCS_FIN = "625D" or PCS_FIN = "625d" or PCS_FIN = "625E" or PCS_FIN = "625e" or PCS_FIN = "625H" or PCS_FIN = "625h" or PCS_FIN = "625F" or PCS_FIN =  "625f" or PCS_FIN = "625G" or PCS_FIN =  "625g" or PCS_FIN = "626A" or PCS_FIN = "626a" or PCS_FIN = "626B" or PCS_FIN = "626b" or PCS_FIN = "626C" or PCS_FIN = "626c" or PCS_FIN = "627A" or PCS_FIN = "627a" or PCS_FIN = "627B" or PCS_FIN = 
"627b" or PCS_FIN = "627C" or PCS_FIN = "627c" or PCS_FIN = "627D" or PCS_FIN = "627d" or PCS_FIN = "627E" or PCS_FIN = "627e" or PCS_FIN = "627F" or PCS_FIN = "627f" or PCS_FIN = "628A" or PCS_FIN = "628a" or PCS_FIN = "628B" or PCS_FIN = "628b" or PCS_FIN = "628C" or PCS_FIN = "628c" or PCS_FIN = "628D" or PCS_FIN = "628d" or PCS_FIN = "628E" or PCS_FIN = "628e" or PCS_FIN = "628F" or PCS_FIN = "628f" or PCS_FIN = "628G" or PCS_FIN = "628g" or PCS_FIN = "631A" or PCS_FIN = "631a" or PCS_FIN = "632A" or PCS_FIN = "632a" or PCS_FIN = "632B" or PCS_FIN = "632b" or PCS_FIN = "632C" or PCS_FIN = "632c" or PCS_FIN = "632D" or PCS_FIN = "632d" or PCS_FIN = "632E" or PCS_FIN = "632e" or PCS_FIN = "632F" or PCS_FIN = "632f" or PCS_FIN = "632G" or PCS_FIN = "632g" or PCS_FIN = "632H" or PCS_FIN = "632h" or PCS_FIN = "632J" or PCS_FIN = "632j" or PCS_FIN = "632K" or PCS_FIN = "632k" or PCS_FIN = "633A" or PCS_FIN = "633a" or PCS_FIN = "633B" or PCS_FIN = "633b" or PCS_FIN = "633C" or PCS_FIN = "633c" or PCS_FIN = "633D" or PCS_FIN = "633d" or PCS_FIN = "634A" or PCS_FIN = "634a" or PCS_FIN = "634B" or PCS_FIN = "634b" or PCS_FIN = "634C" or PCS_FIN = "634c" or PCS_FIN = "634D" or PCS_FIN = "634d" or PCS_FIN = 
"635A" or PCS_FIN = "635a" or PCS_FIN = "636A" or PCS_FIN = "636a" or PCS_FIN = "636B" or PCS_FIN = "636b" or PCS_FIN = "636C" or PCS_FIN = "636c" or PCS_FIN = "636D" or PCS_FIN = "636d" or PCS_FIN = "637A" or PCS_FIN = "637a" or PCS_FIN = "637B" or PCS_FIN = "637b" or PCS_FIN = "637C" or PCS_FIN = "637c" or PCS_FIN = "637D" or PCS_FIN = "637d" or PCS_FIN = "641A" or PCS_FIN = "641a" or PCS_FIN = "641B" or PCS_FIN = "641b" or PCS_FIN = "642A" or PCS_FIN = "642a" or PCS_FIN = "642B" or PCS_FIN = "642b" or PCS_FIN = "643A" or PCS_FIN = "643a" or PCS_FIN = "644A" or PCS_FIN = "644a" or PCS_FIN = "651A" or PCS_FIN = "651a" or PCS_FIN = "651B" or PCS_FIN = "651b" or PCS_FIN = "652A" or PCS_FIN = "652a" or PCS_FIN = "652B" or PCS_FIN = "652b" or PCS_FIN = "653A" or PCS_FIN = "653a" or PCS_FIN = "654A" or PCS_FIN = "654a" or PCS_FIN = "654B" or PCS_FIN =  "654b" or PCS_FIN = "654C" or PCS_FIN =  "654c" or PCS_FIN = "655A" or PCS_FIN = "655a" or PCS_FIN = "656A" or PCS_FIN = "656a" or PCS_FIN = "656B" or PCS_FIN =  "656b" or PCS_FIN = "656C" or PCS_FIN =  "656c" or PCS_FIN = "671A" or PCS_FIN = "671a" or PCS_FIN = "671B" or PCS_FIN = "671b" or PCS_FIN = "671C" or PCS_FIN =  "671c" or PCS_FIN = "671D" or PCS_FIN =  "671d" or PCS_FIN = "672A" or PCS_FIN = "672a" or PCS_FIN = "673A" or PCS_FIN = "673a" or PCS_FIN = "673B" or PCS_FIN = "673b" or PCS_FIN = "673C" or PCS_FIN = "673c" or PCS_FIN = "674A" or PCS_FIN = "674a" or PCS_FIN = "674B" or PCS_FIN = 
"674b" or PCS_FIN = "674C" or PCS_FIN = "674c" or PCS_FIN = "674D" or PCS_FIN = "674d" or PCS_FIN = "674E" or PCS_FIN = "674e" or PCS_FIN = "675A" or PCS_FIN = "675a" or PCS_FIN = "675B" or PCS_FIN = "675b" or PCS_FIN = "675C" or PCS_FIN = "675c" or PCS_FIN = "676A" or PCS_FIN = "676a" or PCS_FIN = "676B" or PCS_FIN = "676b" or PCS_FIN = "676C" or PCS_FIN = "676c" or PCS_FIN = "676D" or PCS_FIN = "676d" or PCS_FIN = "676E" or PCS_FIN = "676e" or PCS_FIN = "681A" or PCS_FIN = "681a" or PCS_FIN = "681B" or PCS_FIN = "681b" or PCS_FIN = "682A" or PCS_FIN = "682a" or PCS_FIN = "683A" or PCS_FIN = "683a" or PCS_FIN = "684A" or PCS_FIN = "684a" or PCS_FIN = "684B" or PCS_FIN = "684b" or PCS_FIN = "685A" or PCS_FIN = "685a" or PCS_FIN = "691A" or PCS_FIN = "691a" or PCS_FIN = "691B" or PCS_FIN = "691b" or PCS_FIN = "691C" or PCS_FIN = "691c" or PCS_FIN = "691D" or PCS_FIN = "691d" or PCS_FIN = "691E" or PCS_FIN = "691e" or PCS_FIN = "691F" or PCS_FIN = "691f" or PCS_FIN = "692A" or PCS_FIN = "692a"
then PCS_FIN_score = -7;

if STAT_FIN = "01" then STAT_FIN_score = -11;		/*FREELANCE*/
if STAT_FIN = "03" then STAT_FIN_score = 6;		/*FONCTIONNAIRE*/
if STAT_FIN = "04" then STAT_FIN_score = 4;		/*CDI*/
if STAT_FIN = "05" then STAT_FIN_score = -9;		/*CDD*/
if STAT_FIN = "07" then STAT_FIN_score = -10;		/*Intérim*/
if STAT_FIN = "02" or STAT_FIN = "06" or STAT_FIN = "08" or STAT_FIN = "10" or STAT_FIN = "11" or STAT_FIN = "12" or STAT_FIN = "13" 
or STAT_FIN = "14" or STAT_FIN = "16" or STAT_FIN = "18" or STAT_FIN = "20" or STAT_FIN = "21" or STAT_FIN = "22" or STAT_FIN = "23" or STAT_FIN = "24" 
or STAT_FIN = "25" or STAT_FIN = "9" then STAT_FIN_score = -11;		/*Autre*/

if EP49 = "1" then EP49_score = 2;
if EP49 = "2" then EP49_score = -12;
else EP49_score = 2;

if EP70 = "1" then EP70_score = -2;	
if EP70 = "2" then EP70_score = 7;		
if EP70 = "3" then EP70_score = 7;
if EP70 = "4" then EP70_score = 7;
else EP70_score = -2;

if SALPRFIN > 0 AND SALPRFIN <= 1200 then SALPRFIN_score = -12;		
else if SALPRFIN > 1200 AND SALPRFIN <= 1500 then SALPRFIN_score = 0;	
else if SALPRFIN > 1500 AND SALPRFIN <= 1900 then SALPRFIN_score = 5;
else if SALPRFIN > 1900 then SALPRFIN_score = 9;

else if SALPRDEB >0 AND SALPRFIN < 1200 then SALPRFIN_score = -12;	

if PART_EMP > 0 AND PART_EMP <= 0.5 then PART_EMP_score = -13;		
else if PART_EMP > 0.5 AND PART_EMP <= 0.75 then PART_EMP_score = -6;	
else if PART_EMP > 0.75 AND PART_EMP <= 0.95 then PART_EMP_score = 1;
else if PART_EMP > 0.95 then PART_EMP_score = 5;

SCORE_FINAL = OP2_score + PCS_FIN_score + STAT_FIN_score + EP49_score + EP70_score + SALPRFIN_score + PART_EMP_score;

if PART_EMP = 0 then SCORE_FINAL = -1000;
RUN;

PROC FREQ DATA=TER.score;
TABLES SCORE_FINAL;
RUN;

PROC SGPLOT DATA=TER.score;
where SCORE_FINAL>-100;
HBOX SCORE_FINAL;
RUN;
PROC MEANS DATA=TER.score n mean median std min max 	MAXDEC=2;
where SCORE_FINAL>-100;
VAR SCORE_FINAL;
RUN;

PROC UNIVARIATE DATA=TER.score;
where SCORE_FINAL>-100;
VAR SCORE_FINAL;
WEIGHT PONDEF;
RUN;

PROC FREQ DATA=TER.score;
TABLES SCORE_FINAL;
FORMAT SCORE_FINAL SCORE_fs.;
WEIGHT PONDEF;
RUN;


ods pdf file="C:\Users\Lokman\Desktop\TER\ANNEXE 3 Croisements entre le score de réussite et les variables explicatives.pdf" style=report_pdf;


/*croisement*/

PROC FREQ DATA=TER.score;
TABLES SCORE_FINAL*Q1 / expected chisq deviation cellchi2; 	/*sexe*/
FORMAT SCORE_FINAL SCORE_FS. Q1 $Q1_FS.;
WEIGHT PONDEF;
RUN;

PROC FREQ DATA=TER.score;
TABLES SCORE_FINAL*PHDIP / expected chisq deviation cellchi2; 	/*diplome*/
FORMAT SCORE_FINAL SCORE_FS. PHDIP $PHDIP_FS.;
WEIGHT PONDEF;
RUN;

PROC FREQ DATA=TER.score;
TABLES SCORE_FINAL*LIEUNPER / expected chisq deviation cellchi2; 	/*région naissance du père*/
FORMAT SCORE_FINAL SCORE_FS. LIEUNPER $LIEUNPER_FS.;
WEIGHT PONDEF;
RUN;

PROC FREQ DATA=TER.score;
TABLES SCORE_FINAL*Q35NEW / expected chisq deviation cellchi2; 	/*type de bac*/
FORMAT SCORE_FINAL SCORE_FS. Q35NEW $Q35NEW_FS.;
WEIGHT PONDEF;
RUN;

PROC FREQ DATA=TER.score;
TABLES SCORE_FINAL*q36 / expected chisq deviation cellchi2; 	/*série de bac*/
FORMAT SCORE_FINAL SCORE_FS. q36 $q36_fs.;
WEIGHT PONDEF;
RUN;

/************************A FAIRE POUR DEMAIN****************/

PROC FREQ DATA=TER.score;
TABLES SCORE_FINAL*q38e / expected chisq deviation cellchi2; 	/*connaissance métier souhaité*/
FORMAT SCORE_FINAL SCORE_FS. q38e $ouiNONnsp.;
WEIGHT PONDEF;
RUN;

PROC FREQ DATA=TER.score;
TABLES SCORE_FINAL*ERA1 / expected chisq deviation cellchi2; 	/*participation à Erasmus*/
FORMAT SCORE_FINAL SCORE_FS. ERA1 $ERA1_fs.;
WEIGHT PONDEF;
RUN;


ods pdf close
