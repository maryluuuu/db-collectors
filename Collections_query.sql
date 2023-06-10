use progettolab;

-- Elimina le procedure esistenti
DROP PROCEDURE IF EXISTS calcola_durata_totale;
DROP PROCEDURE IF EXISTS verifica_anno;
DROP PROCEDURE IF EXISTS eliminazione_da_collezione;
DROP PROCEDURE IF EXISTS cancellazione_collezione;
DROP PROCEDURE IF EXISTS elimina_disco;

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
CREATE PROCEDURE calcola_durata_totale(id_procedura INTEGER UNSIGNED) 
READS SQL DATA
BEGIN
    UPDATE disco
	SET durata_totale = (
    SELECT SUM(durata)
    FROM traccia
    WHERE ID_disco = id_procedura
)
WHERE ID = id_procedura;
END$$



CREATE PROCEDURE eliminazione_da_collezione(id_disco integer unsigned, id_collezionista integer unsigned)
READS SQL DATA -- registrazione binaria
BEGIN
    
    SELECT ID
    FROM doppione
    WHERE ID_disco = id_disco and ID_collezionista = id_collezionista ;
    
END$$

/*	#commentato perchè è da rivedere, ps: la run funziona anche senza questa procedura
-- Procedura di cancellazione di un disco di un collezionista
	-- #non sono sicuro della creazione della procedura
CREATE PROCEDURE cancellazione_collezione(id_collezione integer unsigned, id_collezionista integer unsigned)
READS SQL DATA -- registrazione binaria
BEGIN
    
    SELECT ID
    FROM collezione
    WHERE ID = id_collezione and ID_collezionista = id_collezionista ;
    
END$$
*/

/* #commentato perchè è da rivedere, ps: la run funziona anche senza questo trigger
-- Trigger di cancellazione di una collezione di un collezionista
	-- #non sono sicuro sulla creazione del trigger
CREATE TRIGGER eliminazione_collezione
BEFORE DELETE ON collezione
FOR EACH ROW BEGIN
CALL cancellazione_collezione(OLD.ID, OLD.ID_collezionista);
END$$
*/


-- Eliminazione  dischi
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


/*
-- Trigger di cancellazione di un disco
CREATE TRIGGER eliminazione_disco
BEFORE DELETE ON doppione
FOR EACH ROW BEGIN
CALL eliminazione_da_collezione(OLD.ID_disco, OLD.ID_collezionista);
END$$
*/