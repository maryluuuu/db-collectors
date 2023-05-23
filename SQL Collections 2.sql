drop database if exists progettoLab;
create database progettoLab;
use progettoLab;

drop table if exists collezionista;
drop table if exists collezione;
drop table if exists condivisa;
drop table if exists possiede;
drop table if exists genere;
drop table if exists autore;
drop table if exists traccia;
drop table if exists formato;
drop table if exists condizione;
drop table if exists codice;
drop table if exists etichetta;
drop table if exists disco;
drop table if exists conservazione;
drop table if exists diventa;
drop table if exists immagine;
drop table if exists scritta;
drop table if exists composto;
drop table if exists contiene;
drop table if exists raccolta;
drop table if exists dispone;
drop table if exists produce;

-- Tabella collezionista
create table collezionista(
	ID integer unsigned auto_increment primary key,
	nickname varchar(60) not null,
    email varchar(100) not null,
    constraint collezionista_distinto unique (nickname, email)
);

-- Tabella collezione
create table collezione(
	ID integer unsigned auto_increment primary key,
    nome varchar(80) not null,
    flag varchar(12) not null,
    ID_collezionista integer unsigned not null,
    
    constraint check_share check (flag in ('pubblico', 'privato')),
		-- flag può essere pubblico o privato
    
	constraint collezione_collezionista foreign key (ID_collezionista) 
		references collezionista(ID) on delete cascade on update cascade,
			-- cascade, perchè se cancelli un collezionista cancelli il riferimento
			-- alla collezione
        
    constraint nome_unica unique (ID_collezionista, nome)
    );

-- Tabella autore
create table autore(
	ID integer unsigned auto_increment primary key,
	nome varchar(80) not null,
    IPI varchar(12) unique not null 
);

-- Tabella traccia
create table traccia(
	ID integer unsigned auto_increment primary key,
    titolo varchar(180) not null,
    durata integer unsigned not null,
	ISRC varchar(12) unique not null
);
    
-- Tabella etichetta    
create table etichetta(
	ID integer unsigned auto_increment primary key,
    nome varchar(200) unique not null
    );

-- Tabella formato
create table formato(
	ID integer unsigned auto_increment primary key,
    nome varchar(20) not null,
    
    constraint check_formato check (nome in ('digitale', 'cd', 'vinile'))
);

-- Tabella disco
create table disco(
	ID integer unsigned auto_increment primary key,
    titolo_disco varchar(180) not null,
	barcode integer unsigned unique, 
    anno_uscita smallint unsigned not null,
    ID_etichetta integer unsigned,
    genere varchar(50),
	-- forse sarebbe meglio mettere genere in una tabella e formato come attributo altrimenti viene un check lunghissimo
    -- constraint controllo_anno check (anno_uscita >= 1900 and anno_uscita <= year(curdate())),
		-- controlla se l'anno sta tra il 1900 e l'anno corrente
        -- va specificato nella query per l'insert
            
	foreign key (ID_etichetta) references etichetta(ID) on delete set null on update cascade
			-- # set null perchè una volta cancellata l'etichetta
            -- # il disco ancora esiste nonostante l'assenza
            -- # dell' etichetta
		
);

-- Tabella immagini
create table immagine(
	ID integer unsigned auto_increment primary key,
    tipo varchar(20) not null,
    path varchar(200) not null,
    ID_disco integer unsigned not null,
    
     constraint immagine_disco foreign key (ID_disco)
		references disco(ID) on delete restrict on update cascade
        -- restrict, cancella il disco se non sono presenti 
        -- più immagini
);

-- Tabella doppione
create table doppione(
	ID integer unsigned auto_increment primary key,
    id_disco_originale integer unsigned not null,
    condizione varchar(20),
    quantità integer unsigned not null,
    id_formato integer unsigned,
    
    foreign key (id_formato) references formato(ID) on delete set null on update cascade, -- non lo so
    foreign key (id_formato) references disco(ID) on delete cascade on update cascade
);

-- Tabella condivisione collezione e collezionista (n..n)
create table condivisa(
	ID_collezionista integer unsigned not null,
    ID_collezione integer unsigned not null,
    primary key (ID_collezionista, ID_collezione),
    
    constraint condivisa_collezionista foreign key (ID_collezionista)
		references collezionista(ID) on delete cascade on update cascade,
			-- cascade perchè se viene cancellato un collezionista
            -- cancelli tutte le collezioni che sono state condivise
                
	constraint condivisa_collezione foreign key (ID_collezione)
		references collezione(ID) on delete cascade on update cascade
			-- cascade perchè se viene cancellata una collezione condivisa
            -- viene cancellata a tutti
    );

-- Tabella relazione autore e disco (n..n)		
create table scritta(
	ID_disco  integer unsigned not null,
    ID_autore integer unsigned not null,
    primary key(ID_traccia, ID_autore),
    
    foreign key (ID_disco) references disco(ID) on delete cascade on update cascade,
			-- cascade, perchè se cancelli una traccia cancelli tutte le righe nella tabella scritta riferite alla traccia
        
	foreign key (ID_autore)	references autore(ID) on delete cascade on update cascade
			-- cascade, perchè cancellando un autore cancelli tutte le sue righe nella tabella scritta
);

create table composto(
	ID_disco integer unsigned not null, 
    ID_autore integer unsigned not null,
    primary key (ID_disco, ID_autore),
    
    constraint composto_disco foreign key (ID_disco)
		references disco(ID) on delete restrict on update cascade,
        -- restrict perchè il disco viene cancellato se non è composto
        -- da nessun autore
			-- # non sono sicuro
    constraint composto_autore foreign key (ID_autore)
		references autore(ID) on delete cascade on update cascade
        -- cascade perchè cancelli tutti i dischi legati a
        -- quell' autore 
			-- # non sono sicuro
);

-- Tabella relazione disco e tracce (n..n)
create table contiene (
    ID_disco integer unsigned not null,
    ID_traccia integer unsigned not null,
    primary key(ID_disco, ID_traccia),
    
    constraint contiene_disco foreign key (ID_disco) 
		references disco(ID) on delete restrict on update cascade,
        -- quando le tracce non sono più contenute in nessun disco vengono eliminate
    constraint contiene_traccia foreign key (ID_traccia) 
		references traccia(ID) on delete cascade on update cascade
        -- cascade se cancelli la traccia cancelli pure i dischi
        -- associati ad essi
);

-- Tabella relazione tra doppione e collezione (n..n)
create table raccolta(
	ID_disco integer unsigned not null,
    ID_collezione integer unsigned not null,
    primary key(ID_disco, ID_collezione),
    
    constraint raccolta_disco foreign key (ID_disco)
		references disco(ID) on delete cascade on update cascade,
        -- cascade, il disco viene cancellato dalla collezione
			-- # non sono sicuro
        
    constraint raccolta_collezione foreign key (ID_collezione)
		references collezione(ID) on delete restrict on update cascade
        -- restrict, la collezione viene cancellata se vengono
        -- cancellati tutti i dischi
			-- # non sono sicuro
);
    


    