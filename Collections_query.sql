use progettolab;

-- Elimina le procedure esistenti
DROP PROCEDURE IF EXISTS calcola_durata_totale;
DROP PROCEDURE IF EXISTS verifica_anno;
DROP PROCEDURE IF EXISTS eliminazione_da_collezione;
DROP PROCEDURE IF EXISTS cancellazione_collezione;

-- Elimina i trigger esistenti
DROP TRIGGER IF EXISTS controllo_anno1;
DROP TRIGGER IF EXISTS controllo_anno2;
DROP TRIGGER IF EXISTS inserisci_durata_totale;
DROP TRIGGER IF EXISTS aggiorna_durata_totale;
DROP TRIGGER IF EXISTS eliminazione_disco;
DROP trigger IF EXISTS eliminazione_collezione;

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
CREATE PROCEDURE calcola_durata_totale(id integer unsigned) 
READS SQL DATA -- registrazione binaria
BEGIN
	DECLARE total INTEGER;
    
    SELECT SUM(durata) INTO total
    FROM traccia
    WHERE ID_disco = id;
    
    UPDATE disco
    SET durata_totale = total
    WHERE ID = id;
END$$

<<<<<<< HEAD
-- Eliminazione dischi
CREATE PROCEDURE elimina_disco(disco_id integer unsigned)
=======
-- Procedura di cancellazione di un disco di un collezionista

CREATE PROCEDURE eliminazione_da_collezione(id_disco integer unsigned, id_collezionista integer unsigned)
READS SQL DATA -- registrazione binaria
BEGIN
    
    SELECT ID
    FROM doppione
    WHERE ID_disco = id_disco and ID_collezionista = id_collezionista ;
    
END$$


-- Procedura di cancellazione di un disco di un collezionista
	-- #non sono sicuro della creazione della procedura
CREATE PROCEDURE cancellazione_collezione(id_collezione integer unsigned, id_collezionista integer unsigned)
READS SQL DATA -- registrazione binaria
BEGIN
    
    SELECT ID
    FROM collezione
    WHERE ID = id_collezione and ID_collezionista = id_collezionista ;
    
END$$

-- Trigger di cancellazione di una collezione di un collezionista
	-- #non sono sicuro sulla creazione del trigger
CREATE trigger eliminazione_collezione
BEFORE DELETE ON collezione
FOR EACH ROW BEGIN
CALL cancellazione_collezione(OLD.ID, OLD.ID_collezionista);
END$$

-- Trigger di cancellazione di un disco
CREATE trigger eliminazione_disco
BEFORE DELETE ON doppione
FOR EACH ROW BEGIN
CALL eliminazione_da_collezione(OLD.ID_disco, OLD.ID_collezionista);
END$$

/*
-- Procedura per il calcolo della quantità di un doppione
-- si può togliere perchè ho vincolato l'inserimento però non lo so non sono sicura
CREATE PROCEDURE calcola_quantita_totale(disco_id INT, condizione VARCHAR(20), formato varchar(20))
>>>>>>> 48672271f6b3749ebb0853e1977d64405ff4836d
BEGIN
    DECLARE doppioni_count INT;

    -- Controlla se ci sono doppioni collegati al disco
    SELECT COUNT(*) INTO doppioni_count
    FROM doppione
    WHERE ID_disco = disco_id;

    -- Se ci sono doppioni, elimina prima i doppioni e poi il disco
    IF doppioni_count > 0 THEN
        -- Elimina i doppioni collegati al disco
        DELETE FROM doppione
        WHERE ID_disco = disco_id;

        -- Elimina il disco
        DELETE FROM disco
        WHERE ID = disco_id;
        
        SELECT CONCAT('Disco con ID ', disco_id, ' eliminato insieme ai suoi doppioni.') AS Message;
    ELSE
        -- Se non ci sono doppioni, elimina solo il disco
        DELETE FROM disco
        WHERE ID = disco_id;
        
        SELECT CONCAT('Disco con ID ', disco_id, ' eliminato.') AS Message;
    END IF;
END $$


-- Trigger inserimento di tracce
CREATE TRIGGER inserisci_durata_totale
AFTER INSERT ON traccia
FOR EACH ROW BEGIN
CALL calcola_durata_totale(NEW.ID_disco);
END$$

<<<<<<< HEAD

-- Trigger inserimento di tracce
=======
-- Trigger aggiornamento di tracce
>>>>>>> 48672271f6b3749ebb0853e1977d64405ff4836d
CREATE TRIGGER aggiorna_durata_totale
AFTER UPDATE ON traccia
FOR EACH ROW BEGIN
CALL calcola_durata_totale(NEW.ID_disco);
END$$

<<<<<<< HEAD

-- Trigger per il controllo dell'anno
=======
-- Trigger per il controllo dell'anno quando viene inserito
>>>>>>> 48672271f6b3749ebb0853e1977d64405ff4836d
CREATE TRIGGER controllo_anno1
BEFORE INSERT ON disco
FOR EACH ROW BEGIN
CALL verifica_anno(NEW.anno_uscita);
END$$

<<<<<<< HEAD
=======
-- Trigger per il controllo dell'anno quando viene aggiornato
>>>>>>> 48672271f6b3749ebb0853e1977d64405ff4836d
CREATE TRIGGER controllo_anno2
BEFORE UPDATE ON disco
FOR EACH ROW BEGIN
IF NEW.anno_uscita != OLD.anno_uscita THEN
CALL verifica_anno(NEW.anno_uscita);
END IF;
END$$



    
    