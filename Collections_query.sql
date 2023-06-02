use progettolab;

-- Elimina le procedure esistenti
DROP PROCEDURE IF EXISTS calcola_durata_totale;

-- Elimina i trigger esistenti
DROP TRIGGER IF EXISTS controllo_anno;
DROP TRIGGER IF EXISTS aggiorna_durata_totale;


-- Trigger per il controllo dell'anno
DELIMITER $$
CREATE TRIGGER controllo_anno
BEFORE INSERT ON disco
FOR EACH ROW
BEGIN
    IF NEW.anno_uscita < 1900 OR NEW.anno_uscita > year(curdate()) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Anno non valido';
    END IF;
END$$

-- Funzione calcolo durata album
CREATE PROCEDURE calcola_durata_totale(id_disco integer) 
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
    

CREATE TRIGGER aggiorna_durata_totale
AFTER INSERT ON traccia
FOR EACH ROW
CALL calcola_durata_totale();



    
    