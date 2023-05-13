drop database if exists progettoLab;
create database progettoLab;
use progettoLab;

drop table if exists collezionista;
create table collezionista (
	ID integer unsigned auto_increment primary key,
	nickname varchar(60) not null,
    email varchar(100) not null,
    constraint collezionista_distinto UNIQUE (nickname, email)
);
 
 drop table if exists collezione;
create table collezione(
	ID integer unsigned auto_increment primary key,
    nome varchar(80) not null,
    flag varchar(12),
    collezionista_ID integer unsigned,
    constraint check_share check (flag in ('pubblico', 'privato')),
	constraint proprieta_collezione foreign key (collezionista_ID) 
		references collezionista(ID),
    constraint nome_unica unique (collezionista_ID, nome)
    );

drop table if exists condivisa;
create table condivisa(
	ID_collezionista integer unsigned not null,
    ID_collezione integer unsigned not null,
    constraint collezione_collezionista foreign key (ID_collezionista)
		references collezionista(ID) on delete cascade on update cascade, -- da rivedere
	constraint collezionista_collezione foreign key (ID_collezione)
		references collezione(ID) on delete restrict on update cascade -- da rivedere
    );
    
drop table if exists disco;
create table disco(
	ID_disco integer unsigned auto_increment primary key,
    titolo varchar(80) not null,
    quantita smallint unsigned not null,
    barcode mediumint unsigned
);

drop table if exists genere;
create table genere(
 ID_genere integer unsigned auto_increment primary key,
	nome varchar(80) not null 
 );
 
    

	