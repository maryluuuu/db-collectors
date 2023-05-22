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

-- Tabella formato
create table formato(
	ID integer unsigned auto_increment primary key,
	nome varchar(110) not null
    );
    
-- Tabella etichetta    
create table etichetta(
	ID integer unsigned auto_increment primary key,
    nome varchar(200) unique not null
    );
    
create table formato(
	ID integer unsigned auto_increment primary key,
    nome varchar(20) not null,
    
    constraint check_share check (nome in ('digitale', 'cd', 'vinile'))
    -- la clausola check garantisce che non ci siano duplicati
);

-- Tabella disco
create table disco(
	ID integer unsigned auto_increment primary key,
    titolo_disco varchar(180) not null,
	barcode integer unsigned unique, 
    anno_uscita smallint unsigned not null,
    ID_etichetta integer unsigned not null,
    genere varchar(50),

    constraint controllo_anno check (anno_uscita >= 1900 and anno_uscita <= year(curdate())),
		-- controlla se l'anno sta tra il 1900 e l'anno corrente
            
	foreign key (ID_etichetta) references etichetta(ID) on delete set null on update cascade,
			-- # set null perchè una volta cancellata l'etichetta
            -- # il disco ancora esiste nonostante l'assenza
            -- # dell' etichetta
                
	foreign key (ID_genere) references genere(ID) on delete restrict on update cascade
        -- cancella il genere se non c'è nessun disco che lo appartenga
		-- forse sarebbe meglio mettere genere in una tabella e formato come attributo
);

create table doppione(
	ID integer unsigned auto_increment primary key,
    id_disco_originale integer unsigned not null,
    condizione varchar(20),
    quantità integer unsigned not null,
    id_formato integer unsigned,
    
    foreign key (id_formato) references formato(ID) on delete set null on update cascade,
    foreign key (id_formato) references disco(ID) on delete cascade on update cascade
);

-- Tabella condivisione collezione e collezionista
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

-- Tabella collezionista_collezione
create table gestisce(
	ID_collezionista integer unsigned not null,
    ID_collezione integer unsigned not null,
    primary key(ID_collezionista, ID_collezione),
    
    constraint possiede_collezionista foreign key (ID_collezionista)
		references collezionista(ID) on delete cascade on update cascade,
			-- cascade perchè se viene cancellato un collezionista
            -- cancelli tutte le collezioni che possiede
            
	constraint possiede_collezione foreign key (ID_collezione)
		references collezione(ID) on delete restrict on update cascade
			-- restrict cancelli una collezione se non è condivisa da nessuno
				-- # non sono sicuro se mettere una delete cascade
    );


create table conservazione(
	ID_disco integer unsigned not null,
    ID_condizione integer unsigned not null,
    primary key (ID_disco, ID_condizione),
    
    constraint conservazione_disco foreign key (ID_disco)
		references disco (ID) on delete restrict on update cascade,
			-- restrict cancello il disco se non è presente in quello
            -- stato di condizione
				-- # non sono sicuro
            
	constraint conservazione_condizione foreign key (ID_condizione)
		references condizione (ID) on delete restrict on update cascade
			-- restrict cancello il disco se non è presente in quello
            -- stato di condizione
				-- # non sono sicuro
);


create table diventa(
	ID_disco integer unsigned not null, 
    ID_formato integer unsigned not null,
    primary key(ID_disco, ID_formato),
    
	constraint diventa_disco foreign key (ID_disco)
		references disco(ID) on delete restrict on update cascade,
			-- restrict perchè il disco viene cancellato se non è di
			-- nessun formato
				-- # non sono sicuro
                
	constraint diventa_formato foreign key (ID_formato)
		references formato(ID) on delete restrict on update cascade
			-- restrict perchè il formato viene cancellato se non è di
			-- nessun disco
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
		references autore(ID) on delete cascade on update cascade
			-- cascade, perchè cancellando l'autore cancelli pure
            -- le traccie legate ad esso
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
        -- cascade se cancelli la traccia cancelli pure i dischi
        -- associati ad essi
);

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

create table dispone(
	ID_collezionista integer unsigned not null,
    ID_disco integer unsigned not null,
    quantita integer unsigned default 1,
    primary key(ID_collezionista, ID_disco),
    
    constraint dispone_collezionista foreign key (ID_collezionista)
		references collezionista(ID) on delete cascade on update cascade
        -- cascade, se cancelli il collezionista cancelli pure i 
        -- suoi doppioni
);
    
    

	
	








    