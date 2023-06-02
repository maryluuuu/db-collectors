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

/*
-- Procedura per il calcolo della quantità di un doppione
-- si può togliere perchè ho vincolato l'inserimento però non lo so non sono sicura
CREATE PROCEDURE calcola_quantita_totale(disco_id INT, condizione VARCHAR(20), formato varchar(20))
BEGIN
    DECLARE quantita_totale INT;
    
    SELECT SUM(quantita) INTO quantita_totale
    FROM doppione
    WHERE disco_id = disco_id AND condizione = condizione AND formato=formato;
    SET quantita = quantita_totale;
END$$
*/

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
/*
CREATE TRIGGER controllo_anno2
BEFORE UPDATE ON disco
FOR EACH ROW BEGIN
IF NEW.anno_uscita != OLD.anno_uscita THEN
CALL verifica_anno(NEW.anno_uscita);
END IF;
END$$



    
    