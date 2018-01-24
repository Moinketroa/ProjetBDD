/*---------*/
/* ETAPE 1 */
/*---------*/

/* Sur Panoramix */
/*- Requete de localisation des gaulois sur panoramix -*/
/*-- ROLE : PROPRIETAIRE --*/
CONNECT obelix/obelix;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois@panoramix g, system.etape1_village@panoramix v WHERE g.village=v.id;

/*-- ROLE : AMISCOMMUNS --*/
CONNECT asterix/asterix;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois@panoramix g, system.etape1_village@panoramix v WHERE g.village=v.id;

/*-- ROLE : AMISPANORAMIX --*/
CONNECT informatix/informatix;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois@panoramix g, system.etape1_village@panoramix v WHERE g.village=v.id;

/*-- ROLE : ROMAINS --*/
CONNECT escuelleplus/escuelleplus;

SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape1_gaulois@panoramix g, system.etape1_village@panoramix v WHERE g.village=v.id;

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
CONNECT panoramix/panoramix;
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
CONNECT obelix/obelix;
/* Tables locales frangmentees */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois@panoramix g, system.etape2_village@panoramix v WHERE g.village=v.id;

/* Select sur la vue de defragmentation */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois_vue@panoramix g, system.etape2_village_vue@panoramix v WHERE g.village=v.id;

/* insertion d'un village avec un id pair qui sera cree sur la base panoramix */
INSERT INTO system.etape2_village_vue (id,nom,specialite,region) VALUES (42,'Divodurum','Menuiserie','Lorraine');

/* insertion d'un gaulois avec lie a divodurum qui sera cree sur la base panoramix */
INSERT INTO system.etape2_gaulois_vue (id,nom,profession,village) VALUES (1664,'Inezemix','Barde',42);

/* visualisation des changements */
/* local */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois@panoramix g, system.etape2_village@panoramix v WHERE g.village=v.id;
/* vue */
/* Select sur la vue de defragmentation */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM system.etape2_gaulois_vue@panoramix g, system.etape2_village_vue@panoramix v WHERE g.village=v.id;

/* ETAPE 3 */
/* Transaction qui echoue */
BEGIN
	SAVEPOINT beginning;
	INSERT INTO etape3_village_vue (id,nom,specialite,region) VALUES (42,'Rome','Politique','Italie');
	COMMIT;
	INSERT INTO etape3_gaulois_vue (id,nom,profession,village) VALUES (1664,'Reveilleaheurefix','Marchand de cervoise',666);
	COMMIT;
EXCEPTION
	ROLLBACK TO beginning;
	DBMS_OUTPUT.PUT_LINE('Insert has been rooled back to \'beginning\'');
END;

/* ETAPE 4 */
/* Localisation des gaulois pour l'etape 4 */
SELECT g.nom, g.profession, v.nom village, v.specialite, v.region 
FROM etape4_gaulois@obelix g, etape4_village@panoramix v WHERE g.village=v.id;

/* deadlock */
/* execute chez obelix */
DECLARE
	gaulois_id INT;
	village_id INT;
BEGIN
	/* blocage sur la table gaulois */
	SELECT id INTO gaulois_id
	FROM etape4_gaulois@obelix
	WHERE id = 1
	FOR UPDATE;
 
	/* delay pour permettre le blocage sur la table village depuis panoramix */
	DBMS_LOCK.sleep(30);

	/* tentative d'acces sur la table village bloquee */
	SELECT id INTO village_id
	FROM   etape4_village@panoramix
	WHERE  id = 1
	FOR UPDATE;
END;

/* execute chez panoramix */
DECLARE
	gaulois_id INT;
	village_id INT;
BEGIN
	/* blocage sur la table village */
	SELECT id INTO village_id
	FROM etape4_village@panoramix
	WHERE id = 1
	FOR UPDATE;
 
	/* delay pour permettre le blocage sur la table village depuis obelix */
	DBMS_LOCK.sleep(30);

	/* tentative d'acces sur la table gaulois bloquee */
	SELECT id INTO gaulois_id
	FROM   etape4_gaulois@obelix
	WHERE  id = 1
	FOR UPDATE;
END;