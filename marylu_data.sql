-- selezioniamo il database di default
use progettolab;

-- svuotiamo le tabelle
delete from `collezionista`;
delete from `collezione`;
delete from `genere`;
delete from `etichetta`;
delete from `disco`;
delete from `traccia`;
delete from `autore`;
delete from `doppione`;


insert into `collezionista` values
(1,'alice', 'alice.lyndon@mail.it'),
(2,'bob','bob.evans@mail.it'),
(3,'tyler','tyler.lynch@mail.it');

-- Inserimento di una nuova collezione
insert into `collezione`(ID, nome, flag, ID_collezionista) values
(1, 'I miei preferiti', 'privata', 2),
(2, 'Pink Floyd music', 'pubblica', 2),
(3, 'I miei preferiti', 'privata', 3),
(4, 'I miei preferiti', 'pubblica', 1);


insert into `genere` values
(1,'Progressive Rock'),
(2,'Art Rock'),
(3,'Progressive Pop'),
(4, 'Rock and roll'),
(5, 'Sunshine Pop');


insert into `etichetta` values
(1, 'Sony Music Entertainment'),
(2, 'Universal Music Group'),
(3, 'Warner-Elektra-Atlantic'),
(4, 'Capitol Records');

-- Aggiunta di dischi a una collezione.
insert into `disco`(ID, titolo_disco, anno_uscita, barcode, ID_etichetta, ID_genere) values
-- disco 'The Wall' del 1979, barcode 0000000012, durata tot(Mother + Stop + Young Lust),
-- della Sony Music Entertainment, genere Progressive Rock,
-- della collezione 'Pink Floyd Music' di bob
(1,'The Wall',1979,0000000012, 1, 1),


-- disco 'The Dark Side of the Moon' del 1973, non esiste barcode, durata tot(Eclipse + Us and Them),
-- della Warner-Elektra-Atlantic, genere Progressive Pop,
-- della collezione 'Pink Floyd Music' di bob
(2, 'The Dark Side of the Moon', 1973, null, 1, 3),


-- disco 'Abbey Road' del 1969, non esiste barcode, durata tot(Come Together),
-- della Sony Music Entertainment, genere Art Rock,
-- della collezione 'I miei preferiti' di alice
(3, 'Abbey Road', 1969, null, 2, 2),
-- select sum(durata) from traccia where id_disco=3 ho tolto questa riga di codice perchè l'entità disco viene creata prima di traccia
-- quando viene creato il disco non ci sono tracce associate quindi la durata di default è null.
-- Durante l'inserimento delle tracce interviene il trigger

-- disco 'The Wall' del 1979, barcode 0000000013, durata tot(Mother + Stop + Young Lust),
-- della Sony Music Entertainment, genere Progressive Rock,
-- della collezione 'I miei preferiti' di alice
(4, "Sgt. Pepper's Lonely Hearts Club Band ", 1967, 0000000015, 4, 4),


-- disco 'Abbey Road' del 1969, non esiste barctracciaode, durata tot(Come Together),
-- della Sony Music Entertainment, genere Art Rock,
-- della collezione 'I miei preferiti' di bob
(5, 'Pet Sounds', 1966, 0000000018, 4, 5);

-- Aggiunta di tracce a un disco.
insert into `traccia`(ID, titolo, durata,ID_disco) values
-- tracce del disco The Wall
(1, 'Mother', 334, 1),
(2, 'Stop', 31, 1),
(3, 'Young Lust', 331, 1),
-- tracce del disco The Dark Side of the Moon
(4, 'Eclipse', 121, 4),
(5, 'Us and Them', 470, 4),
-- tracce del disco Abbey Road
(6, 'Come Together', 260, 3),
(7, 'Here Comes The Sun', 216, 3),
-- tracce del disco Pet Sound
(8, "Wouldn't It Be Nice", 142, 5),
(9, "Caroline, No", 172,5);


insert into `autore` (ID, nome, IPI) values
(1,'Pink Floyd', 0000004853),
(2,'The Beatles', 0000007906),
(3, 'The Beach Boys',0000003897);


insert into `doppione` values
(1, 4, 'CD', 'buona', 1, 1),				-- collezionista 1 (alice) ha 2 CD in buona condizione di 'The Wall'
(1, 2, 'CD', 'buona', 1, 1),				-- collezionista 1 (alice) ha 2 CD in buona condizione di 'The Wall'
(2, 5, 'vinile', 'pessima', 2, 1), 			-- collezionista 1 (alice) ha 5 vinili in pessima condizione di 'The Dark Side of the Moon'
(3, 1, 'musicassetta', 'perfetta', 3, 3),	-- collezionista 3 (tyler) ha 1 musicassetta in perfetta condizione di 'Abbey Road'
(4, 3, 'vinile', 'brutta', 3, 3) 			-- collezionista 3 (tyler) ha 3 vinili in brutta condizione di 'Abbey Road'
ON DUPLICATE KEY UPDATE quantita = quantita + VALUES(quantita); -- vincolo di aggiornamento quantità nel caso di disco già esistente

-- Aggiunta di nuove condivisioni a una collezione.
insert into `condivisa`(ID_collezionista, ID_collezione) values 
(1,1), (1,3);

-- Cancellazione collezione
delete from collezione where ID = 2;

-- Cancellazione genere
delete from genere where ID = 1; 

-- Aggiunta di dischi a una collezione
insert into `collezioni_dischi`(ID_collezione, ID_disco) values
(3,4), (3,3), (1,3), (1,4), (4,5), (4,1), (4,3);


-- Inserimento nella tabella composto
insert into `composto`(ID_disco, ID_autore, ruolo) values
(1,1,'compositore ed esecutore'),
(2,1,'compositore ed esecutore'),
(3,2,'compositore ed esecutore'),
(4,2,'compositore ed esecutore'),
(5,3,'compositore ed esecutore');

insert into `scritta`(ID_traccia, ID_autore) values
(1,1), (2,1), (3,1), (4,1), (5,1), (6,2), (7,2), (8,3), (9,3);


