use progettolab;

DELIMITER //
CREATE TRIGGER controllo_anno
BEFORE INSERT ON disco
FOR EACH ROW
BEGIN
    IF NEW.anno < 1900 OR NEW.anno > year(curdate()) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Anno non valido';
    END IF;
END//

DELIMITER ;



    
    