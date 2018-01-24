/*--*/
ALTER SESSION SET "_ORACLE_SCRIPT"=true;

/* creation database link vers panoramix */
CREATE PUBLIC DATABASE LINK panoramix.projet using 'panoramix';

/* creation tablespace */
CREATE TABLESPACE tablespace_users DATAFILE 'tablespace__users.dbf' size 50M ONLINE;

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

GRANT INHERIT REMOTE PRIVILEGES ON proprietaire TO system;
GRANT INHERIT REMOTE PRIVILEGES ON amisCommuns TO system;
GRANT INHERIT REMOTE PRIVILEGES ON amisObelix TO system;
GRANT INHERIT REMOTE PRIVILEGES ON romains TO system;

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

/*---- les vues seront crees plus tard ----*/

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

/*---- les vues et les triggers seront crees plus tard ----*/

/*---------------------------------*/
/* ETAPE 3 FRAGMENTATION VERTICALE */
/*---------------------------------*/

/* creation de la table village, incomplete */
CREATE TABLE etape3_village (
    id INT PRIMARY KEY NOT NULL,
    specialite VARCHAR(20) NOT NULL
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

/*---- les vues et les triggers seront crees plus tard ----*/

/*---------------------------------*/
/* ETAPE 4 FRAGMENTATION DU SCHEMA */
/*---------------------------------*/

/*---- assurez vous de bien avoir execute l'etape 1 de la creation chez panoramix ----*/
/* creation de la table gaulois, presente uniquement chez obelix */
CREATE TABLE etape4_gaulois (
    id INT PRIMARY KEY NOT NULL,
    nom VARCHAR(20) NOT NULL,
    profession VARCHAR(20) NOT NULL,
    village INT NOT NULL
);
GRANT SELECT, DELETE ON etape4_gaulois TO proprietaire, amisCommuns, amisObelix;

/* insertion de tuples */
INSERT INTO etape4_gaulois (id,nom,profession,village) VALUES (1,'Trisomix','Artiste',1);
INSERT INTO etape4_gaulois (id,nom,profession,village) VALUES (2,'Barometrix','Meteorologue',2);
INSERT INTO etape4_gaulois (id,nom,profession,village) VALUES (3,'Aplusbegalix','Mathematicien',3);
INSERT INTO etape4_gaulois (id,nom,profession,village) VALUES (4,'Porquepix','Marchand de vin',3);
INSERT INTO etape4_gaulois (id,nom,profession,village) VALUES (5,'Netflix','Realisateur',1);

/* creation d'un vue et d'un trigger pour emuler la cle etrangere lors de l'insertion */
CREATE VIEW etape4_gaulois_vue
AS
SELECT * FROM system.etape4_gaulois;
GRANT SELECT, INSERT, DELETE ON etape4_gaulois_vue TO proprietaire, amisCommuns, amisObelix;

/* trigger sur l'insertion */
CREATE OR REPLACE TRIGGER etape4_gaulois_trigger
INSTEAD OF INSERT ON etape4_gaulois_vue
REFERENCING new AS new old AS old
DECLARE
	village_id INT;
BEGIN
	SELECT id INTO village_id
	FROM system.etape4_village@panoramix
	WHERE id = :new.id;
	
	IF village_id IS NULL THEN
		raise_application_error (-20001, 'le village n existe pas');
	ELSE
		INSERT INTO system.etape4_gaulois (id,nom,profession,village) VALUES (:new.id, :new.nom, :new.profession, :new.village);
	END IF;
END;
/
		