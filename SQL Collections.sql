drop database if exists progettoLab;
create database progettoLab;
use progettoLab;
create table collezionista (
	ID integer unsigned auto_increment primary key,
	nickname varchar(60) not null,
    email varchar(100) not null,
    constraint collezionista_distinto UNIQUE (nickname, email)
);
 
create table collezione(
	ID integer unsigned auto_increment primary key,
    nome varchar(80) not null,
    flag varchar(12),
    constraint check_share check (flag in ('pubblico', 'privato'))
    );
    
create table condivisa(
	ID_collezionista integer unsigned not null,
    ID_collezione integer unsigned not null,
    constraint collezione_collezionista foreign key (ID_collezionista)
    references collezionista(ID) on delete cascade on update cascade, -- da rivedere
	constraint collezionista_collezione foreign key (ID_collezione)
    references collezione(ID) on delete restrict on update cascade -- da rivedere
    )

	
	








    