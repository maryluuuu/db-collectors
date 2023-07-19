use progettolab;
-- Elimina le funzioni esistenti
DROP FUNCTION IF EXISTS query1;
DROP FUNCTION IF EXISTS query2traccia;

-- Elimina le procedure esistenti
DROP PROCEDURE IF EXISTS calcola_durata_totale;
DROP PROCEDURE IF EXISTS verifica_anno;
DROP PROCEDURE IF EXISTS query2disco;
DROP PROCEDURE IF EXISTS eliminazione_da_collezione;
DROP PROCEDURE IF EXISTS query5;
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
DROP PROCEDURE IF EXISTS query13;

-- Elimina i trigger esistenti
DROP TRIGGER IF EXISTS controllo_anno1;
DROP TRIGGER IF EXISTS controllo_anno2;
DROP TRIGGER IF EXISTS inserisci_durata_totale;
DROP TRIGGER IF EXISTS aggiorna_durata_totale;

-- Elimina le viste esistenti
DROP VIEW IF EXISTS dischiCPubbliche;
DROP VIEW IF EXISTS dischiAutori;

-- Elimina le tabelle temporanee
DROP TEMPORARY TABLE IF EXISTS temp_results;

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

-- 1. Inserimento di una nuova collezione.
CREATE FUNCTION query1(nomec varchar(80), id_collezionista integer unsigned) RETURNS integer unsigned
READS SQL DATA
BEGIN
    IF id_collezionista is null or nomec is null then 
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valori inseriti errati';
	END IF;
    INSERT INTO collezione(nome,ID_collezionista) VALUES (nomec, id_collezionista);
	RETURN last_insert_id();
END$$

-- 2. Aggiunta di dischi a una collezione e di tracce a un disco.

CREATE PROCEDURE query2disco(
nomecollezione varchar(80),
nomed VARCHAR(100), 
annod year,
barcoded bigint(13),
id_collezionista integer unsigned,
formatod varchar(20),
condizioned varchar(20),
quantitad smallint unsigned,
nomea varchar(50),
ipi integer unsigned
)
BEGIN
  DECLARE id_collezione INTEGER UNSIGNED;
  DECLARE id_disco INTEGER UNSIGNED;
  DECLARE id_autore INTEGER UNSIGNED;
  DECLARE id_doppione INTEGER UNSIGNED;
  -- Verifica se la collezione esiste
  SELECT collezione.ID INTO id_collezione FROM collezione
  WHERE collezione.nome = nomecollezione AND collezione.ID_collezionista=id_collezionista LIMIT 1;
  -- Verifica se il disco esiste
  SELECT d.ID_disco INTO id_disco FROM dischiAutori d
  WHERE d.titolo_disco=nomed AND d.IPI=ipi LIMIT 1 ;
  -- Se la collezione non esiste, esci dalla procedura
  IF id_collezione IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La collezione non esiste';
  END IF;
  -- Se il disco non esiste, crea il disco e lo associa a un autore
IF id_disco IS NULL THEN
  INSERT INTO disco(titolo_disco, anno_uscita, barcode) VALUES
  (nomed,annod,barcoded);
SET id_disco=last_insert_id();
INSERT INTO autore(nome,IPI) VALUES (nomea,ipi);
SET id_autore=last_insert_id();
INSERT INTO composto(ID_disco,ID_autore) VALUES (id_disco,id_autore);
END IF;
  -- Verifica se l'associazione esiste già nella tabella raccolta
  IF not EXISTS( SELECT 1 FROM raccolta r WHERE r.ID_disco=id_disco AND r.ID_collezione=id_collezione) THEN
   -- Inserisci l'associazione nella tabella raccolta
  INSERT INTO raccolta (ID_collezione, ID_disco)
  VALUES (id_collezione, id_disco);
  END IF;
  SELECT ID INTO id_doppione FROM doppione WHERE doppione.formato=formatod AND doppione.condizione=condizioned 
  AND doppione.ID_disco=id_disco;
  IF id_doppione is null THEN
  INSERT INTO doppione(quantita, formato, condizione, ID_disco, ID_collezionista)
  VALUES (quantitad, formatod, condizioned, id_disco, id_collezionista);
  ELSE
  UPDATE doppione
  SET doppione.quantita=doppione.quantita+quantitad;
  END IF;
END$$

CREATE FUNCTION query2traccia( 
nomed varchar(100),
nomea varchar(50), 
ipi integer unsigned,
duratat smallint unsigned,
nomet varchar(100), 
isrc varchar(12)) RETURNS integer unsigned
READS SQL DATA
BEGIN
  DECLARE id_traccia INTEGER UNSIGNED;
  DECLARE id_disco INTEGER UNSIGNED;
  DECLARE id_autore INTEGER UNSIGNED;
  -- Verifica se il disco esiste
  SELECT dischiAutori.ID_disco INTO id_disco
  FROM dischiAutori WHERE dischiAutori.IPI=ipi AND dischiAutori.titolo_disco=nomed;
  IF id_disco IS NULL THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il disco non esiste';
  END IF;
  SELECT ID INTO id_autore FROM autore
	WHERE autore.IPI=ipi LIMIT 1;
  -- Verifica se la traccia esiste
  SELECT traccia.ID INTO id_traccia
  FROM traccia
  WHERE traccia.titolo=nomet AND traccia.ID_disco=id_disco;
  -- Se la traccia non esiste viene inserita
  IF id_traccia IS NULL THEN 
	INSERT INTO traccia(titolo,durata,ISRC,ID_disco) VALUES 
	(nomet,SEC_TO_TIME(duratat),isrc,id_disco);
    SET id_traccia=last_insert_id();
-- controllo se l'autore esiste
IF id_autore IS NULL THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Autore non esistente';
END IF;
    INSERT INTO scritta(ID_traccia, ID_autore) VALUES (id_traccia, id_autore);
END IF;
RETURN id_traccia;
END$$

-- 3. Modifica dello stato della collezione
-- se la modifichiamo da privata a pubblica eliminiamo tutte le righe nella tabella condivisa corrispondenti
-- perchè ora tutti possono vedere la collezione e non serve tenere un registro dei singoli collezionisti come nel caso privato
CREATE PROCEDURE modifica_stato_collezione (nomec varchar(80),id_collezionista integer unsigned)
BEGIN
DECLARE idc integer unsigned;
SELECT ID INTO idc FROM collezione WHERE nome=nomec AND collezione.ID_collezionista=id_collezionista;
UPDATE collezione
SET flag = CASE
    WHEN flag = 0 THEN 1
    WHEN flag = 1 THEN 0
END
WHERE ID=idc;
IF (SELECT flag FROM collezione WHERE ID=idc) = 1 THEN
	DELETE  FROM condivisa WHERE ID_collezione = idc;
    END IF;
END$$

-- 4. Procedura per la rimozione di un disco da una collezione
CREATE PROCEDURE eliminazione_da_collezione(
nomed varchar(100),
ipi integer unsigned,
nomec varchar(80),
id_collezionista integer unsigned)
BEGIN
DECLARE iddisco integer unsigned;
DECLARE idcollezione integer unsigned;

IF id_collezionista is null THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Collezionista non esistente';
END IF;
SELECT collezione.ID INTO idcollezione FROM collezione WHERE collezione.nome=nomec AND collezione.ID_collezionista=id_collezionista;
IF idcollezione is null THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Collezione non esistente';
END IF;
SELECT ID_disco INTO iddisco FROM dischiAutori WHERE dischiAutori.titolo_disco=nomed AND dischiAutori.IPI=ipi;
DELETE FROM raccolta 
WHERE ID_disco = iddisco and ID_collezione = idcollezione;
END$$


-- 5. Rimozione di una collezione.
CREATE PROCEDURE query5(id_collezionista integer unsigned, nomec varchar(80))
BEGIN
DECLARE idc integer unsigned;
IF id_collezionista IS NULL OR nomec IS NULL THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Collezione o collezionista non esistente';
END IF;
SELECT ID INTO idc FROM collezione WHERE collezione.nome=nomec AND collezione.ID_collezionista LIMIT 1;
DELETE FROM collezione WHERE collezione.ID=idc;
DELETE FROM raccolta WHERE raccolta.ID_collezione=idc;
DELETE FROM condivisa WHERE condivisa.ID_collezione=idc;
END$$

-- 6. Lista di tutti i dischi in una collezione
CREATE PROCEDURE lista_dischi (nomec varchar(60), id_collezionista integer unsigned)
BEGIN
DECLARE id_collezione integer unsigned;
IF id_collezionista is null THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il collezionista non esiste';
END IF;
SELECT ID INTO id_collezione FROM collezione WHERE collezione.nome=nomec AND ID_collezionista=id_collezionista LIMIT 1;
IF id_collezione is null THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La collezione non esiste';
END IF;
SELECT disco.titolo_disco FROM disco 
JOIN raccolta ON disco.ID=raccolta.ID_disco
WHERE raccolta.ID_collezione=id_collezione;
END$$

-- 7. Tracklist di un disco
CREATE PROCEDURE tracklist (nomed varchar(100), ipi integer unsigned)
BEGIN
DECLARE id_disco integer unsigned;
SELECT dischiAutori.ID_disco INTO id_disco FROM dischiAutori WHERE dischiAutori.titolo_disco=nomed AND dischiAutori.IPI=ipi LIMIT 1;
IF id_disco is null THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il disco non esiste';
END IF;
SELECT DISTINCT titolo, traccia.durata, titolo_disco 
FROM disco JOIN traccia ON disco.ID=traccia.ID_disco
WHERE traccia.ID_disco = id_disco;
END$$ 

-- 8. Ricerca di dischi in base a nomi di...
CREATE PROCEDURE trova_disco (
id_collezionista integer unsigned, 
nome_autore varchar(50), 
titolo_disco varchar(50))
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
CREATE PROCEDURE verifica_visibilita (
id_collezionista integer unsigned, 
nomecollezione varchar(80), 
nickname1 varchar(60))
BEGIN
DECLARE id_collezione integer unsigned;
DECLARE id_collezionista1 integer unsigned;
IF id_collezionista is null or nickname1 is null or nomecollezione is null then
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inseriti valori errati';
END IF;
SELECT c1.ID INTO id_collezionista1 FROM collezionista c1 WHERE c1.nickname=nickname1 LIMIT 1;
IF id_collezionista1 is null then
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il collezionista non esiste';
END IF;
SELECT c.ID INTO id_collezione FROM collezione c WHERE c.nome=nomecollezione AND c.ID_collezionista=id_collezionista1 LIMIT 1;
IF id_collezione is null then
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La collezione non esiste';
END IF;
SELECT disco.titolo_disco
FROM collezione c 
JOIN raccolta ON raccolta.ID_collezione = c.ID
JOIN disco ON disco.ID=raccolta.ID_disco
LEFT JOIN condivisa ON raccolta.ID_collezione = condivisa.ID_collezione
WHERE (c.ID=id_collezione) AND (c.ID_collezionista = id_collezionista OR condivisa.ID_collezionista = id_collezionista OR c.flag = 1);
END$$

-- 10. Numero dei brani (tracce di dischi) distinti di un certo autore (compositore, musicista) presenti nelle collezioni pubbliche.
CREATE PROCEDURE braniPerAutore(nomea varchar(50),ipi integer unsigned )
BEGIN
DECLARE ida integer unsigned;
SELECT autore.ID INTO ida FROM autore WHERE IPI=ipi LIMIT 1;
SELECT dischiAutori.nome, COUNT(DISTINCT traccia.ID) AS Numero_brani
FROM dischiAutori 
JOIN traccia ON traccia.ID_disco=dischiAutori.ID_disco
LEFT JOIN scritta ON scritta.ID_autore=dischiAutori.ID_autore
JOIN dischiCPubbliche ON dischiCPubbliche.ID=dischiAutori.ID_disco
WHERE dischiAutori.ID_autore=ida
GROUP BY dischiAutori.ID_autore;
END$$

-- 11. Minuti totali di musica riferibili a un certo autore (compositore, musicista) memorizzati nelle collezioni pubbliche
CREATE PROCEDURE minutiPerAutore(nomea varchar(60), ipi integer unsigned)
BEGIN
DECLARE ida integer unsigned;
SELECT ID INTO ida FROM autore WHERE autore.IPI=ipi;
SELECT dischiAutori.nome, SEC_TO_TIME(SUM(DISTINCT TIME_TO_SEC(traccia.durata))) AS Numero_brani
FROM dischiAutori
JOIN traccia ON traccia.ID_disco=dischiAutori.ID_disco
LEFT JOIN scritta ON scritta.ID_autore=dischiAutori.ID_autore
JOIN dischiCPubbliche ON dischiCPubbliche.ID = dischiAutori.ID_disco
WHERE dischiAutori.ID_autore=ida
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

-- 13 OPZIONALE
CREATE PROCEDURE query13 (numbarcode bigint(13), titolod varchar(100), nomea varchar(50))
BEGIN
 CREATE TEMPORARY TABLE temp_results (
        titolo_disco VARCHAR(100),
        nome_autore VARCHAR(50),
        punteggio INT
        );
SELECT disco.titolo_disco, autore.nome,
       (CASE
           WHEN disco.barcode = numbarcode THEN 3
           WHEN disco.titolo_disco LIKE CONCAT('%',titoloD,'%') THEN 2
           WHEN autore.nome = nomea THEN 1
           ELSE 0
       END) AS punteggio
FROM disco
JOIN composto ON disco.ID = composto.ID_disco
JOIN autore ON composto.ID_autore = autore.ID
WHERE (disco.barcode = numbarcode
       OR disco.titolo_disco LIKE CONCAT('%',titoloD,'%')
       OR autore.nome = 'nome_autore')
ORDER BY punteggio DESC
LIMIT 10;
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
SELECT disco.ID as ID_disco, titolo_disco, composto.ID_autore, autore.nome, autore.IPI
FROM disco
JOIN composto ON composto.ID_disco = disco.ID
JOIN autore ON autore.ID = composto.ID_autore;


-- TESTED:
-- query2d ok !aggiungere ruolo!
-- query2t ok !aggiungere ruolo!
-- modifica_stato_collezione ok
-- eliminazione_da_collezione ok
-- query5 ok
-- lista_dischi ok
-- tracklist ok
-- verifica_visibilita ok;
-- minutiPerAutore ok;
-- braniPerAutore ok;
-- statistiche ok;

SELECT * FROM doppione;
  

