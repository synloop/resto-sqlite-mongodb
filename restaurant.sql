/* ============================================================
   restaurant.sql  –  création + données de test
   ============================================================ */
PRAGMA foreign_keys = ON;

/* ---------- 1. TABLES PRINCIPALES -------------------------- */
CREATE TABLE CLIENT (
    id_client      INTEGER PRIMARY KEY,
    nom            TEXT    NOT NULL,
    prenom         TEXT,
    email          TEXT    UNIQUE,
    tel            TEXT
);

CREATE TABLE RESTAURANT (
    id_restaurant  INTEGER PRIMARY KEY,
    nom            TEXT    NOT NULL,
    adresse        TEXT,
    ville          TEXT
);

CREATE TABLE EMPLOYE (
    id_employe     INTEGER PRIMARY KEY,
    id_restaurant  INTEGER NOT NULL,
    nom            TEXT    NOT NULL,
    prenom         TEXT,
    poste          TEXT,
    date_embauche  DATE,
    FOREIGN KEY (id_restaurant) REFERENCES RESTAURANT(id_restaurant)
);

CREATE TABLE ARTICLE (
    id_article     INTEGER PRIMARY KEY,
    libelle        TEXT    NOT NULL,
    prix_unitaire  REAL    NOT NULL
);

CREATE TABLE MENU (
    id_menu        INTEGER PRIMARY KEY,
    id_restaurant  INTEGER NOT NULL,
    nom            TEXT    NOT NULL,
    prix_base      REAL,              -- mis à jour par trigger
    FOREIGN KEY (id_restaurant) REFERENCES RESTAURANT(id_restaurant)
);

CREATE TABLE COMMANDE (
    id_commande    INTEGER PRIMARY KEY,
    id_client      INTEGER NOT NULL,
    date_commande  DATETIME DEFAULT CURRENT_TIMESTAMP,
    statut         TEXT,
    FOREIGN KEY (id_client) REFERENCES CLIENT(id_client)
);

/* ---------- 2. TABLES D’ASSOCIATION ------------------------ */
CREATE TABLE COMMANDE_MENU (
    id_commande    INTEGER,
    id_menu        INTEGER,
    PRIMARY KEY (id_commande, id_menu),
    FOREIGN KEY (id_commande) REFERENCES COMMANDE(id_commande) ON DELETE CASCADE,
    FOREIGN KEY (id_menu)     REFERENCES MENU(id_menu)         ON DELETE CASCADE
);

CREATE TABLE MENU_ARTICLE (
    id_menu     INTEGER,
    id_article  INTEGER,
    quantite    INTEGER NOT NULL CHECK (quantite >= 1),
    PRIMARY KEY (id_menu, id_article),
    FOREIGN KEY (id_menu)    REFERENCES MENU(id_menu)    ON DELETE CASCADE,
    FOREIGN KEY (id_article) REFERENCES ARTICLE(id_article)
);

/* ---------- 3. TRIGGERS : PRIX DU MENU --------------------- */
DROP TRIGGER IF EXISTS maj_prix_menu_insert;
DROP TRIGGER IF EXISTS maj_prix_menu_update;
DROP TRIGGER IF EXISTS maj_prix_menu_delete;

/* Recalcule après INSERT */
CREATE TRIGGER maj_prix_menu_insert
AFTER INSERT ON MENU_ARTICLE
BEGIN
    UPDATE MENU
    SET prix_base = COALESCE((
        SELECT SUM(a.prix_unitaire * ma.quantite)
        FROM   MENU_ARTICLE ma
        JOIN   ARTICLE a USING(id_article)
        WHERE  ma.id_menu = NEW.id_menu
    ), 0)
    WHERE id_menu = NEW.id_menu;
END;

/* Recalcule après UPDATE */
CREATE TRIGGER maj_prix_menu_update
AFTER UPDATE ON MENU_ARTICLE
BEGIN
    -- Nouveau menu potentiellement impacté
    UPDATE MENU
    SET prix_base = COALESCE((
        SELECT SUM(a.prix_unitaire * ma.quantite)
        FROM   MENU_ARTICLE ma
        JOIN   ARTICLE a USING(id_article)
        WHERE  ma.id_menu = NEW.id_menu
    ), 0)
    WHERE id_menu = NEW.id_menu;

    -- Ancien menu (si id_menu change)
    UPDATE MENU
    SET prix_base = COALESCE((
        SELECT SUM(a.prix_unitaire * ma.quantite)
        FROM   MENU_ARTICLE ma
        JOIN   ARTICLE a USING(id_article)
        WHERE  ma.id_menu = OLD.id_menu
    ), 0)
    WHERE id_menu = OLD.id_menu;
END;

/* Recalcule après DELETE */
CREATE TRIGGER maj_prix_menu_delete
AFTER DELETE ON MENU_ARTICLE
BEGIN
    UPDATE MENU
    SET prix_base = COALESCE((
        SELECT SUM(a.prix_unitaire * ma.quantite)
        FROM   MENU_ARTICLE ma
        JOIN   ARTICLE a USING(id_article)
        WHERE  ma.id_menu = OLD.id_menu
    ), 0)
    WHERE id_menu = OLD.id_menu;
END;

/* ---------- 4. DONNÉES DE TEST ----------------------------- */
/* Restaurants */
INSERT INTO RESTAURANT (id_restaurant, nom, adresse, ville) VALUES
  (1,'Le Bistrot','12 rue du Marché','Lyon'),
  (2,'Veggie Spot','8 quai Vert','Lyon'),
  (3,'Chez Elena','5 place Pailleron','Grenoble');

/* Articles */
INSERT INTO ARTICLE (id_article, libelle, prix_unitaire) VALUES
  (1,'Burger',12.5),
  (2,'Frites',4),
  (3,'Salade',5.5),
  (4,'Café',2);

/* Menus (prix_base sera calculé) */
INSERT INTO MENU (id_menu,id_restaurant,nom) VALUES
  (1,1,'Menu Midi'),
  (2,2,'Menu Végétarien');

/* Composition des menus */
INSERT INTO MENU_ARTICLE VALUES
  (1,1,1),  -- Menu 1 : 1 Burger
  (1,2,2),  --           2 Frites
  (1,4,1),  --           1 Café
  (2,3,2),  -- Menu 2 : 2 Salades
  (2,4,1);  --           1 Café

/* Clients */
INSERT INTO CLIENT (id_client,nom,prenom,email,tel) VALUES
  (1,'Dupont','Jean','jean.dupont@gmail.com','0601010101'),
  (2,'Martin','Clara','clara.martin@yahoo.fr','0602020202'),
  (3,'Durand','Hugo','hugo@outlook.com','0603030303'),
  (4,'Nguyen','Linh','linh@gmail.com','0604040404'),
  (5,'Rossi','Paolo','paolo@gmail.com','0605050505');

/* Employés */
INSERT INTO EMPLOYE (id_employe,id_restaurant,nom,prenom,poste,date_embauche) VALUES
  (1,1,'Bernard','Alice','Serveuse','2023-04-01'),
  (2,1,'Fabre','Luc','Cuisinier','2022-10-15'),
  (3,2,'Morel','Inès','Caissière','2024-01-10'),
  (4,3,'Petit','Omar','Livreur','2023-06-20');

/* Commandes */
INSERT INTO COMMANDE (id_commande,id_client,statut) VALUES
  (1,1,'en cours'),
  (2,3,'preparée');

/* Lignes de commandes */
INSERT INTO COMMANDE_MENU VALUES
  (1,1),  -- commande 1 = menu 1
  (2,2);  -- commande 2 = menu 2

/* ---------- FIN DU SCRIPT ---------------------------------- */

