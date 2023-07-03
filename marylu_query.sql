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
DROP PROCEDURE IF EXISTS trova_disco;
DROP PROCEDURE IF EXISTS statistiche1;
DROP PROCEDURE IF EXISTS statistiche2;

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
		SELECT SUM(traccia.durata)
		FROM traccia
		WHERE traccia.ID_disco = id_disco
	)
	WHERE disco.ID = id_disco;		
END$$


-- Procedura per la rimozione di un disco da una collezione
CREATE PROCEDURE eliminazione_da_collezione(id_disco integer unsigned, id_collezione integer unsigned)
BEGIN
    DELETE FROM collezioni_dischi 
    WHERE ID_disco = id_disco and ID_collezione = id_collezione;
    
END$$


-- Rimozione di un disco dal database
CREATE PROCEDURE elimina_disco(disco_id integer unsigned) 
BEGIN
    DECLARE doppioni_count INT;

    -- Controlla se ci sono doppioni collegati al disco
    SELECT COUNT(*) INTO doppioni_count
    FROM doppione
    WHERE ID_disco = disco_id;

    -- Se ci sono doppioni, elimina prima i doppioni e poi il disco
    IF doppioni_count > 1 THEN
        -- Diminuisci di una quantità i doppioni di ID_disco
        UPDATE doppione
        SET quantita = quantita - 1 WHERE ID_disco = disco_id;
        
        SELECT CONCAT('La quantita disponibile del disco ', disco_id, ' è ', quantita , '.') AS Message;
    ELSE
        -- Se non ci sono doppioni, elimina solo il disco
        DELETE FROM disco
        WHERE ID = disco_id;
        
        SELECT CONCAT('Disco con ID ', disco_id, ' eliminato.') AS Message;
    END IF;
END $$

-- Modifica dello stato della collezione
-- se la modifichiamo da privata a pubblica eliminiamo tutte le righe nella tabella condivisa corrispondenti
-- perchè ora tutti possono vedere la collezione e non serve tenere un registro dei singoli collezionisti come nel caso privato
CREATE PROCEDURE modifica_stato_collezione (id_collezione integer unsigned)
BEGIN
UPDATE collezione
SET flag = CASE
    WHEN flag = 'privata' THEN 'pubblica'
    WHEN flag = 'pubblica' THEN 'privata'
END
WHERE ID=id_collezione;
IF (SELECT flag FROM collezione WHERE ID=id_collezione) ='pubblica' THEN
	DELETE  FROM condivisa WHERE ID_collezione = id_collezione;
    END IF;
END$$

-- Lista di tutti i dischi in una collezione
CREATE PROCEDURE lista_dischi (id_collezione integer unsigned)
BEGIN
SELECT * FROM disco JOIN collezioni_dischi ON disco.ID=collezioni_dischi.ID_disco
WHERE collezioni_dischi.ID_collezione=id_collezione;
END$$

-- Tracklist di un disco
CREATE PROCEDURE tracklist (id_disco integer unsigned)
BEGIN
SELECT * FROM traccia WHERE traccia.ID_disco = id_disco;
END$$ 

-- Ricerca di dischi in base a nomi di...
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
 JOIN collezioni_dischi ON disco.ID=collezioni_dischi.ID_disco
 JOIN collezione ON collezione.ID=collezioni_dischi.ID_collezione
 WHERE collezione.ID_collezionista=id_collezionista and collezione.flag='privata'

 
 UNION
 -- Ricerca di dischi in collezioni pubbliche di un collezionista 
 SELECT titolo_disco FROM disco
 JOIN composto ON disco.ID=composto.ID_disco
 JOIN collezioni_dischi ON disco.ID=collezioni_dischi.ID_disco
 JOIN collezione ON collezione.ID=collezioni_dischi.ID_collezione
 WHERE collezione.ID_collezionista=id_collezionista and collezione.flag='pubblica'

 
 UNION
 -- Ricerca di dischi in collezioni condivise con un collezionista
 SELECT titolo_disco FROM disco
 JOIN composto ON disco.ID=composto.ID_disco
 JOIN collezioni_dischi ON disco.ID=collezioni_dischi.ID_disco
 JOIN collezione ON collezione.ID=collezioni_dischi.ID_collezione
JOIN condivisa ON collezione.ID = condivisa.ID_collezione
WHERE collezione.flag = 'privata' AND condivisa.ID_collezionista = id_collezionista;

  END$$
  
-- Statistiche: numero di collezioni di ciascun collezionista.
CREATE PROCEDURE statistiche1()
BEGIN
SELECT nickname, COUNT(*) as numero_collezioni FROM collezione JOIN collezionista ON ID_collezionista=collezionista.ID
GROUP BY ID_collezionista;
END$$

-- Statistiche: numero di dischi per genere nel sistema.
CREATE PROCEDURE statistiche2()
BEGIN
SELECT nome, COUNT(*) as numero_dischi FROM genere JOIN disco ON ID_genere=genere.ID
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

-- Trigger per l'aggiornamento dello stato di una collezione
CREATE TRIGGER cambia_stato_collezione
AFTER UPDATE ON collezione
FOR EACH ROW
BEGIN
    IF NEW.flag = 'privata' AND OLD.flag = 'pubblica' THEN
        IF (
            SELECT COUNT(*) FROM condivisa WHERE ID_collezione = NEW.ID
        ) != 0 THEN
            DELETE FROM condivisa WHERE ID_collezione = NEW.ID;
        END IF;
    END IF;
END$$


-- CALL trova_disco(2);
