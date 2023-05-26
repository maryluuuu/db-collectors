drop database if exists progettoLab;
create database progettoLab;
use progettoLab;

drop table if exists collezionista; -- X
drop table if exists collezione; -- X
drop table if exists genere; -- X
drop table if exists autore; -- X
drop table if exists traccia; -- X
drop table if exists etichetta; -- X
drop table if exists disco; -- X
drop table if exists doppioni; -- X
drop table if exists scritta; -- X
drop table if exists immagine; -- X
drop table if exists compone; -- X


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
    ID_collezionista integer unsigned not null,
    
    constraint check_share check (flag in ('pubblico', 'privato')),
		-- flag può essere pubblico o privato
    
	constraint collezione_collezionista foreign key (ID_collezionista) 
		references collezionista(ID) on delete cascade on update cascade,
			-- cascade, perchè se cancelli un collezionista cancelli
            -- il riferimento alla collezione
        
    constraint nome_unica unique (ID_collezionista, nome)
        
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
    
);


create table traccia(

	ID integer unsigned auto_increment primary key,
    titolo varchar(180) unique not null,
    durata integer unsigned not null,
    ID_disco integer unsigned not null,
    
    constraint traccia_disco foreign key (ID_disco)
		references disco(ID) on delete cascade on update cascade 
			-- cascade, cancellato il disco cancelli la traccia

);

    
create table etichetta(

	ID integer unsigned auto_increment primary key,
    nome varchar(200) not null
    
);
  
  
create table disco(

	ID integer unsigned auto_increment primary key,
    titolo_disco varchar(180) not null,
    anno_uscita smallint unsigned not null,
    barcode integer unsigned unique,
    durata_totale integer unsigned not null,
    ID_etichetta integer unsigned not null,
    ID_genere integer unsigned not null,
    ID_collezionista integer unsigned not null,
    
    constraint controllo_anno check (anno_uscita > 1900 and anno_uscita < year(now())),
		-- controlla se l'anno sta tra il 1900 e l'anno corrente
			
	constraint disco_etichetta foreign key (ID_etichetta)
		references etichetta(ID) on delete set null on update cascade,
			-- set null perchè una volta cancellata l'etichetta
            -- il disco ancora esiste nonostante l'assenza
            -- dell' etichetta
                
	constraint disco_genere foreign key (ID_genere)
		references genere(ID) on delete restrict on update cascade,
			-- cascade, cancella il genere se non c'è nessun disco
            -- che lo appartenga

	constraint disco_collezionista foreign key (ID_collezionista)
		references collezionista(ID) on delete cascade on update cascade
			-- cascade, cancellato il collezionista cancelli il 
            -- disco
            
);


create table doppione(

	ID integer unsigned auto_increment primary key,
    progressivo integer not null,
    quantita integer unsigned default 1,
    formato varchar(70) not null,
    condizione varchar(200) not null,
    ID_disco integer unsigned not null,
    ID_collezionista integer unsigned not null,
    
    constraint check_formato check (formato in ('CD', 'vinile', 'digitale', 'LP', 'musicasetta', 'Stereo8')),
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


create table scritta(

	ID_traccia  integer unsigned not null,
    ID_autore integer unsigned not null,
    primary key (ID_traccia, ID_autore),
    
    constraint scritta_traccia foreign key (ID_traccia)
		references traccia(ID) on delete cascade on update cascade,
			-- cascade, perchè se cancelli la traccia cancelli
            -- anche l'autore legato a quella traccia
        
	constraint scritta_autore foreign key (ID_autore)
		references autore(ID) on delete set null on update cascade
			-- set null, perchè cancellando l'autore non cancelli
            -- le traccie legate ad esso ma semplicemente ometti
            -- l'autore
            
);


create table immagine(

	ID integer unsigned auto_increment primary key,
    percorso varchar(500) unique not null,
		-- percorso dove si trova il file dell'immagine
    tipo varchar(200) not null,
    ID_disco integer unsigned not null,
    
	constraint immagine_disco foreign key (ID_disco)
		references disco(ID) on delete restrict on update cascade
        -- restrict, cancella il disco se non sono presenti 
        -- più immagini
        
);
    

create table compone(

	ID_disco integer unsigned not null, 
    ID_autore integer unsigned not null,
    primary key (ID_disco, ID_autore),
    
    constraint compone_disco foreign key (ID_disco)
		references disco(ID) on delete cascade on update cascade,
			-- cascade perchè se il disco viene cancellato anche
			-- l'autore viene cancellato
        
    constraint compone_autore foreign key (ID_autore)
		references autore(ID) on delete restrict on update cascade
			-- restrict per cancellare l'autore non deve essere associato
			-- a nessun disco 
        
);