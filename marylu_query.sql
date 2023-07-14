use progettolab;

-- Elimina le procedure esistenti
DROP PROCEDURE IF EXISTS calcola_durata_totale;
DROP PROCEDURE IF EXISTS verifica_anno;
DROP PROCEDURE IF EXISTS eliminazione_da_collezione;
DROP PROCEDURE IF EXISTS cancellazione_collezione;
DROP PROCEDURE IF EXISTS elimina_disco;
DROP PROCEDURE IF EXISTS lista_dischi;
DROP PROCEDURE IF EXISTS modifica_stato_collezione;
DROP PROCEDURE IF EXISTS tracklist;
DROP PROCEDURE IF EXISTS trova_disco; -- DA RIVEDERE
DROP PROCEDURE IF EXISTS statistiche1;
DROP PROCEDURE IF EXISTS statistiche2;
DROP PROCEDURE IF EXISTS numero_brani;
DROP PROCEDURE IF EXISTS minuti_totali;
DROP PROCEDURE IF EXISTS verifica_visibilita;
DROP PROCEDURE IF EXISTS inserimento_utente;

-- Elimina i trigger esistenti
DROP TRIGGER IF EXISTS controllo_anno1;
DROP TRIGGER IF EXISTS controllo_anno2;
DROP TRIGGER IF EXISTS inserisci_durata_totale;
DROP TRIGGER IF EXISTS aggiorna_durata_totale;
DROP TRIGGER IF EXISTS eliminazione_disco;
DROP trigger IF EXISTS eliminazione_collezione;
DROP TRIGGER IF EXISTS cambia_stato_collezione;

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


-- 4. Procedura per la rimozione di un disco da una collezione
CREATE PROCEDURE eliminazione_da_collezione(id_disco integer unsigned, id_collezione integer unsigned)
BEGIN
    DELETE FROM raccolta 
    WHERE ID_disco = id_disco and ID_collezione = id_collezione;
    
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
CREATE PROCEDURE trova_disco (id_collezionista integer unsigned)
BEGIN
SELECT titolo_disco FROM disco
JOIN composto ON disco.ID = composto.ID_disco
WHERE composto.ID_autore is null
OR composto.ruolo is null
OR composto.ruolo is null
OR disco.titolo_disco = '%Abbey Road%'
 UNION
 -- Ricerca collezioni private di un collezionista
 SELECT titolo_disco FROM disco
 JOIN composto ON disco.ID=composto.ID_disco
 JOIN raccolta ON disco.ID=raccolta.ID_disco
 JOIN collezione ON collezione.ID=raccolta.ID_collezione
 WHERE collezione.ID_collezionista=id_collezionista and collezione.flag=0

 UNION
 -- Ricerca di dischi in collezioni pubbliche di un collezionista 
 SELECT titolo_disco FROM disco
 JOIN composto ON disco.ID=composto.ID_disco
 JOIN raccolta ON disco.ID=raccolta.ID_disco
 JOIN collezione ON collezione.ID=raccolta.ID_collezione
 WHERE collezione.ID_collezionista=id_collezionista and collezione.flag=1
 
 UNION
 -- Ricerca di dischi in collezioni condivise con un collezionista
 SELECT titolo_disco FROM disco
 JOIN composto ON disco.ID=composto.ID_disco
 JOIN raccolta ON disco.ID=raccolta.ID_disco
 JOIN collezione ON collezione.ID=raccolta.ID_collezione
JOIN condivisa ON collezione.ID = condivisa.ID_collezione
WHERE collezione.flag = 0 AND condivisa.ID_collezionista = id_collezionista;

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
CREATE PROCEDURE numero_brani (id_autore integer unsigned)
BEGIN
SELECT autore.nome, COUNT(DISTINCT traccia.ID) as numero_brani 
FROM scritta 
JOIN traccia ON scritta.ID_traccia = traccia.ID
JOIN autore ON scritta.ID_autore = autore.ID
JOIN raccolta ON traccia.ID_disco=raccolta.ID_disco
JOIN collezione ON raccolta.ID_collezione = collezione.ID
WHERE autore.ID=id_autore AND collezione.flag=1
GROUP BY autore.nome;
END$$

-- 11. Minuti totali di musica riferibili a un certo autore (compositore, musicista) memorizzati nelle collezioni pubbliche
CREATE PROCEDURE minuti_totali(id_autore integer unsigned)
BEGIN
SELECT autore.nome, SEC_TO_TIME(SUM(DISTINCT TIME_TO_SEC(traccia.durata))) AS durata_totale_minuti
FROM scritta 
JOIN traccia ON scritta.ID_traccia = traccia.ID
JOIN autore ON scritta.ID_autore = autore.ID
JOIN raccolta ON traccia.ID_disco=raccolta.ID_disco
JOIN collezione ON raccolta.ID_collezione = collezione.ID
WHERE autore.ID=id_autore AND collezione.flag=1
GROUP BY autore.ID;
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
SELECT nome, COUNT(*) as numero_dischi FROM genere JOIN disco ON ID_genere=genere.ID
GROUP BY ID_genere;
END$$

-- Procedura per dare privilegi admin
-- ...

-- Procedura per l'inserimento utenti
CREATE PROCEDURE inserimento_utente(nickname1 varchar(50), email1 varchar(100), passkey1 varchar(100))
BEGIN
  -- Creazione dell'utente
  SET @create_user_query = CONCAT('CREATE USER ', nickname1, '@localhost IDENTIFIED BY "', passkey1, '"');
  PREPARE create_user_stmt FROM @create_user_query;
  EXECUTE create_user_stmt;
  DEALLOCATE PREPARE create_user_stmt;
  
  -- Assegnazione dei privilegi
  SET @grant_query = CONCAT('GRANT SELECT, INSERT, DELETE, UPDATE ON progettolab.* TO ', nickname1, '@localhost');
  PREPARE grant_stmt FROM @grant_query;
  EXECUTE grant_stmt;
  DEALLOCATE PREPARE grant_stmt;
  
  -- Inserimento delle informazioni nella tabella "collezionista"
  INSERT INTO collezionista (nickname, email, passkey) VALUES (nickname1, email1, passkey1);
  
  -- Aggiornamento dei privilegi
  FLUSH PRIVILEGES;
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

-- Trigger per l'aggiornamento dello stato di una collezione
CREATE TRIGGER cambia_stato_collezione
AFTER UPDATE ON collezione
FOR EACH ROW
BEGIN
    IF NEW.flag = 0 AND OLD.flag = 1 THEN
        IF (
            SELECT COUNT(*) FROM condivisa WHERE ID_collezione = NEW.ID
        ) != 0 THEN
            DELETE FROM condivisa WHERE ID_collezione = NEW.ID;
        END IF;
    END IF;
END$$


-- CALL trova_disco(2);
-- CALL minuti_totali('Pink Floyd');
-- CALL verifica_visibilita(1,1);
-- SELECT * from mysql.user
SHOW GRANTS FOR 'alice'@'localhost';