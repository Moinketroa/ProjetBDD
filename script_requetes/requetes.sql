/*---------*/
/* ETAPE 1 */
/*---------*/

/* Sur Panoramix */
/*- Requete de localisation des gaulois sur panoramix -*/
/*-- ROLE : PROPRIETAIRE --*/
CONNECT obelix/obelix;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois g, system.etape1_village v WHERE g.village=v.id;

/*-- ROLE : AMISCOMMUNS --*/
CONNECT asterix/asterix;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois g, system.etape1_village v WHERE g.village=v.id;

/*-- ROLE : AMISPANORAMIX --*/
CONNECT informatix/informatix;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois g, system.etape1_village v WHERE g.village=v.id;

/*-- ROLE : ROMAINS --*/
CONNECT escuelleplus/escuelleplus;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois g, system.etape1_village v WHERE g.village=v.id;

/* Sur Obelix */
/*- Requete de localisation des gaulois sur panoramix -*/
/*-- ROLE : PROPRIETAIRE --*/
CONNECT panoramix/panoramix;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois@panoramix g, system.etape1_village@panoramix v WHERE g.village=v.id;

/*-- ROLE : AMISCOMMUNS --*/
CONNECT asterix/asterix;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois@panoramix g, system.etape1_village@panoramix v WHERE g.village=v.id;

/*-- ROLE : AMISOBELIX --*/
CONNECT falbala/falbala;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois@panoramix g, system.etape1_village@panoramix v WHERE g.village=v.id;

/*-- ROLE : ROMAINS --*/
CONNECT escuelleplus/escuelleplus;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois@panoramix g, system.etape1_village@panoramix v WHERE g.village=v.id;

/*- Requete de localisation des gaulois sur la vue materialisee sur obelix -*/
/*-- ROLE : AMISOBELIX --*/
CONNECT falbala/falbala;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois_vue_mat g, system.etape1_village_vue_mat v WHERE g.village=v.id;

/*-- ROLE : ROMAINS --*/
CONNECT escuelleplus/escuelleplus;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois_vue_mat g, system.etape1_village_vue_mat v WHERE g.village=v.id;

/*---------*/
/* ETAPE 2 */
/*---------*/

/* DEPUIS PANORAMIX */
/* Tables locales frangmentees */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois g, system.etape2_village v WHERE g.village=v.id;

/* Select sur la vue de defragmentation */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois_vue g, system.etape2_village_vue v WHERE g.village=v.id;

/* insertion d'un village avec un id impair qui sera cree sur la base obelix */
INSERT INTO system.etape2_village_vue (id,nom,specialite,region) VALUES (55,'Rome','Politique','Italie');

/* insertion d'un gaulois avec lie a rome qui sera cree sur la base obelix */
INSERT INTO system.etape2_gaulois_vue (id,nom,profession,village) VALUES (1664,'Reveilleaheurefix','Marchand de cervoise',55);

/* visualisation des changements */
/* local */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois g, system.etape2_village v WHERE g.village=v.id;
/* vue */
/* Select sur la vue de defragmentation */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois_vue g, system.etape2_village_vue v WHERE g.village=v.id;

/* DEPUIS OBELIX */
/* Tables locales frangmentees */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois g, system.etape2_village v WHERE g.village=v.id;

/* Select sur la vue de defragmentation */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois_vue g, system.etape2_village_vue v WHERE g.village=v.id;

/* insertion d'un village avec un id pair qui sera cree sur la base panoramix */
INSERT INTO system.etape2_village_vue (id,nom,specialite,region) VALUES (42,'Divodurum','Menuiserie','Lorraine');

/* insertion d'un gaulois avec lie a divodurum qui sera cree sur la base panoramix */
INSERT INTO system.etape2_gaulois_vue (id,nom,profession,village) VALUES (1664,'Inezemix','Barde',42);

/* visualisation des changements */
/* local */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois g, system.etape2_village v WHERE g.village=v.id;

SELECT g.nom, g.profession, v.id id_village, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois g, system.etape2_village v WHERE g.village=v.id;
/* vue */
/* Select sur la vue de defragmentation */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois_vue g, system.etape2_village_vue v WHERE g.village=v.id;

/*---------*/
/* ETAPE 3 */
/*---------*/

/* visualisation des tables locales */
SELECT * FROM system.etape3_village;
SELECT * FROM system.etape3_gaulois;

/* Select sur la vue de defragmentation */
SELECT * FROM system.etape3_village_vue;
SELECT * FROM system.etape3_gaulois_vue;

/* insertion d'un village qui sera fragmente entre les 2 bases */
INSERT INTO system.etape3_village_vue (id,nom,specialite,region) VALUES (55,'Rome','Politique','Italie');

/* insertion d'un gaulois avec lie a rome qui sera fragmente entre les 2 bases */
INSERT INTO system.etape3_gaulois_vue (id,nom,profession,village) VALUES (1664,'Reveilleaheurefix','Marchand de cervoise',55);

/* visualisation des changements */
/* local */
SELECT * FROM system.etape3_village;
SELECT * FROM system.etape3_gaulois;

/* vue */
SELECT * FROM system.etape3_village_vue;
SELECT * FROM system.etape3_gaulois_vue;

/* affichage de la localisation de tout les gaulois */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape3_gaulois_vue g, system.etape3_village_vue v WHERE g.village=v.id;

/* supression d'un gaulois */
DELETE FROM system.etape3_gaulois_vue WHERE id = 1664;

/* visualisation des changements */
/* local */
SELECT * FROM system.etape3_gaulois;

/* vue */
SELECT * FROM system.etape3_gaulois_vue;

/* Transaction qui echoue */
BEGIN
	SAVEPOINT beginning;
	INSERT INTO system.etape3_village_vue (id,nom,specialite,region) VALUES (4200,'Gegobrivate','Cervoise','Bretagne');
	COMMIT;
	INSERT INTO system.etape3_village_vue (id,nom,specialite,region) VALUES (4200,'Gegobrivate','Cervoise','Bretagne');
	COMMIT;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		ROLLBACK TO SAVEPOINT beginning;
		DBMS_OUTPUT.PUT_LINE('Insert has been rooled back to \'beginning\'');
END;
/


/*---------*/
/* ETAPE 4 */
/*---------*/

/* Visualisation du schema */
SELECT * FROM system.etape4_gaulois@obelix;
SELECT * FROM system.etape4_village@panoramix;

/* Localisation des gaulois pour l'etape 4 */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape4_gaulois@obelix g, system.etape4_village@panoramix v WHERE g.village=v.id;

/* deadlock */
/* execute chez obelix */
DECLARE
	gaulois_id INT;
	village_id INT;
BEGIN
	/* blocage sur la table gaulois */
	SELECT id INTO gaulois_id
	FROM system.etape4_gaulois@obelix
	WHERE id = 1
	FOR UPDATE;
 
	/* delay pour permettre le blocage sur la table village depuis panoramix */
	DBMS_LOCK.sleep(30);

	/* tentative d'acces sur la table village bloquee */
	SELECT id INTO village_id
	FROM system.etape4_village@panoramix
	WHERE id = 1
	FOR UPDATE;
END;
/

/* execute chez panoramix */
DECLARE
	gaulois_id INT;
	village_id INT;
BEGIN
	/* blocage sur la table village */
	SELECT id INTO village_id
	FROM system.etape4_village@panoramix
	WHERE id = 1
	FOR UPDATE;
 
	/* delay pour permettre le blocage sur la table village depuis obelix */
	DBMS_LOCK.sleep(30);

	/* tentative d'acces sur la table gaulois bloquee */
	SELECT id INTO gaulois_id
	FROM system.etape4_gaulois@obelix
	WHERE id = 1
	FOR UPDATE;
END;
/