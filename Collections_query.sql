use progettolab;

-- Elimina le procedure esistenti
DROP PROCEDURE IF EXISTS calcola_durata_totale;
DROP PROCEDURE IF EXISTS verifica_anno;

-- Elimina i trigger esistenti
DROP TRIGGER IF EXISTS controllo_anno1;
DROP TRIGGER IF EXISTS controllo_anno2;
DROP TRIGGER IF EXISTS inserisci_durata_totale;
DROP TRIGGER IF EXISTS aggiorna_durata_totale;

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

-- Eliminazione dischi
CREATE PROCEDURE elimina_disco(disco_id integer unsigned)
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


-- Trigger inserimento di tracce
CREATE TRIGGER aggiorna_durata_totale
AFTER UPDATE ON traccia
FOR EACH ROW BEGIN
CALL calcola_durata_totale(NEW.ID_disco);
END$$


-- Trigger per il controllo dell'anno
CREATE TRIGGER controllo_anno1
BEFORE INSERT ON disco
FOR EACH ROW BEGIN
CALL verifica_anno(NEW.anno_uscita);
END$$

CREATE TRIGGER controllo_anno2
BEFORE UPDATE ON disco
FOR EACH ROW BEGIN
IF NEW.anno_uscita != OLD.anno_uscita THEN
CALL verifica_anno(NEW.anno_uscita);
END IF;
END$$



    
    