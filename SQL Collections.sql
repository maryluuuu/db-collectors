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
	constraint proprietà_collezione foreign key (collezionista_ID) 
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

drop table if exists genere;
create table genere(
	id_genere integer unsigned auto_increment primary key,
    nome varchar(80) not null
);

drop table if exists autore;
create table autore(
	id_autore integer unsigned auto_increment primary key,
	nome varchar(80) not null,
    ipi integer unsigned 
);

drop table if exists traccia;
create table traccia(
	id_genere integer unsigned auto_increment primary key,
    titolo varchar(180) not null,
    durata integer unsigned not null
);
    
drop table if exists disco;
create table disco(
	id_disco integer unsigned auto_increment primary key,
    titolo varchar(180) not null,
    barcode integer unsigned,
    anno smallint unsigned not null,
    genere_id integer unsigned, -- specificare se può essere nullo o no
    autore_id integer unsigned, -- specificare se può essere nullo o no
    constraint controllo_anno check (anno>1900 and anno<2500),
	foreign key (genere_id)
		references genere(id_genere) on delete cascade on update cascade, -- da rivedere
	foreign key (autore_id)
		references autore(id_autore) 
);

drop table if exists disco_genere;
create table disco_genere( -- ci va la primary key?
	id_disco integer unsigned, 
    id_genere integer unsigned,
    foreign key (id_disco)
		references disco(id_disco) on delete cascade on update cascade,
    foreign key (id_genere)
		references genere(id_genere) on delete cascade on update cascade
);

drop table if exists disco_autore;
create table disco_autore( -- ci va la primary key?
	id_disco integer unsigned, 
    id_autore integer unsigned,
    foreign key (id_disco)
		references disco(id_disco) on delete cascade on update cascade,
    foreign key (id_autore)
		references autore(id_autore) on delete cascade on update cascade
);

drop table if exists disco_traccia;
CREATE TABLE disco_traccia ( -- ci va la parimary key?
    disco_id INTEGER UNSIGNED,
    traccia_id INTEGER UNSIGNED,
    foreign key (disco_id) references disco(id_disco) on delete cascade on update cascade,
    foreign key (traccia_id) references traccia(id_traccia) on delete cascade on update cascade
);

drop table if exists disco_collezione;
create table disco_collezione( -- ci va la primary key?
	disco_id integer unsigned ,
    collezione_id integer unsigned,
    foreign key (disco_id) references disco(id_disco) on delete cascade on update cascade,
    foreign key (collezione_id) references collezione(ID) on delete cascade on update cascade
);
    
    

	
	








    