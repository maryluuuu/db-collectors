drop database if exists progettolab;
create database progettolab;
use progettolab;

drop table if exists collezionista;
drop table if exists collezione; -- X
drop table if exists genere; -- X
drop table if exists etichetta; -- X
drop table if exists disco; -- X #DUBBIO controllare!!!
drop table if exists traccia; -- X
drop table if exists autore; -- X
drop table if exists doppione; -- X
drop table if exists immagine; -- X
drop table if exists composto; -- X
drop table if exists raccolta;


DROP USER 'collezioneAdmin'@'localhost';
CREATE USER 'collezioneAdmin'@'localhost' IDENTIFIED BY 'randompassword';
GRANT ALL ON progettolab.* TO 'collezioneAdmin'@'localhost';

create table collezionista(
	ID integer unsigned auto_increment primary key,
	nickname varchar(60) not null,
    email varchar(100) not null,
    passkey varchar(50) not null,
    
    constraint collezionista_distinto unique (nickname)  
);
 
create table collezione(
	ID integer unsigned auto_increment primary key,
    nome varchar(80) not null,
    flag  boolean not null default 0, -- privata -> 0 pubblica -> 1
    ID_collezionista integer unsigned not null,
    
	constraint collezione_collezionista foreign key (ID_collezionista) 
		references collezionista(ID) on delete cascade on update cascade,
			-- cascade, perchè se cancelli un collezionista cancelli
            -- il riferimento alla collezione
        
    constraint nome_unica unique (ID_collezionista, nome)
);


create table genere(
	ID smallint unsigned auto_increment primary key,
    nome varchar(50) not null
);


create table etichetta(
	ID smallint unsigned auto_increment primary key,
    nome varchar(100) not null
);


create table disco(
	ID integer unsigned auto_increment primary key,
    titolo_disco varchar(100) not null,
    anno_uscita smallint unsigned not null,
    barcode bigint(13) unsigned unique,
    durata_totale time default 0, -- default null importante, così posso creare un disco anche se non ho ancora tracce associate
    ID_etichetta smallint unsigned,
    ID_genere smallint unsigned,
    -- unique (titolo,anno_uscita,ID_etichetta,ID_genere,), DA RIVEDERE
			
	constraint disco_etichetta foreign key (ID_etichetta)
		references etichetta(ID) on delete set null on update cascade,
			-- set null perchè una volta cancellata l'etichetta
            -- il disco ancora esiste nonostante l'assenza
            -- dell' etichetta
                
	constraint disco_genere foreign key (ID_genere)
		references genere(ID) on delete set null on update cascade
			-- cascade, cancella il genere se non c'è nessun disco
            -- che lo appartenga
);


create table traccia(
	ID integer unsigned auto_increment primary key,
    titolo varchar(100) unique not null,
    durata time not null,
    ID_disco integer unsigned not null,

    
    constraint traccia_disco foreign key (ID_disco)
		references disco(ID) on delete cascade on update cascade
			-- cascade, cancellato il disco cancelli la traccia

);

create table autore(
	ID integer unsigned auto_increment primary key,
	nome varchar(50),
    IPI integer unsigned unique not null
);
  

create table doppione(
	ID integer unsigned auto_increment primary key,
    quantita integer unsigned default 1,
    formato varchar(20) not null,
    condizione varchar(20) not null,
    ID_disco integer unsigned not null,
    ID_collezionista integer unsigned not null,
    unique (ID_disco,ID_collezionista,formato,condizione),
    constraint check_formato check (formato in ('CD', 'vinile', 'digitale', 'LP', 'musicassetta', 'Stereo8')),
		-- il disco può essere solo di questi formati
    
    constraint check_condizione check (condizione in ('perfetta', 'eccellente',
		'molto buona', 'buona', 'brutta', 'pessima' )),
			-- il disco può essere solo di queste condizioni
    
    constraint doppione_disco foreign key (ID_disco)
		references disco(ID) on delete restrict on update cascade,
			-- restrict, cancella disco se non hai doppioni
        
	constraint doppione_collezionista foreign key (ID_collezionista)
		references collezionista(ID) on delete cascade on update cascade
			-- cascade, cancellato il collezionista cancelli anche
			-- i doppioni
);


create table immagine(
	ID integer unsigned auto_increment primary key,
    percorso varchar(500) unique not null,
		-- percorso dove si trova il file dell'immagine
    tipo varchar(20) not null,
    ID_disco integer unsigned not null,
    
	constraint immagine_disco foreign key (ID_disco)
		references disco(ID) on delete cascade on update cascade
        -- posso eliminare un disco anche se ha delle immagini associate
        -- le immagini associate vengono eliminate quando vine eliminato il disco
        
);

-- Tabella condivisione collezione e collezionista (n..m)
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

-- Tabella relazione disco e autore (n..m)
create table composto(
	ID_disco integer unsigned not null, 
    ID_autore integer unsigned not null,
    ruolo varchar(30),
    primary key (ID_disco, ID_autore),
    
    constraint composto_disco foreign key (ID_disco)
		references disco(ID) on delete restrict on update cascade,
		-- elimino disco ed elimino tutte le righe nella tabella relative al disco
        -- in questo modo garantisco che non vi siano righe composto che fanno riferimento a dischi inesistenti

    constraint composto_autore foreign key (ID_autore)
		references autore(ID) on delete cascade on update cascade,
        -- se elimino l'autore(tabella riferita) elimino tutte le colonne relative all'autore nella tabella referente(compone)
        -- autore non può essere nullo perchè primary key
	constraint check_ruolo2 check (ruolo in ('compositore', 'esecutore', 'compositore ed esecutore'))
		
);

-- Tabella relazione traccia e autore (n..m)
create table scritta(
	ID_traccia integer unsigned not null, 
    ID_autore integer unsigned not null,
    ruolo varchar(20),
    primary key (ID_traccia, ID_autore),
    
    foreign key (ID_traccia) references traccia(ID) on delete cascade on update cascade,
		-- elimino traccia ed elimino tutte le righe nella tabella relative alla traccia
        -- in questo modo garantisco che non vi siano righe di 'scritta' che fanno riferimento a tracce inesistenti
    foreign key (ID_autore) references autore(ID) on delete restrict on update cascade,
        -- posso eliminare l'autore se non è collegato a nessun disco o nessuna traccia
	constraint check_ruolo check (ruolo in ('compositore', 'esecutore', 'compositore ed esecutore'))
);

-- Relazione disco e collezione (n..m)
create table raccolta(
ID_collezione integer unsigned not null,
ID_disco integer unsigned not null,
foreign key (ID_collezione) references collezione(ID) on delete cascade on update cascade,
foreign key (ID_disco) references disco(ID) on delete cascade on update cascade
);