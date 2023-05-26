-- selezioniamo il database di default
use progettolab;

-- svuotiamo le tabelle
delete from collezionista;
delete from autore;
delete from etichetta;
delete from genere;
delete from disco;

insert into collezionista values
(1,'alice', 'alice.lyndon@mail.it'),
(2,'bob','bob.evans@mail.it'),
(3,'tyler','tyler.lynch@mail.it');

insert into autore values
(1,'Red Hot Chili Peppers','I-000000229-7'),
(2,'Pink Floyd','I-000000485-3'),
(3,'Led Zeppelin','I-000000485-3'),
(4,'The Beatles','I-000000790-6');

insert into etichetta values
(1,'Sony Music');

insert into genere values
(1,'Progressive Rock'),
(2,'Art Rock'),
(3,'Progressive Pop');

insert into disco values
(1,'The Wall',8032089000012,1979,1,1,2);





