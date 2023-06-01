use progettolab;

-- Elimina le funzioni esistenti
DROP FUNCTION IF EXISTS calcola_durata_totale;

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
drop function if exists calcola_durata_totale;
CREATE FUNCTION calcola_durata_totale() RETURNS integer
READS SQL DATA -- registrazione binaria: la funziona
BEGIN
  UPDATE disco
  SET durata_totale = (
    SELECT SUM(durata)
    FROM tracce
    WHERE id_disco = NEW.id_disco
  )
  WHERE id_disco = NEW.id_disco;
  RETURN NEW;
END;

CREATE TRIGGER aggiorna_durata_totale
AFTER INSERT ON tracce
FOR EACH ROW
EXECUTE FUNCTION calcola_durata_totale();



    
    