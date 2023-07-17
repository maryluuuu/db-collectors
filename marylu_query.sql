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
CREATE PROCEDURE query2disco(id_collezione integer unsigned, id_disco integer unsigned , id_collezionista integer unsigned)
BEGIN
	DECLARE id_c integer unsigned;
	SET id_c= (SELECT ID_collezionista FROM collezione WHERE ID=id_collezione);
    IF id_c=id_collezionista THEN 
		INSERT INTO raccolta(ID,ID_collezione,ID_disco) VALUES
        (last_insert_id(),id_collezione,id_disco);
	END IF;
END$$


CREATE PROCEDURE query2traccia( id_disco integer unsigned, durata1 integer unsigned, titolo1 varchar(100), isrc varchar(12))
BEGIN
	INSERT INTO traccia(ID,titolo,durata,ID_disco,ISRC) VALUES (last_insert_id(),titolo1,SEC_TO_TIME(durata1),id_disco,isrc);
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
CREATE PROCEDURE lista_dischi (id_collezione integer unsigned)
BEGIN
SELECT * FROM disco JOIN raccolta ON disco.ID=raccolta.ID_disco
WHERE raccolta.ID_collezione=id_collezione;
END$$

-- 7. Tracklist di un disco
CREATE PROCEDURE tracklist (disco integer unsigned)
BEGIN
SELECT DISTINCT * FROM traccia 
WHERE traccia.ID_disco = disco;
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




