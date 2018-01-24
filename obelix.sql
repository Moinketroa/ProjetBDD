/* creation database link vers panoramix */
CREATE PUBLIC DATABASE LINK panoramix.projet using 'panoramix';

/* creation tablespace */
CREATE TABLESPACE tablespace_users DATAFILE 'tablespace_users.dbf' size 50M ONLINE;

/*---------------------------------------------*/
/* CREATION DE ROLES ET DOTATION DE PRIVILEGES */
/*---------------------------------------------*/

/* creation du role proprietaire pour representer obelix et panoramix */
/* le role est dupliqué sur la bdd panoramix */
CREATE ROLE proprietaire;
/* dotation des droits pour le role proprietaire */
GRANT CREATE TABLE TO proprietaire;
GRANT CREATE USER TO proprietaire;
GRANT CREATE VIEW TO proprietaire;
GRANT CREATE MATERIALIZED VIEW TO proprietaire;
GRANT CREATE TRIGGER TO proprietaire;
GRANT CREATE DATABASE LINK TO proprietaire;
GRANT CREATE PUBLIC SYNONYM TO proprietaire;
/* dotation des droits de connection pour faciliter le changement de role */
GRANT CONNECT TO proprietaire;

/* creation du role amisCommuns qui pourra avoir accès à toutes les informations sur les BDD */
/* le role est dupliqué sur la bdd panoramix */
CREATE ROLE amisCommuns;
/* dotation des droits de connection pour faciliter le changement de role */
GRANT CONNECT TO amisCommuns;

/* creation du role amisObelix qui pourra avoir seulement accès aux informations disponible sur la BDD obelix */
CREATE ROLE amisObelix;
/* dotation des droits de connection pour faciliter le changement de role */
GRANT CONNECT TO amisObelix;

/* creation du role romains qui ne pourra rien voir */
/* le role est dupliqué sur la bdd panoramix */
CREATE ROLE romains;
/* dotation des droits de connection pour faciliter le changement de role */
GRANT CONNECT TO romains;

/*---------------------------*/
/* CREATION DES UTILISATEURS */
/*---------------------------*/

/* Creation d'obelix et panoramix en tant que proprietaire */
/* obelix et panoramix sont dupliques sur la bdd panoramix */
CREATE USER obelix IDENTIFIED BY obelix DEFAULT TABLESPACE tablespace_users QUOTA 10M ON tablespace_users;
CREATE USER panoramix IDENTIFIED BY panoramix DEFAULT TABLESPACE tablespace_users QUOTA 10M ON tablespace_users;
GRANT proprietaire TO obelix;
GRANT proprietaire TO panoramix;

/* Creation d'asterix en tant qu'amisCommuns */
/* asterix est dupliques sur la bdd panoramix */
CREATE USER asterix IDENTIFIED BY asterix DEFAULT TABLESPACE tablespace_users QUOTA 10M ON tablespace_users;
GRANT amisCommuns TO asterix;

/* Creation de falbala en tant qu'amisObelix */
CREATE USER falbala IDENTIFIED BY falbala DEFAULT TABLESPACE tablespace_users QUOTA 10M ON tablespace_users;
GRANT amisObelix TO falbala;

/* Creation d'un romain en tant que romains */
CREATE USER escuelleplus IDENTIFIED BY escuelleplus DEFAULT TABLESPACE tablespace_users QUOTA 10M ON tablespace_users;
GRANT romains TO escuelleplus;

/*-----------------------*/
/* ETAPE 1 : REPLICATION */
/*-----------------------*/

/* creation de vues materialisees pour dupliquer les donnees disponibles chez panoramix */
CREATE MATERIALIZED VIEW etape1_village_vue_mat REFRESH FAST WITH PRIMARY KEY ON COMMIT
AS
SELECT * FROM etape1_village@panoramix;
GRANT SELECT ON etape1_village_vue_mat TO proprietaire, amisCommuns, amisObelix;

CREATE MATERIALIZED VIEW etape1_gaulois_vue_mat REFRESH FAST WITH PRIMARY KEY ON COMMIT
AS
SELECT * FROM etape1_gaulois@panoramix;
GRANT SELECT ON etape1_gaulois_vue_mat TO proprietaire, amisCommuns, amisObelix;

/*-------------------------------------*/
/* ETAPE 2 : FRAGMENTATION HORIZONTALE */
/*-------------------------------------*/

/* creation de la table village, la meme que chez panoramix */
CREATE TABLE etape2_village (
    id INT PRIMARY KEY NOT NULL,
    nom VARCHAR(20) NOT NULL,
    specialite VARCHAR(20) NOT NULL,
    region VARCHAR(20) NOT NULL
);
GRANT SELECT, INSERT, DELETE ON etape2_village TO proprietaire, amisCommuns, amisObelix;

/* creation de la table gaulois, la meme que chez panoramix */
CREATE TABLE etape2_gaulois (
    id INT PRIMARY KEY NOT NULL,
    nom VARCHAR(20) NOT NULL,
    profession VARCHAR(20) NOT NULL,
    village INT NOT NULL,
    FOREIGN KEY (village) REFERENCES etape2_village(id)
);
GRANT SELECT, INSERT, DELETE ON etape2_gaulois TO proprietaire, amisCommuns, amisObelix;

/* insertion de tuples, panoramix n'aura pas les tubles suivant */
INSERT INTO etape2_village (id,nom,specialite,region) VALUES (1,'Alesia','Elevage','Cumaracum');
INSERT INTO etape2_village (id,nom,specialite,region) VALUES (3,'Gergovie','Ceuillette','Nemessos');

INSERT INTO etape2_gaulois (id,nom,profession,village) VALUES (1,'Trisomix','Artiste',1);
INSERT INTO etape2_gaulois (id,nom,profession,village) VALUES (3,'Aplusbegalix','Mathematicien',3);
INSERT INTO etape2_gaulois (id,nom,profession,village) VALUES (4,'Porquepix','Marchand de vin',3);
INSERT INTO etape2_gaulois (id,nom,profession,village) VALUES (5,'Netflix','Realisateur',1);

/* creation des vues de defragmentation */
/* les vues sont dupliquees chez panoramix */
CREATE VIEW etape2_village_vue
AS
SELECT * FROM etape2_village@obelix UNION
SELECT * FROM etape2_village@panoramix;
GRANT SELECT, INSERT, DELETE ON etape2_village_vue TO proprietaire, amisCommuns;

CREATE VIEW etape2_gaulois_vue
AS
SELECT * FROM etape2_gaulois@obelix UNION
SELECT * FROM etape2_gaulois@panoramix;
GRANT SELECT, INSERT, DELETE ON etape2_gaulois_vue TO proprietaire, amisCommuns;

/* creation des triggers pour l'insertion en fragmentation horizontale */
/* les triggers sont dupliquees chez panoramix */
CREATE OR REPLACE TRIGGER etape2_village_vue_trigger
INSTEAD OF INSERT ON etape2_village_vue
REFERENCING new AS new old AS old
BEGIN
	IF (:new.id % 2) = 0 THEN
		INSERT INTO etape2_village@panoramix (id,nom,specialite,region) VALUES (:new.id, :new.nom, :new.specialite, :new.region);
	ELSE
		INSERT INTO etape2_village@obelix (id,nom,specialite,region) VALUES (:new.id, :new.nom, :new.specialite, :new.region);
	END IF;
END;
/

CREATE OR REPLACE TRIGGER etape2_gaulois_vue_trigger
INSTEAD OF INSERT ON etape2_gaulois_vue
REFERENCING new AS new old AS old
BEGIN
	IF (:new.village % 2) = 0 THEN
		INSERT INTO etape2_gaulois@panoramix (id,nom,profession,village) VALUES (:new.id, :new.nom, :new.profession, :new.village);
	ELSE
		INSERT INTO etape2_gaulois@obelix (id,nom,profession,village) VALUES (:new.id, :new.nom, :new.profession, :new.village);
	END IF;
END;
/

/*---------------------------------*/
/* ETAPE 3 FRAGMENTATION VERTICALE */
/*---------------------------------*/

/* creation de la table village, incomplete */
CREATE TABLE etape3_village (
    id INT PRIMARY KEY NOT NULL,
    specialite VARCHAR(20) NOT NULL,
);
GRANT SELECT ON etape3_village TO proprietaire, amisCommuns, amisObelix;

/* creation de la table gaulois, incomplete */
CREATE TABLE etape3_gaulois (
    id INT PRIMARY KEY NOT NULL,
    profession VARCHAR(20) NOT NULL,
    village INT NOT NULL,
    FOREIGN KEY (village) REFERENCES etape3_village(id)
);
GRANT SELECT ON etape3_gaulois TO proprietaire, amisCommuns, amisObelix;

/* insertion de tuples */
INSERT INTO etape3_village (id,specialite) VALUES (1,'Elevage');
INSERT INTO etape3_village (id,specialite) VALUES (2,'Peche');
INSERT INTO etape3_village (id,specialite) VALUES (3,'Ceuillette');

INSERT INTO etape3_gaulois (id,profession,village) VALUES (1,'Artiste',1);
INSERT INTO etape3_gaulois (id,profession,village) VALUES (2,'Meteorologue',2);
INSERT INTO etape3_gaulois (id,profession,village) VALUES (3,'Mathematicien',3);
INSERT INTO etape3_gaulois (id,profession,village) VALUES (4,'Marchand de vin',3);
INSERT INTO etape3_gaulois (id,profession,village) VALUES (5,'Realisateur',1);

/* creation des vues de defragmentation */
/* les vues sont dupliquees chez panoramix */
CREATE VIEW etape3_village_vue 
AS
SELECT villageO.id, villageP.nom, villageO.specialite, villageP.region
FROM etape3_village@obelix AS villageO JOIN etape3_village@panoramix AS villageP
ON villageO.id = villageP.id;
GRANT SELECT, INSERT, DELETE ON etape3_village_vue TO proprietaire, amisCommuns;

CREATE VIEW etape3_gaulois_vue 
AS
SELECT gauloisO.id, gauloisP.nom, gauloisO.profession, gauloisP.village
FROM etape3_gaulois@obelix AS gauloisO JOIN etape3_gaulois@panoramix AS gauloisP
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

/*---------------------------------*/
/* ETAPE 4 FRAGMENTATION DU SCHEMA */
/*---------------------------------*/

/* creation de la table gaulois, presente uniquement chez obelix */
CREATE TABLE etape4_gaulois (
    id INT PRIMARY KEY NOT NULL,
    nom VARCHAR(20) NOT NULL,
    profession VARCHAR(20) NOT NULL,
    village INT NOT NULL,
    FOREIGN KEY (village) REFERENCES etape4_village@panoramix(id)
);
GRANT SELECT ON etape4_gaulois TO proprietaire, amisCommuns, amisObelix;

