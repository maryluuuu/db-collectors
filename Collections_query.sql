use progettolab;

-- Elimina le procedure esistenti
DROP PROCEDURE IF EXISTS calcola_durata_totale;
DROP PROCEDURE IF EXISTS verifica_anno;

-- Elimina i trigger esistenti
DROP TRIGGER IF EXISTS controllo_anno;
DROP TRIGGER IF EXISTS aggiorna_durata_totale;
DROP TRIGGER IF EXISTS inserisci_durata_totale;

DELIMITER $$

-- Procedura verifica anno_uscita di disco
CREATE PROCEDURE verifica_anno(id_disco integer unsigned)
BEGIN
    IF NEW.anno_uscita < 1900 OR NEW.anno_uscita > year(curdate()) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Anno non valido';
    END IF;
END$$

-- Procedura calcolo durata_totale disco
CREATE PROCEDURE calcola_durata_totale(id_disco integer unsigned) 
READS SQL DATA -- registrazione binaria
BEGIN
	DECLARE total INTEGER;
    
    SELECT SUM(durata) INTO total
    FROM traccia
    WHERE ID_disco = id_disco;
    
    UPDATE disco
    SET durata_totale = total
    WHERE ID_disco = id_disco;
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
FOR EACH ROW
CALL calcola_durata_totale();

-- Trigger inserimento di tracce
CREATE TRIGGER aggiorna_durata_totale
AFTER UPDATE ON traccia
FOR EACH ROW
CALL calcola_durata_totale();

-- Trigger per il controllo dell'anno
CREATE TRIGGER controllo_anno
BEFORE INSERT ON disco
FOR EACH ROW
CALL verifica_anno();

DELIMITER $$
CREATE TRIGGER controllo_anno
BEFORE UPDATE ON disco
FOR EACH ROW
CALL verifica_anno();



    
    