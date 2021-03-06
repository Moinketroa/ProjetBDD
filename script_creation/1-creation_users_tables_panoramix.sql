/*--*/
ALTER SESSION SET "_ORACLE_SCRIPT"=true;

/* creation database link vers obelix */
CREATE PUBLIC DATABASE LINK obelix.projet using 'obelix';

/* creation tablespace */
CREATE TABLESPACE tablespace_users DATAFILE 'tablespaceusers.dbf' size 50M ONLINE;

/*---------------------------------------------*/
/* CREATION DE ROLES ET DOTATION DE PRIVILEGES */
/*---------------------------------------------*/

/* creation du role proprietaire pour representer obelix et panoramix */
/* le role est dupliqué sur la bdd obelix */
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
/* le role est dupliqué sur la bdd obelix */
CREATE ROLE amisCommuns;
/* dotation des droits de connection pour faciliter le changement de role */
GRANT CONNECT TO amisCommuns;

/* creation du role amisObelix qui pourra avoir seulement accès aux informations disponible sur la BDD obelix */
CREATE ROLE amisPanoramix;
/* dotation des droits de connection pour faciliter le changement de role */
GRANT CONNECT TO amisPanoramix;

/* creation du role romains qui ne pourra rien voir */
/* le role est dupliqué sur la bdd obelix */
CREATE ROLE romains;
/* dotation des droits de connection pour faciliter le changement de role */
GRANT CONNECT TO romains;

GRANT INHERIT REMOTE PRIVILEGES ON proprietaire TO system;
GRANT INHERIT REMOTE PRIVILEGES ON amisCommuns TO system;
GRANT INHERIT REMOTE PRIVILEGES ON amisPanoramix TO system;
GRANT INHERIT REMOTE PRIVILEGES ON romains TO system;

/*---------------------------*/
/* CREATION DES UTILISATEURS */
/*---------------------------*/

/* Creation d'obelix et panoramix en tant que proprietaire */
/* obelix et panoramix sont dupliques sur la bdd obelix */
CREATE USER obelix IDENTIFIED BY obelix DEFAULT TABLESPACE tablespace_users QUOTA 10M ON tablespace_users;
CREATE USER panoramix IDENTIFIED BY panoramix DEFAULT TABLESPACE tablespace_users QUOTA 10M ON tablespace_users;
GRANT proprietaire TO obelix;
GRANT proprietaire TO panoramix;

/* Creation d'asterix en tant qu'amisCommuns */
/* asterix est dupliques sur la bdd obelix */
CREATE USER asterix IDENTIFIED BY asterix DEFAULT TABLESPACE tablespace_users QUOTA 10M ON tablespace_users;
GRANT amisCommuns TO asterix;

/* Creation de informatix en tant qu'amisPanoramix */
CREATE USER informatix IDENTIFIED BY informatix DEFAULT TABLESPACE tablespace_users QUOTA 10M ON tablespace_users;
GRANT amisPanoramix TO informatix;

/* Creation d'un romain en tant que romains */
CREATE USER escuelleplus IDENTIFIED BY escuelleplus DEFAULT TABLESPACE tablespace_users QUOTA 10M ON tablespace_users;
GRANT romains TO escuelleplus;

/*-----------------------*/
/* ETAPE 1 : REPLICATION */
/*-----------------------*/

/* creation des tables village et gaulois presentes uniquement sur panoramix */
CREATE TABLE etape1_village (
    id INT PRIMARY KEY NOT NULL,
    nom VARCHAR(20) NOT NULL,
    specialite VARCHAR(20) NOT NULL,
    region VARCHAR(20) NOT NULL
);
GRANT SELECT, INSERT, DELETE ON etape1_village TO proprietaire, amisCommuns, amisPanoramix;

CREATE TABLE etape1_gaulois (
    id INT PRIMARY KEY NOT NULL,
    nom VARCHAR(20) NOT NULL,
    profession VARCHAR(20) NOT NULL,
    village INT NOT NULL,
    FOREIGN KEY (village) REFERENCES etape1_village(id)
);
GRANT SELECT, INSERT, DELETE ON etape1_gaulois TO proprietaire, amisCommuns, amisPanoramix;

/* insertion de tuples */
INSERT INTO etape1_village (id,nom,specialite,region) VALUES (1,'Alesia','Elevage','Cumaracum');
INSERT INTO etape1_village (id,nom,specialite,region) VALUES (2,'Anichium','Peche','Condate');
INSERT INTO etape1_village (id,nom,specialite,region) VALUES (3,'Gergovie','Cueuille','Nemessos');

INSERT INTO etape1_gaulois (id,nom,profession,village) VALUES (1,'Trisomix','Artiste',1);
INSERT INTO etape1_gaulois (id,nom,profession,village) VALUES (2,'Barometrix','Meteorologue',2);
INSERT INTO etape1_gaulois (id,nom,profession,village) VALUES (3,'Aplusbegalix','Mathematicien',3);
INSERT INTO etape1_gaulois (id,nom,profession,village) VALUES (4,'Porquepix','Marchand de vin',3);
INSERT INTO etape1_gaulois (id,nom,profession,village) VALUES (5,'Netflix','Realisateur',1);

/* creation des logs pour les vues materialisees */
CREATE MATERIALIZED VIEW LOG ON etape1_village WITH PRIMARY KEY;
CREATE MATERIALIZED VIEW LOG ON etape1_gaulois WITH PRIMARY KEY;

/*-------------------------------------*/
/* ETAPE 2 : FRAGMENTATION HORIZONTALE */
/*-------------------------------------*/

/* creation de la table village, la meme que chez obelix */
CREATE TABLE etape2_village (
    id INT PRIMARY KEY NOT NULL,
    nom VARCHAR(20) NOT NULL,
    specialite VARCHAR(20) NOT NULL,
    region VARCHAR(20) NOT NULL
);
GRANT SELECT, INSERT, DELETE ON etape2_village TO proprietaire, amisCommuns, amisPanoramix;

/* creation de la table gaulois, la meme que chez obelix */
CREATE TABLE etape2_gaulois (
    id INT PRIMARY KEY NOT NULL,
    nom VARCHAR(20) NOT NULL,
    profession VARCHAR(20) NOT NULL,
    village INT NOT NULL,
    FOREIGN KEY (village) REFERENCES etape2_village(id)
);
GRANT SELECT, INSERT, DELETE ON etape2_gaulois TO proprietaire, amisCommuns, amisPanoramix;

/* insertion de tuples, obelix n'aura pas les tubles suivant */
INSERT INTO etape2_village (id,nom,specialite,region) VALUES (2,'Anichium','Peche','Condate');

INSERT INTO etape2_gaulois (id,nom,profession,village) VALUES (2,'Barometrix','Meteorologue',2);

/*---- les vues et les triggers seront crees plus tard ----*/

/*---------------------------------*/
/* ETAPE 3 FRAGMENTATION VERTICALE */
/*---------------------------------*/

/* creation de la table village, incomplete */
CREATE TABLE etape3_village (
    id INT PRIMARY KEY NOT NULL,
    nom VARCHAR(20) NOT NULL,
    region VARCHAR(20) NOT NULL
);
GRANT SELECT ON etape3_village TO proprietaire, amisCommuns, amisPanoramix;

/* creation de la table gaulois, incomplete */
CREATE TABLE etape3_gaulois (
    id INT PRIMARY KEY NOT NULL,
    nom VARCHAR(20) NOT NULL
);
GRANT SELECT ON etape3_gaulois TO proprietaire, amisCommuns, amisPanoramix;

/* insertions de tuples */
INSERT INTO etape3_village (id,nom,region) VALUES (1,'Alesia','Cumaracum');
INSERT INTO etape3_village (id,nom,region) VALUES (2,'Anichium','Condate');
INSERT INTO etape3_village (id,nom,region) VALUES (3,'Gergovie','Nemessos');

INSERT INTO etape3_gaulois (id,nom) VALUES (1,'Trisomix');
INSERT INTO etape3_gaulois (id,nom) VALUES (2,'Barometrix');
INSERT INTO etape3_gaulois (id,nom) VALUES (3,'Aplusbegalix');
INSERT INTO etape3_gaulois (id,nom) VALUES (4,'Porquepix');
INSERT INTO etape3_gaulois (id,nom) VALUES (5,'Netflix');

/*---------------------------------*/
/* ETAPE 4 FRAGMENTATION DU SCHEMA */
/*---------------------------------*/

/* creation de la table village, presente uniquement chez panoramix */
CREATE TABLE etape4_village (
    id INT PRIMARY KEY NOT NULL,
    nom VARCHAR(20) NOT NULL,
    specialite VARCHAR(20) NOT NULL,
    region VARCHAR(20) NOT NULL
);
GRANT SELECT, INSERT ON etape4_village TO proprietaire, amisCommuns, amisPanoramix;

/* insertion de tuples */
INSERT INTO etape4_village (id,nom,specialite,region) VALUES (1,'Alesia','Elevage','Cumaracum');
INSERT INTO etape4_village (id,nom,specialite,region) VALUES (2,'Anichium','Peche','Condate');
INSERT INTO etape4_village (id,nom,specialite,region) VALUES (3,'Gergovie','Cueuille','Nemessos');

/* creation d'un vue et d'un trigger pour emuler la cle etrangere lors de la suppression */
CREATE VIEW etape4_village_vue
AS
SELECT * FROM system.etape4_village;
GRANT SELECT, INSERT, DELETE ON etape4_village_vue TO proprietaire, amisCommuns, amisPanoramix;

/* trigger sur la suppression */
CREATE OR REPLACE TRIGGER etape4_village_vue_trigger_delete
INSTEAD OF DELETE ON etape4_village_vue
FOR EACH ROW
DECLARE
	gaulois_village INT;
BEGIN
	SELECT village INTO gaulois_village
	FROM system.etape4_gaulois@obelix
	WHERE village = :old.id;
	
	IF gaulois_village IS NOT NULL THEN
		raise_application_error (-20001, 'le village ne peut pas etre supprime, il depend d un ou plusieurs gaulois');
	ELSE
		DELETE FROM system.etape4_village WHERE id = :old.id;
	END IF;
END;
/