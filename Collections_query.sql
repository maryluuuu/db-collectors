CREATE TRIGGER controllo_anno
BEFORE INSERT ON la_tua_tabella
FOR EACH ROW
BEGIN
    IF NEW.anno <> YEAR(CURDATE()) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "L'anno deve essere compreso tra il 1900 e l'anno corrente";
    END IF;
END;

CREATE TRIGGER controllo_anno
BEFORE INSERT ON la_tua_tabella
FOR EACH ROW
BEGIN
    IF NEW.anno <> YEAR(CURDATE()) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L''anno deve essere corrente.';
    END IF;
END;