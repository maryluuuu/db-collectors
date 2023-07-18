use progettolab;

-- Elimina le procedure esistenti
DROP PROCEDURE IF EXISTS calcola_durata_totale;
DROP PROCEDURE IF EXISTS verifica_anno;
DROP PROCEDURE IF EXISTS query1;
DROP PROCEDURE IF EXISTS query2disco;
DROP PROCEDURE IF EXISTS query2traccia;
DROP PROCEDURE IF EXISTS eliminazione_da_collezione;
DROP PROCEDURE IF EXISTS cancellazione_collezione;
DROP PROCEDURE IF EXISTS elimina_disco;
DROP PROCEDURE IF EXISTS lista_dischi;
DROP PROCEDURE IF EXISTS modifica_stato_collezione;
DROP PROCEDURE IF EXISTS tracklist;
DROP PROCEDURE IF EXISTS trova_disco; -- DA RIVEDERE
DROP PROCEDURE IF EXISTS braniPerAutore;
DROP PROCEDURE IF EXISTS minutiPerAutore;
DROP PROCEDURE IF EXISTS statistiche1;
DROP PROCEDURE IF EXISTS statistiche2;
DROP PROCEDURE IF EXISTS minuti_totali;
DROP PROCEDURE IF EXISTS verifica_visibilita;

-- Elimina i trigger esistenti
DROP TRIGGER IF EXISTS controllo_anno1;
DROP TRIGGER IF EXISTS controllo_anno2;
DROP TRIGGER IF EXISTS inserisci_durata_totale;
DROP TRIGGER IF EXISTS aggiorna_durata_totale;

-- Elimina le viste esistenti
DROP VIEW IF EXISTS dischiCPubbliche;
DROP VIEW IF EXISTS dischiAutori;

DELIMITER $$

-- Procedura verifica anno_uscita di disco
CREATE PROCEDURE verifica_anno(anno smallint unsigned)
BEGIN
    IF anno < 1900 OR anno > year(curdate()) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Anno non valido';
    END IF;
END$$

-- Procedura calcolo durata_totale disco
CREATE PROCEDURE calcola_durata_totale(id_disco INTEGER UNSIGNED) 
BEGIN
    UPDATE disco
	SET disco.durata_totale = (
		SELECT SEC_TO_TIME(SUM(DISTINCT TIME_TO_SEC(traccia.durata)))
		FROM traccia
		WHERE traccia.ID_disco = id_disco
	)
	WHERE disco.ID = id_disco;		
END$$

-- Inserimento di un disco
CREATE PROCEDURE query0(nomed varchar(100), annod year, barcoded bigint(13),
idet integer unsigned, idge integer unsigned,formatod varchar(20),condizioned varchar(20), 
quantitad smallint unsigned, id_coll integer unsigned)
BEGIN
DECLARE var integer unsigned;
SET var = last_insert_id();
INSERT INTO disco(ID, titolo_disco,anno_uscita,barcode,ID_etichetta,ID_genere) VALUES
(var,nomed, annod, barcoded, idet, idge);
INSERT INTO doppione (quantita, formato, condizione, ID_disco, ID_collezionista) VALUES 
(quantitad, formatod, condizioned, var, id_coll);
END$$

-- 1. Inserimento di una nuova collezione.
CREATE PROCEDURE query1(nomec varchar(80), nicknamec varchar(80))
BEGIN
	DECLARE id_collezionista integer unsigned;
	SET id_collezionista = (SELECT ID FROM collezionista WHERE nickname=nicknamec);
    IF id_collezionista is not null then 
		INSERT INTO collezione(ID,nome,ID_collezionista) VALUES
		(last_insert_id(), nomec, id_collezionista);
    END IF;
END$$

-- 2. Aggiunta di dischi a una collezione e di tracce a un disco.

CREATE PROCEDURE query2disco(
nomecollezione varchar(80),
nomed VARCHAR(100), 
annod year, 
barcoded bigint(13),
id_collezionista integer unsigned
)
BEGIN
  DECLARE id_collezione INT;
  DECLARE id_disco INT;
  
  -- Verifica se la collezione esiste
  SELECT ID INTO id_collezione
  FROM collezioni
  WHERE nome = nome_collezione AND ID_collezionista=id_collezionista;
  
  -- Verifica se il disco esiste
  SELECT ID INTO id_disco
  FROM disco
  WHERE titolo_disco = nomed and anno_uscita=annod;
  
  -- Se la collezione o il disco non esistono, esci dalla procedura
  IF id_collezione IS NULL OR id_disco IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La collezione non esiste';
  END IF;
  -- Se il disco non esiste, crea il disco
  IF id_disco IS NULL THEN
  SET id_disco=last_insert_id();
  INSERT INTO disco(ID,titolo_disco, anno_uscita, barcode) VALUES
  (id_disco,nomed,annod,barcoded);
  END IF;
  
  -- Verifica se l'associazione esiste già nella tabella collezioni_disco
  IF EXISTS (
    SELECT 1
    FROM raccolta
    WHERE ID_collezione = id_collezione AND ID_disco = id_disco
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il disco è già presente nella collezione';
  END IF;
  
  -- Inserisci l'associazione nella tabella collezioni_disco
  INSERT INTO collezioni_disco (ID_collezione, ID_disco)
  VALUES (id_collezione, id_disco);
END$$

CREATE PROCEDURE query2traccia( 
nomed varchar(100), 
annod smallint unsigned,
duratat time,
nomet varchar(100), 
isrc varchar(12))
BEGIN
  DECLARE id_traccia INT;
  DECLARE id_disco INT;
  
  -- Verifica se il disco esiste
  SELECT ID INTO id_disco
  FROM disco
  WHERE nomed = titolo_disco AND annod=anno_uscita;
  IF id_disco IS NULL THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il disco non esiste';
  END IF;
  -- Verifica se la traccia esiste
  SELECT ID INTO id_traccia
  FROM traccia
  WHERE isrc=ISRC;
  -- Se la traccia non esiste viene inserita
  IF id_traccia IS NULL THEN 
	SET id_traccia=last_insert_id();
	INSERT INTO traccia(ID,titolo,durata,ISRC,ID_disco) VALUES 
	(id_traccia,titolod,duratad,isrc,id_disco);
END IF;
END$$

-- 3. Modifica dello stato della collezione
-- se la modifichiamo da privata a pubblica eliminiamo tutte le righe nella tabella condivisa corrispondenti
-- perchè ora tutti possono vedere la collezione e non serve tenere un registro dei singoli collezionisti come nel caso privato
CREATE PROCEDURE modifica_stato_collezione (id_collezione integer unsigned)
BEGIN
UPDATE collezione
SET flag = CASE
    WHEN flag = 0 THEN 1
    WHEN flag = 1 THEN 0
END
WHERE ID=id_collezione;
IF (SELECT flag FROM collezione WHERE ID=id_collezione) = 1 THEN
	DELETE  FROM condivisa WHERE ID_collezione = id_collezione;
    END IF;
END$$

-- 4. Procedura per la rimozione di un disco da una collezione
CREATE PROCEDURE eliminazione_da_collezione(id_disco integer unsigned, id_collezione integer unsigned)
BEGIN
    DELETE FROM raccolta 
    WHERE ID_disco = id_disco and ID_collezione = id_collezione;
    
END$$

-- 6. Lista di tutti i dischi in una collezione
CREATE PROCEDURE lista_dischi (nomec varchar(60), nomecollezionista integer unsigned)
BEGIN
DECLARE id_collezione integer unsigned;
DECLARE id_c integer ;
SELECT ID INTO id_c FROM collezionista WHERE collezionista.nickname=nomec;
SELECT ID INTO id_collezione FROM collezione WHERE collezione.nome=nomec AND ID_collezionista=id_c;
IF id_collezione is null OR id_c is null THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La collezione o il collezionista non esistono';
END IF;
SELECT disco.titolo FROM disco 
JOIN raccolta ON disco.ID=raccolta.ID_disco
WHERE raccolta.ID_collezione=id_collezione;
END$$

-- 7. Tracklist di un disco
CREATE PROCEDURE tracklist (nomed varchar(100), annod year)
BEGIN
DECLARE id_d integer unsigned;
SELECT ID INTO id_d FROM disco WHERE titolo_disco=nomed AND anno_uscita=annod;
IF id_D is null THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il disco non esiste';
END IF;
SELECT DISTINCT titolo, traccia.durata, titolo_disco 
FROM disco JOIN traccia ON disco.ID=traccia.ID_disco
WHERE traccia.ID_disco = id_d;
END$$ 

-- 8. Ricerca di dischi in base a nomi di...
CREATE PROCEDURE trova_disco (id_collezionista integer unsigned, nome_autore varchar(50), titolo_disco varchar(50))
BEGIN
-- Ricerca in base ai nomi di autori/compositori/interpreti e/o titoli nelle collezioni private di un collezionista
SELECT dischiAutori.titolo_disco
FROM dischiAutori
JOIN raccolta ON raccolta.ID_disco=dischiAutori.ID_disco
JOIN collezione ON collezione.ID = raccolta.ID_collezione
WHERE (dischiAutori.nome LIKE (CONCAT('%',nome_autore,'%')) OR dischiAutori.titolo_disco LIKE (CONCAT('%',titolo_disco,'%')))
    AND collezione.flag = 0
    AND collezione.ID_collezionista = id_collezionista

UNION

-- Ricerca in base ai nomi di autori/compositori/interpreti e/o titoli nelle collezioni condivise con un collezionista
SELECT dischiAutori.titolo_disco
FROM dischiAutori
JOIN raccolta ON raccolta.ID_disco=dischiAutori.ID_disco
JOIN collezione ON collezione.ID = raccolta.ID_collezione
JOIN condivisa ON condivisa.ID_collezione = collezione.ID
WHERE (dischiAutori.nome LIKE (CONCAT('%',nome_autore,'%')) OR dischiAutori.titolo_disco LIKE (CONCAT('%',titolo_disco,'%')))
    AND condivisa.ID_collezionista = id_collezionista

UNION

-- Ricerca in base ai nomi di autori/compositori/interpreti e/o titoli nelle collezioni pubbliche
SELECT dischiAutori.titolo_disco
FROM dischiAutori
JOIN raccolta ON raccolta.ID_disco = dischiAutori.ID_disco
JOIN dischiCPubbliche ON dischiCPubbliche.ID = raccolta.ID_disco
WHERE (dischiAutori.nome LIKE (CONCAT('%',nome_autore,'%')) OR dischiAutori.titolo_disco LIKE (CONCAT('%',titolo_disco,'%')));

  END$$
  
-- 9. Verifica della visibilità di una collezione da parte di un collezionista.
CREATE PROCEDURE verifica_visibilita (id_collezionista integer unsigned, id_collezione integer unsigned)
SELECT disco.*
FROM collezione c 
JOIN condivisa ON c.ID = condivisa.ID_collezione
JOIN raccolta ON raccolta.ID_collezione = c.ID
JOIN disco ON disco.ID=raccolta.ID_disco
WHERE (c.ID=id_collezione) AND (c.ID_collezionista = id_collezionista OR condivisa.ID_collezionista = id_collezionista OR c.flag = 1);

-- 10. Numero dei brani (tracce di dischi) distinti di un certo autore (compositore, musicista) presenti nelle collezioni pubbliche.
CREATE PROCEDURE braniPerAutore(id_autore integer unsigned)
BEGIN
DECLARE 
SELECT dischiAutori.nome, COUNT(DISTINCT traccia.ID) AS Numero_brani
FROM dischiAutori 
JOIN traccia ON traccia.ID_disco=dischiAutori.ID_disco
LEFT JOIN scritta ON scritta.ID_autore=dischiAutori.ID_autore
JOIN dischiCPubbliche ON dischiCPubbliche.ID=dischiAutori.ID_disco
WHERE dischiAutori.ID_autore=id_autore
GROUP BY dischiAutori.ID_autore;
END$$

-- 11. Minuti totali di musica riferibili a un certo autore (compositore, musicista) memorizzati nelle collezioni pubbliche
CREATE PROCEDURE minutiPerAutore(id_autore integer unsigned)
BEGIN
SELECT dischiAutori.nome, SEC_TO_TIME(SUM(DISTINCT TIME_TO_SEC(traccia.durata))) AS Numero_brani
FROM dischiAutori
JOIN traccia ON traccia.ID_disco=dischiAutori.ID_disco
LEFT JOIN scritta ON scritta.ID_autore=dischiAutori.ID_autore
JOIN dischiCPubbliche ON dischiCPubbliche.ID = dischiAutori.ID_disco
WHERE dischiAutori.ID_autore=id_autore
GROUP BY dischiAutori.ID_autore;
END$$

-- 12.1 Statistiche: numero di collezioni di ciascun collezionista.
CREATE PROCEDURE statistiche1()
BEGIN
SELECT nickname, COUNT(*) as numero_collezioni FROM collezione JOIN collezionista ON ID_collezionista=collezionista.ID
GROUP BY ID_collezionista;
END$$

-- 12.2 Statistiche: numero di dischi per genere nel sistema.
CREATE PROCEDURE statistiche2()
BEGIN
SELECT nome, COUNT(*) as numero_dischi FROM genere JOIN disco ON genere.ID = disco.ID_genere
GROUP BY ID_genere;
END$$


-- TRIGGER

-- Trigger per il controllo dell'anno
CREATE TRIGGER controllo_anno1
BEFORE INSERT ON disco
FOR EACH ROW BEGIN
CALL verifica_anno(NEW.anno_uscita);
END$$


-- Trigger aggiornamento anno disco
CREATE TRIGGER controllo_anno2
BEFORE UPDATE ON disco
FOR EACH ROW BEGIN
IF NEW.anno_uscita != OLD.anno_uscita THEN
CALL verifica_anno(NEW.anno_uscita);
END IF;
END$$


-- Trigger inserimento di tracce
CREATE TRIGGER inserisci_durata_totale
AFTER INSERT ON traccia
FOR EACH ROW BEGIN
  CALL calcola_durata_totale(NEW.ID_disco);
END$$


-- Trigger inserimento di tracce
CREATE TRIGGER aggiorna_durata_totale
AFTER UPDATE ON traccia
FOR EACH ROW BEGIN
CALL calcola_durata_totale(NEW.ID_disco);
END$$


-- VISTE

-- Vista per la visualizzazione delle collezioni pubbliche nel database
CREATE VIEW dischiCPubbliche AS
SELECT DISTINCT disco.ID ,titolo_disco
FROM disco 
JOIN raccolta ON raccolta.ID_disco = disco.ID
JOIN collezione ON collezione.ID = raccolta.ID_collezione
WHERE collezione.flag=1;

CREATE VIEW dischiAutori AS
SELECT disco.ID as ID_disco, titolo_disco, composto.ID_autore, autore.nome
FROM disco
JOIN composto ON composto.ID_disco = disco.ID
JOIN autore ON autore.ID = composto.ID_autore;



-- CALL trova_disco(2);
-- CALL minuti_totali('Pink Floyd');
-- CALL verifica_visibilita(1,1);
-- dischi in collezioni pubbliche
call trova_disco(1,'The Beatles',null);




