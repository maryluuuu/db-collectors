-- selezioniamo il database di default
use progettolab;

-- svuotiamo le tabelle
delete from collezionista;
delete from collezione;
delete from genere;
delete from etichetta;
delete from disco; #non funziona durata totale
delete from traccia;
delete from autore;
delete from doppione;


insert into `collezionista` values
(1,'alice', 'alice.lyndon@mail.it'),
(2,'bob','bob.evans@mail.it'),
(3,'tyler','tyler.lynch@mail.it');


insert into `collezione` values
(1, 'I miei preferiti', 'privato', 2),
(2, 'Pink Floyd music', 'pubblico', 2),
(3, 'I miei preferiti', 'pubblico', 3);


insert into `genere` values
(1,'Progressive Rock'),
(2,'Art Rock'),
(3,'Progressive Pop');


insert into `etichetta` values
(1, 'Sony Music Entertainment'),
(2, 'Universal Music Group'),
(3, 'Warner-Elektra-Atlantic');


insert into `disco` values
-- disco 'The Wall' del 1979, barcode 0000000012, durata tot(Mother + Stop + Young Lust),
-- della Sony Music Entertainment, genere Progressive Rock,
-- della collezione 'Pink Floyd Music' di bob
(1,'The Wall',1979,0000000012, (select sum(durata) from `traccia` where ID_disco = 1), 1, 1, 2),


-- disco 'The Dark Side of the Moon' del 1973, non esiste barcode, durata tot(Eclipse + Us and Them),
-- della Warner-Elektra-Atlantic, genere Progressive Pop,
-- della collezione 'Pink Floyd Music' di bob
(2, 'The Dark Side of the Moon', 1973, null, (select sum(durata) from `traccia` where ID_disco = 2), 1, 3, 2),


-- disco 'Abbey Road' del 1969, non esiste barcode, durata tot(Come Together),
-- della Sony Music Entertainment, genere Art Rock,
-- della collezione 'I miei preferiti' di alice
(3, 'Abbey Road', 1969, null, (select sum(durata) from `traccia` where ID_disco = 3),2, 2, 1),


-- disco 'The Wall' del 1979, barcode 0000000012, durata tot(Mother + Stop + Young Lust),
-- della Sony Music Entertainment, genere Progressive Rock,
-- della collezione 'I miei preferiti' di alice
(4,'The Wall',1979,0000000012, (select sum(durata) from `traccia` where ID_disco = 1), 1, 1, 1),


-- disco 'Abbey Road' del 1969, non esiste barcode, durata tot(Come Together),
-- della Sony Music Entertainment, genere Art Rock,
-- della collezione 'I miei preferiti' di bob
(5, 'Abbey Road', 1969, null, (select sum(durata) from `traccia` where ID_disco = 3),2, 2, 3);


insert into `traccia` values
-- traccie del disco The Wall
(1, 'Mother', 334, 1),
(2, 'Stop', 31, 1),
(3, 'Young Lust', 331, 1),
-- traccie del disco The Dark Side of the Moon
(4, 'Eclipse', 121, 4),
(5, 'Us and Them', 470, 4), 
-- traccie del disco Abbey Road
(6, 'Come Together', 260, 3);


insert into `autore` (ID, nome, IPI) values
(1,'Pink Floyd', 0000004853),
(2,'The Beatles', 0000007906);


insert into `doppione` values
(1, 1, 2, 'CD', 'buona', 1, 1), 				-- collezionista 1 (alice) ha 2 CD in buona condizione di 'The Wall'
(2, 2, 5, 'vinile', 'pessima', 2, 1),			-- collezionista 1 (alice) ha 5 vinili in pessima condizione di 'The Dark Side of the Moon'
(3, 3, 1, 'musicassetta', 'perfetta', 3, 3),	-- collezionista 3 (tyler) ha 1 musicassetta in perfetta condizione di 'Abbey Road'
(4, 4, 3, 'vinile', 'brutta', 3, 3);			-- collezionista 3 (tyler) ha 3 vinili in brutta condizione di 'Abbey Road'