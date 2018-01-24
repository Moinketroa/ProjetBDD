/*--*/
ALTER SESSION SET "_ORACLE_SCRIPT"=true;

/*-----------------------*/
/* ETAPE 1 : REPLICATION */
/*-----------------------*/

/* creation de vues materialisees pour dupliquer les donnees disponibles chez panoramix */
CREATE MATERIALIZED VIEW etape1_village_vue_mat REFRESH FAST WITH PRIMARY KEY ON DEMAND
AS
SELECT * FROM etape1_village@panoramix;
GRANT SELECT ON etape1_village_vue_mat TO proprietaire, amisCommuns, amisObelix;

CREATE MATERIALIZED VIEW etape1_gaulois_vue_mat REFRESH FAST WITH PRIMARY KEY ON DEMAND
AS
SELECT * FROM etape1_gaulois@panoramix;
GRANT SELECT ON etape1_gaulois_vue_mat TO proprietaire, amisCommuns, amisObelix;

/*-------------------------------------*/
/* ETAPE 2 : FRAGMENTATION HORIZONTALE */
/*-------------------------------------*/

/* creation des vues de defragmentation */
/* les vues sont dupliquees chez panoramix */
CREATE VIEW etape2_village_vue
AS
SELECT * FROM system.etape2_village@obelix UNION
SELECT * FROM system.etape2_village@panoramix;
GRANT SELECT, INSERT, DELETE ON etape2_village_vue TO proprietaire, amisCommuns;

CREATE VIEW etape2_gaulois_vue
AS
SELECT * FROM system.etape2_gaulois@obelix UNION
SELECT * FROM system.etape2_gaulois@panoramix;
GRANT SELECT, INSERT, DELETE ON etape2_gaulois_vue TO proprietaire, amisCommuns;

/* creation des triggers pour l'insertion en fragmentation horizontale */
/* les triggers sont dupliquees chez panoramix */
CREATE OR REPLACE TRIGGER etape2_village_vue_trigger
INSTEAD OF INSERT ON etape2_village_vue
REFERENCING new AS new old AS old
BEGIN
	IF mod(:new.id, 2) = 0 THEN
 		INSERT INTO system.etape2_village@panoramix (id,nom,specialite,region) VALUES (:new.id, :new.nom, :new.specialite, :new.region);
	ELSE
		INSERT INTO system.etape2_village@obelix (id,nom,specialite,region) VALUES (:new.id, :new.nom, :new.specialite, :new.region);
	END IF;
END;
/

CREATE OR REPLACE TRIGGER etape2_gaulois_vue_trigger
INSTEAD OF INSERT ON etape2_gaulois_vue
REFERENCING new AS new old AS old
BEGIN
	IF mod(:new.village, 2) = 0 THEN
		INSERT INTO system.etape2_gaulois@panoramix (id,nom,profession,village) VALUES (:new.id, :new.nom, :new.profession, :new.village);
	ELSE
		INSERT INTO system.etape2_gaulois@obelix (id,nom,profession,village) VALUES (:new.id, :new.nom, :new.profession, :new.village);
	END IF;
END;
/

/*---------------------------------*/
/* ETAPE 3 FRAGMENTATION VERTICALE */
/*---------------------------------*/

/* creation des vues de defragmentation */
/* les vues sont dupliquees chez panoramix */
CREATE VIEW etape3_village_vue 
AS
SELECT villageO.id, villageP.nom, villageO.specialite, villageP.region
FROM etape3_village@obelix villageO JOIN etape3_village@panoramix villageP
ON villageO.id = villageP.id;
GRANT SELECT, INSERT, DELETE ON etape3_village_vue TO proprietaire, amisCommuns;

CREATE VIEW etape3_gaulois_vue 
AS
SELECT gauloisO.id, gauloisP.nom, gauloisO.profession, gauloisO.village
FROM etape3_gaulois@obelix gauloisO JOIN etape3_gaulois@panoramix gauloisP
ON gauloisO.id = gauloisP.id;
GRANT SELECT, INSERT, DELETE ON etape3_gaulois_vue TO proprietaire, amisCommuns;

/* creation des triggers pour l'insertion et la deletion en fragmentation verticale */
/* les triggers sont dupliquees chez panoramix */

/* triggers pour l'insertion */
CREATE OR REPLACE TRIGGER etape3_village_vue_trigger_insert
INSTEAD OF INSERT ON etape3_village_vue
REFERENCING new AS new old AS old
BEGIN
	INSERT INTO etape3_village@obelix (id,specialite) VALUES (:new.id, :new.specialite);
	INSERT INTO etape3_village@panoramix (id,nom,region) VALUES (:new.id, :new.nom, :new.region);
END;
/

CREATE OR REPLACE TRIGGER etape3_gaulois_vue_trigger_insert
INSTEAD OF INSERT ON etape3_gaulois_vue
REFERENCING new AS new old AS old
BEGIN
	INSERT INTO etape3_gaulois@obelix (id,profession,village) VALUES (:new.id, :new.profession, :new.village);
	INSERT INTO etape3_gaulois@panoramix (id,nom) VALUES (:new.id, :new.nom);
END;
/

/* triggers pour la deletion */
CREATE OR REPLACE TRIGGER etape3_village_vue_trigger_delete
INSTEAD OF DELETE ON etape3_village_vue
FOR EACH ROW
BEGIN
	DELETE FROM etape3_village@obelix WHERE id = :old.id;
	DELETE FROM etape3_village@panoramix WHERE id = :old.id;
END;
/

CREATE OR REPLACE TRIGGER etape3_gaulois_vue_trigger_delete
INSTEAD OF DELETE ON etape3_gaulois_vue
FOR EACH ROW
BEGIN
	DELETE FROM etape3_gaulois@obelix WHERE id = :old.id;
	DELETE FROM etape3_gaulois@panoramix WHERE id = :old.id;
END;
/

