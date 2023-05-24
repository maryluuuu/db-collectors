drop database if exists progettoLab;
create database progettoLab;
use progettoLab;

drop table if exists collezionista; --
drop table if exists collezione; --
drop table if exists condivisa; --
drop table if exists possiede; --
drop table if exists genere; --
drop table if exists autore; --
drop table if exists traccia; --
drop table if exists etichetta; --
drop table if exists disco; -- #DUBBIO
drop table if exists scritta; -- #DUBBIO
drop table if exists immagine; --
drop table if exists composto; -- #DUBBIO
drop table if exists contiene; -- #DUBBIO
drop table if exists raccolta; --
drop table if exists dispone; --
drop table if exists doppioni; --


create table collezionista(
	ID integer unsigned auto_increment primary key,
	nickname varchar(60) not null,
    email varchar(100) not null,
    constraint collezionista_distinto unique (nickname, email)
);

 
create table collezione(
	ID integer unsigned auto_increment primary key,
    nome varchar(80) not null,
    flag varchar(12) not null,
    ID_collezionista integer unsigned,
    
    constraint check_share check (flag in ('pubblico', 'privato')),
		-- flag può essere pubblico o privato
    
	constraint collezione_collezionista foreign key (ID_collezionista) 
		references collezionista(ID) on delete cascade on update cascade,
			-- cascade, perchè se cancelli un collezionista cancelli il riferimento
			-- alla collezione
        
    constraint nome_unica unique (ID_collezionista, nome)
    );
    
    
create table condivisa(
	ID_collezionista integer unsigned not null,
    ID_collezione integer unsigned not null,
    primary key (ID_collezionista, ID_collezione),
    
    constraint condivisa_collezionista foreign key (ID_collezionista)
		references collezionista(ID) on delete cascade on update cascade,
			-- cascade perchè se viene cancellato un collezionista
            -- cancelli tutte le collezioni che sono state condivise da lui
                
	constraint condivisa_collezione foreign key (ID_collezione)
		references collezione(ID) on delete cascade on update cascade
			-- cascade perchè se viene cancellata una collezione condivisa
            -- viene cancellata
    );


create table possiede(
	ID_collezionista integer unsigned not null,
    ID_collezione integer unsigned not null,
    primary key(ID_collezionista, ID_collezione),
    
    constraint possiede_collezionista foreign key (ID_collezionista)
		references collezionista(ID) on delete cascade on update cascade,
			-- cascade perchè se viene cancellato un collezionista
            -- cancelli tutte le collezioni che possiede
            
	constraint possiede_collezione foreign key (ID_collezione)
		references collezione(ID) on delete cascade on update cascade
			-- cascade cancelli una collezione che possiedi e tutti i dischi allegati
            -- ad essa
    );


create table genere(
	ID integer unsigned auto_increment primary key,
    nome varchar(80) not null
);


create table autore(
	ID integer unsigned auto_increment primary key,
	nome varchar(80),
    cognome varchar(100) default 'Sconosciuto', 
    IPI integer unsigned unique not null
    
    -- no inserimento constraint essendo che un autore può
    -- avere lo stesso nome e cognome di un altro autore
);


create table traccia(
	ID integer unsigned auto_increment primary key,
    titolo varchar(180) unique not null,
    durata integer unsigned not null
);
    
create table etichetta(
	ID integer unsigned auto_increment primary key,
    nome varchar(200) not null
    );
    
create table disco(
	ID integer unsigned auto_increment primary key,
    titolo_disco varchar(180) not null,
    anno_uscita smallint unsigned not null,
    barcode integer unsigned,
    ID_etichetta integer unsigned not null,
    ID_genere integer unsigned not null,
    
    constraint controllo_anno check (anno_uscita > 1900 and anno_uscita < year(now())),
		-- controlla se l'anno sta tra il 1900 e l'anno corrente
			-- # non sono sicuro se questo me lo confronta con l'anno
			-- # corrente
            
	constraint disco_etichetta foreign key (ID_etichetta)
		references etichetta(ID) on delete set null on update cascade,
			-- set null perchè una volta cancellata l'etichetta
            -- il disco ancora esiste nonostante l'assenza
            -- dell' etichetta
                
	constraint disco_genere foreign key (ID_genere)
		references genere(ID) on delete restrict on update cascade
			-- # cancella il genere se non c'è nessun disco che lo appartenga

);

create table scritta(
	ID_traccia  integer unsigned not null,
    ID_autore integer unsigned not null,
    primary key(ID_traccia, ID_autore),
    
    constraint scritta_traccia foreign key (ID_traccia)
		references traccia(ID) on delete cascade on update cascade,
			-- cascade, perchè se cancelli la traccia cancelli
            -- anche l'autore legato a quella traccia
        
	constraint scritta_autore foreign key (ID_autore)
		references autore(ID) on delete set null on update cascade
			-- # set null, perchè cancellando l'autore non cancelli
            -- # le traccie legate ad esso ma semplicemente ometti
            -- # l'autore
);

create table immagine(
	ID integer unsigned auto_increment primary key,
    tipo varchar(200) not null,
    ID_disco integer unsigned not null,
    
     constraint immagine_disco foreign key (ID_disco)
		references disco(ID) on delete restrict on update cascade
        -- restrict, cancella il disco se non sono presenti 
        -- più immagini
);
    

create table composto(
	ID_disco integer unsigned not null, 
    ID_autore integer unsigned not null,
    primary key (ID_disco, ID_autore),
    
    constraint composto_disco foreign key (ID_disco)
		references disco(ID) on delete cascade on update cascade,
        -- # cascade perchè se il disco viene cancellato anche
        -- # l'autore viene cancellato
        
    constraint composto_autore foreign key (ID_autore)
		references autore(ID) on delete cascade on update cascade
        -- cascade perchè cancelli tutti i dischi legati a
        -- quell' autore 
);

CREATE TABLE contiene (
    ID_disco integer unsigned not null,
    ID_traccia integer unsigned not null,
    primary key(ID_disco, ID_traccia),
    
    constraint contiene_disco foreign key (ID_disco) 
		references disco(ID) on delete cascade on update cascade,
        -- cascade se cancelli il disco cancelli pure le traccie
        -- associate
    constraint contiene_traccia foreign key (ID_traccia) 
		references traccia(ID) on delete cascade on update cascade
        -- # cascade se cancelli la traccia cancelli pure i dischi
        -- # associati ad essi
			-- # non sono sicuro se mettere restrict
);

create table raccolta(
	ID_disco integer unsigned not null,
    ID_collezione integer unsigned not null,
    primary key(ID_disco, ID_collezione),
    
    constraint raccolta_disco foreign key (ID_disco)
		references disco(ID) on delete cascade on update cascade,
        -- cascade, il disco viene cancellato dalla collezione
        
    constraint raccolta_collezione foreign key (ID_collezione)
		references collezione(ID) on delete cascade on update cascade
        -- cascade, la collezione viene cancellata con tutti 
        -- i dischi
);

create table dispone(
	ID_collezionista integer unsigned not null,
    quantita integer unsigned default 1,
    primary key(ID_collezionista, ID_disco),
    
    constraint dispone_collezionista foreign key (ID_collezionista)
		references collezionista(ID) on delete cascade on update cascade
        -- cascade, se cancelli il collezionista cancelli pure i 
        -- suoi doppioni
);

create table doppione(
	ID integer unsigned primary key,
    quantita integer unsigned not null,
    ID_disco integer unsigned not null,
    ID_collezionista integer unsigned not null,
    
    constraint doppione_disco foreign key (ID_disco)
		references disco(ID) on delete restrict on update cascade,
        -- restrict, cancella disco se non hai doppioni
        
	constraint doppione_collezionista foreign key (ID_collezionista)
		references collezionista(ID) on delete cascade on update cascade
		-- cascade, cancellato il collezionista cancelli anche
        -- i doppioni
);
    
    

	
	








    