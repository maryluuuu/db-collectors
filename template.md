# Laboratorio di Basi di Dati: *Progetto "Titolo"* 

  

**Gruppo di lavoro**: 
| Matricola | Nome           | Cognome | Contributo al progetto | 
|:------------:|:----------------:|:-------------:|:-----------------------------:| 
|251926     |Maria Alberta|Caradio      |                                         | 
|278438     |Federico         | Leopardi    | 	                           | 
|278566     |Filippo             |Rastelli       |                        	             |
  
**Data di consegna del progetto**: gg/mm/aaaa 
  
## Analisi dei requisiti 
L'obiettivo del progetto "Collectors" è quello di sviluppare un database per la gestione delle collezioni di dischi dei collezionisti. Il database consente la registrazione di dati dei collezionisti, le loro collezioni di dischi, i dettagli e le tracce associate a ciascun disco. Il sistema offre una serie di funzionalità per l'inserimento, la modifica e la visualizzazione dei dati, nonché per la ricerca e l’analisi delle informazioni memorizzate.  
  
**Requisiti**: 
- Registrare i dati dei collezionisti, compresi e-mail e nickname.  
- Registrare i dati delle collezioni, consentendo ai collezionisti di creare più collezioni, ciascuna con un nome distinto.  
- Registrare i dettagli dei dischi, inclusi autori, titolo, anno di uscita, etichetta, genere, stato di conservazione, formato, numero di bar-code e numero di doppioni.  
- Registrare le tracce dei dischi, compresi titolo, durata, compositore ed esecutore.  
- Consentire l'associazione di immagini ai dischi, ad esempio copertina, retro, facciate interne o libretti.  
- Consentire ai collezionisti di condividere le proprie collezioni con nessuno, altri utenti o renderle pubbliche.  
- Fornire operazioni di base come l'inserimento di una nuova collezione, l'aggiunta di dischi e tracce, la modifica dello stato di pubblicazione di una collezione, la      
   rimozione di dischi o collezioni. 
- Supportare funzionalità avanzate come la visualizzazione dei dischi in una collezione, la visualizzazione della tracklist di un disco, la ricerca di dischi basata su  
   autori/compositori/interpreti o titoli e fornire le statistiche sui dati.  
  
**Dominio**: 
Elenchiamo le scelte progettuali relative al dominio della base di dati: 
1. **Identificazione delle entità e dei loro attributi**:  
**Collezionista:** entità a cui sono associate le informazioni dei collezionisti 
nickname: rappresenta il nome nella piattaforma associato con l'utente, è univoco quindi non possono esistere più utenti con lo stesso nickname, il dominio dell'attributo è stringa di caratteri. 
email: contiene l'indirizzo e-mail del collezionista è univoco, il dominio dell'attributo è stringa di caratteri. 
passkey: rappresenta la password dell’utente, il dominio dell’attributo è stringa di caratteri. 
  
**Collezione:** entità debole che memorizza le informazioni sulle collezioni 
nome: attributo nome dell'entità collezione contiene il nome della collezione, il dominio sono le stringhe di caratteri. Il titolo di una collezione è unico per ogni collezionista, non possono esserci due collezioni appartenenti ad un utente con lo stesso titolo. 
flag: identifica lo stato della collezione se è pubblica o privata, il suo dominio è un valore booleano, (pubblica è uguale a 1 e privato è uguale a 0) in questo modo si evita all'utente di scrivere delle stringhe e quindi di commettere eventuali errori, inoltre lo spazio occupato da un valore booleano è minore di quello che occupa una stringa di caratteri. 

**Disco**:  
titolo_disco: contiene il titolo del disco, il dominio dell'attributo è stringa di caratteri 
anno_uscita: memorizza l'anno di uscita del disco, il dominio dell'attributo è quindi valori temporali. 
barcode: memorizza il codice a barre univoco associato a disco, può essere nullo, il dominio dell'attributo è stringa di caratteri 
durata_totale: somma della durata delle singole tracce associate al disco, il dominio dell'attributo è valore temporale. 
genere: memorizza il nome del genere musicale, il dominio dell’attributo è stringa di caratteri 
etichetta: memorizza il nome dell’etichetta che ha prodotto il disco, il dominio dell’attributo è stringa di caratteri 
 
**Traccia** entità che memorizza le informazioni sulle tracce 
titolo: contiene il titolo della traccia, il dominio dell'attributo è stringa di caratteri 
durata: contiene la durata della traccia 
ISRC: contiene la stringa alfanumerica di 12 caratteri che identifica il codice internazionale delle singole opere musicali, il dominio è stringa di caratteri 
  
**Doppione** : entità che memorizza informazione sulle copie dei dischi dei collezionisti 
quantità: memorizza la quantità dei dischi fisici appartenenti all’utente con lo stesso formato e la stessa condizione, il dominio dell’attributo è valore numerico. 
formato: memorizza le informazioni sul formato del disco, che può essere scelto da un elenco di valori predefiniti che indicano i vari tipi di formato, il dominio dell’attributo è stringa di caratteri. 
condizione: memorizza le informazioni sulla condizione in cui si trova la copia dell’utente, che può essere scelto da un elenco predefinito di condizioni, il dominio dell’attributo è stringa di caratteri.  
 
**Autore**:   
Nome: contiene il nome dell’autore, il dominio dell’attributo è una stringa di caratteri, è possibile creare due autori con lo stesso nome. 
IPI: identificativo univoco dell’utente, formato da una stringa alfanumerica di 12 caratteri, il dominio dell’attributo è stringa di caratteri 
 
**Immagine**: L’entità debole immagine memorizza le informazioni delle immagini associate ai dischi. 
percorso: Contiene il percorso del file dell’immagine, identifica quindi univocamente le immagini, il dominio dell’attributo è una stringa di caratteri 
tipo: identifica il tipo di immagine, ad esempio se l’immagine è della copertina del disco, della tracklist e eventuali immagini del libretto e dell’interno del disco 
Disco: identifica il disco a cui è associata l’immagine, il valore del dominio sarà lo stesso dell’identificatore del disco, quindi valore numerico. 
 
**Relazioni**: 
- Gestisce: relazione di cardinalità uno a molti tra Collezionista e Collezione, un collezionista può creare molte collezioni (ciascuna con un nome distinto) e una collezione può essere gestita da un solo collezionista. Viene posta una chiave esterna in Collezione (tabella referente) che si riferisce all’identificatore del Collezionista (tabella riferita). Collezione deve essere necessariamente collegata ad un collezionista. 
- Condivisa: relazione di cardinalità molti a molti tra Collezionista e Collezione che identifica la condivisione di una collezione privata con dei collezionisti. un collezionista può condividere una collezione con molti collezionisti, inoltre molti collezionisti possono vedere una collezione. Viene creata una tabella di associazione di nome “condivisa” che associa la collezione con il collezionista, che si riferiscono rispettivamente all’identificatore della collezione e del collezionista. Un collezionista e una collezione possono non essere condivisi con nessun utente 
- Raccolta: relazione di cardinalità molti a molti tra Collezione e Disco che permette l’associazione di più dischi a una collezione. A una collezione possono appartenere più dischi e un disco può appartenere a più collezioni. Viene creata una tabella di associazione di nome “raccolta” che associa la collezione con il disco, che si riferiscono rispettivamente all’identificatore della collezione e del disco. Collezione e Disco possono esistere come entità separate e non associate. 
- Istanza: relazione di cardinalità uno a molti tra Doppione e Disco che permette l’associazione di più doppioni ad un disco. Un disco può avere più istanze doppione, ma un doppione è istanza di un solo disco. Viene posta una chiave esterna in Doppione (tabella referente) che si riferisce all’identificatore del Disco (tabella riferita). Doppione deve essere necessariamente collegata ad un disco. A un disco possono non essere associati doppioni.Ha senso inserire un doppione nel caso di aggiunta di un disco al database, tuttavia una volta eliminato il doppione il disco non verrà eliminato e in questo modo non verranno perse le sue associazioni con traccia e autore. 
- Possiede: relazione di cardinalità uno a molti tra Doppione e Collezionista. Un collezionista può avere più doppioni ma un doppione è di un solo collezionista. Viene posta una chiave esterna in Doppione (tabella referente) che si riferisce all’identificatore del Collezionista (tabella riferita).  Doppione deve essere necessariamente collegata ad un collezionista 
- Rappresenta: relazione di cardinalità uno a molti tra Immagine e Disco. Un disco può avere più immagini ma un’immagine è associata ad un solo disco. Viene posta una chiave esterna in Immagine (tabella referente) che si riferisce all’identificatore del Disco (tabella riferita).  Un'immagine deve essere necessariamente collegata ad un disco. 
- Formato: relazione di cardinalità uno a molti tra Traccia e Disco. Un disco può essere associato a più tracce, ma ogni traccia può essere associato ad un solo disco. Viene posta una chiave esterna in Traccia(tabella referente) che si riferisce all’identificatore di Disco(tabella riferita). Una traccia non può esistere senza un disco associato.
-Scritta: relazione di cardinalità molti a molti tra Traccia e Autore che permette l’associazione di più autori ad una traccia con i loro ruoli(compositore ed esecutore). Una traccia può avere più autori e un autore può scrivere più tracce. Viene create una tabella per la relazione di nome “scritta” che associa le entità Traccia e Autore e permette di associare i diversi autori alle tracce univocamente tramite i loro rispettivi identificatori. Una traccia può esistere senza essere associata a un’autore, l’autore può non avere associati dischi.
-Composto: relazione di cardinalità molti a molti tra Disco e Autore che permette l’associazione di più autori ad un disco con i loro ruoli(compositore ed esecutore). Un disco può avere più autori deve averne almeno uno per essere identificabile e un autore può comporre più dischi. Viene create una tabella per la relazione di nome “composto” che associa le entità Disco e Autore e permette di associare i diversi autori ai dischi univocamente tramite i loro rispettivi identificatori. Un disco non può esistere senza essere associato ad un autore, l’autore può non avere associati dischi. 

## Progettazione concettuale 

![diagramma e-r base](https://github.com/maryluuuu/progetto-basi-di-dati/assets/114227980/dbde1985-8acf-45a3-a9a1-9aba91dd6f56)


  
- Assumiamo che il genere e l’etichetta di un disco siano unici, che non possano esistere due dischi usciti nello stesso anno con lo stesso nome.  
- Possono esistere due autori con lo stesso nome ma con IPI diverso (Interested Party Information, codice univoco assegnato agli autori musicali. 
- Assumiamo che un autore non possa comporre più dischi con lo stesso nome.
- L’entità Doppione memorizza le informazioni associate alle copie fisiche dei dischi posseduti dai collezionisti e specifica la condizione in cui si trova il disco, il formato e la quantità che un collezionista possiede. L’entità è la copia fisica di un disco, abbiamo deciso di crearla per evitare la perdita di informazione e gli errori di aggiornamento che potrebbero crearsi quando si gestiscono numerose tuple in unica tabella con molte informazioni ripetute. Abbiamo deciso quindi di tenere traccia delle copie fisiche dei dischi posseduti dal collezionista in una entità a parte e di associare le informazioni generali del disco all’entità disco rendendola indipendente dalle sue copie fisiche.  
-Doppione è definita come entità padre nella generalizzazione totale con le entità figlie Formato Digitale e Formato Fisico che identificano le informazioni specifiche per la copia del disco. Una generalizzazione è totale quando tutte le istanze dell’entità genitore fanno parte di almeno un’entità figlia, almeno un formato identifica il doppione del disco. 
-Autore è definita come entità padre nella generalizzazione parziale con le entità figlie Compositore e Autore. In una generalizzazione parziale, ogni istanza dell'entità padre ("Autore") può appartenere solo a una delle entità figlie ("Compositore" o "Esecutore"), ma non ad entrambe contemporaneamente. 
- Disco rappresenta l'entità astratta del disco posseduto dal collezionista a cui vengono collegate le informazioni generali del disco che non dipendono dalla copia fisica posseduta dall'utente, viene collegata alle entità traccia ed autore, in questo modo si evita di sovraccaricare l'entità disco con molti attributi e, nel caso in cui nel database non ci siano più copie fisiche del disco, le informazioni dell'album e le sue associazioni con le altre tabelle non vengano perse. Un disco viene associato a un solo genere. Disco può essere univocamente identificato dal titolo del disco e dall’autore/autori a lui collegati. L’attributo “durata_totale” viene calcolato automaticamente come somma delle tracce associate al disco. 
 

### Formalizzazione dei vincoli non esprimibili nel modello ER   
L'attributo "anno_uscita" dell'entità "disco" deve essere un valore reale compreso nell'intervallo tra gli anni 1900 e l'anno corrente.
L'attributo "durata_totale" dell'entità "disco" è un attributo calcolato ottenuto sommando il valore dell'attributo "durata" di tutte le entità "traccia" associate al disco.
  

## Progettazione logica 

  

### Ristrutturazione ed ottimizzazione del modello ER 

  

- Riportate qui il modello **ER ristrutturato** ed eventualmente ottimizzato.  

- La relazione “Condivisa” lega le entità COLLEZIONE e COLLEZIONISTA 
- La generalizzazione totale associata a Doppione tra Formato Fisico e Formato Digitale è stata implementata aggiungendo un attributo chiamato "Formato" che identifica a quale formato appartiene il disco. Questo attributo può assumere valori specifici come "digitale" o "vinile" o “CD” o “musicassetta” o “LP” o “Stereo8” per indicare il tipo di formato del disco. Inoltre, abbiamo inserito un attributo aggiuntivo chiamato "condizione" specifico per il caso di formato fisico. Questo attributo può essere utilizzato per registrare informazioni sulla condizione fisica del disco, ad esempio se è in “perfetta” o “eccellente” o “molto buona” o “buona” o “brutta” o “pessima” condizione. 
- La generalizzazione totale associata ad Autore tra Compositore ed Esecutore è stata implementata aggiungendo un attributo chiamato "ruolo" che identifica il ruolo dell’autore nelle rispettive relazioni di autore con traccia e con disco. Questo attributo può assumere valori specifici come "compositore" o "esecutore" o “compositore ed esecutore” e servono per indicare il ruolo dell’artista nella composizione del disco e della traccia.  
- L’attributo di Disco etichetta è stato definito come entità a parte “Etichetta” con relazione di cardinalità uno a molti “produce” tra Etichetta e Disco. Un'etichetta può produrre più dischi ma ogni disco può essere prodotto da una sola etichetta. Assumiamo quindi che un disco è prodotto da una sola etichetta, se ci sono altre etichette associate al disco verranno omesse. Viene posta una chiave esterna in Disco(tabella referente) che si riferisce all’identificatore di Etichetta (tabella riferita). Un'etichetta può esistere senza avere dischi associati e il disco può esistere senza etichetta.  Non possono esistere due etichette con lo stesso nome. Abbiamo deciso di implementare la tabella per evitare valori ripetuti, con successive perdita di informazione e errori di aggiornamento, in questo modo la base di dati sarà più efficiente. 
-  L’attributo di disco etichetta è stato definito come entità a parte “Genere” con relazione di cardinalità uno a molti “classificato” tra Genere e Disco. Un genere può essere associato a più dischi, ma ogni disco può essere associato ad un solo genere. Assumiamo quindi che un disco è associato da un solo genere, se ci sono altri generi associati al disco verranno omessi. Viene posta una chiave esterna in Disco(tabella referente) che si riferisce all’identificatore di Genere(tabella riferita). Un genere può esistere senza avere dischi associati e il disco può esistere senza genere. Le informazioni sulle varie etichette non vengono perse con il cancellamento di dischi. Non possono esistere due generi con lo stesso nome 

 

  

### Traduzione del modello ER nel modello relazionale 

> **LEGENDA** 
> chiave primaria (PK = primary key) 
> chiave esterna (FK = foreign key) 

```sql
COLLEZIONISTA (ID, nickname, email, passkey) PK:ID 
COLLEZIONE (ID, nome, flag, ID_collezionista) PK: ID - FK:ID_collezionista 
GENERE (ID, nome) PK:ID 
ETICHETTA (ID, nome) PK:ID 
DISCO (ID, titolo_disco, anno_uscita, barcode, durata_totale, ID_etichetta, ID_genere)  
PK:ID - FK: ID_etichetta, ID_genere 
TRACCIA (ID, ISRC, titolo, durata, ID_disco) PK:ID 
AUTORE (ID, IPI, nome) PK:ID  
DOPPIONE (ID, quantita, formato, condizione, ID_disco, ID_collezionista) PK:ID – FK: ID_disco, ID_collezionista 
IMMAGINE (ID, percorso, tipo, ID_disco) PK:ID – FK:ID_disco 
CONDIVISA (ID_collezione, ID_collezionista) PK: ID_collezione, ID_collezionista 
COMPOSTO (ID­_disco, ID_autore, ruolo) PK: ID_disco, ID_autore 
SCRITTA (ID_autore, ID_traccia, ruolo) PK:ID_autore, ID_traccia 
RACCOLTA (ID_collezione, ID_disco) PK:ID_collezione, ID_disco 
```
 

## Progettazione fisica 

  

### Implementazione del modello relazionale 

  

- Inserite qui lo *script SQL* con cui **creare il database** il cui modello relazionale è stato illustrato nella sezione precedente. Ricordate di includere nel codice tutti 

  i vincoli che possono essere espressi nel DDL.  

  ```sql
  drop database if exists progettolab;
  create database progettolab;
  use progettolab;

  drop table if exists collezionista;
  drop table if exists collezione;
  drop table if exists genere;
  drop table if exists etichetta;
  drop table if exists disco;
  drop table if exists traccia;
  drop table if exists autore;
  drop table if exists doppione;
  drop table if exists immagine;
  drop table if exists condivisa;
  drop table if exists composto;
  drop table if exists scritta;
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
    anno_uscita year not null,
    barcode bigint(13) unsigned unique,
    durata_totale time default 0, -- default null importante, così posso creare un disco anche se non ho ancora tracce associate
    ID_etichetta smallint unsigned,
    ID_genere smallint unsigned,
			
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
      titolo varchar(100) not null,
      durata time not null,
      ISRC varchar(12) unique not null,
      -- ISRC codice a 12 caratteri alfanumeriche che identifica una traccia audio
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
    quantita smallint unsigned default 1,
    formato varchar(20) not null,
    condizione varchar(20) not null,
    ID_disco integer unsigned not null,
    ID_collezionista integer unsigned not null,
    unique (ID_disco,ID_collezionista,formato,condizione),
    constraint check_formato check (formato in ('CD', 'vinile', 'digitale', 'LP', 'musicassetta', 'Stereo8')),
		  -- il disco può essere solo di questi formati
    
    constraint check_condizione check (condizione in ('perfetta', 'eccellente',
		'molto buona', 'buona', 'brutta', 'pessima','nessuna' )),
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
		  references disco(ID) on delete cascade on update cascade,
        -- posso eliminare un disco anche se ha delle immagini associate
        -- le immagini associate vengono eliminate quando vine eliminato il disco
        
	  constraint check_tipo check (tipo in ('copertina', 'retro', 'libretto', 'facciata interna'))
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
	  primary key (ID_collezione, ID_disco),

	  foreign key (ID_collezione) references collezione(ID) on delete cascade on update cascade,
		  -- quando una collezione viene cancellata i dischi non sono più associati a nessuna collezione
	  foreign key (ID_disco) references disco(ID) on delete cascade on update cascade
		  -- quando elimino un disco dalla collezione elimino quel disco associato nella tabella raccolta 
  );
  ```

  

-Script separato di popolamento (INSERT) del database.

```sql
-- selezioniamo il database di default
use progettolab;

-- svuotiamo le tabelle
delete from `collezionista`;
delete from `collezione`;
delete from `genere`;
delete from `etichetta`;
delete from `disco`;
delete from `traccia`;
delete from `autore`;
delete from `doppione`;

-- Inserimento dei collezionisti
insert into collezionista(ID, nickname, email, passkey) values
(1,'alice','alice.lyndon@mail.it','randompassword'),
(2,'bob','bob.evans@mail.it','pipeline00'),
(3,'tyler','tyler.lynch@mail.it','pipeline01');

-- Inserimento di una nuova collezione
insert into `collezione`(ID, nome, flag, ID_collezionista) values
(1, 'I miei preferiti', 0, 2),
(2, 'Pink Floyd music', 1, 2),
(3, 'I miei preferiti', 0, 3),
(4, 'I miei preferiti', 1, 1);

-- Inserimento di generi musicali
insert into `genere` values
(1,'Progressive Rock'),
(2,'Art Rock'),
(3,'Progressive Pop'),
(4, 'Rock and roll'),
(5, 'Sunshine Pop');

-- Inserimento delle etichette discografiche
insert into `etichetta` values
(1, 'Sony Music Entertainment'),
(2, 'Universal Music Group'),
(3, 'Warner-Elektra-Atlantic'),
(4, 'Capitol Records');

-- Aggiunta di dischi a una collezione.
insert into `disco`(ID, titolo_disco, anno_uscita, barcode, ID_etichetta, ID_genere) values
-- disco 'The Wall' del 1979, barcode 0000000012,
-- della Sony Music Entertainment, genere Progressive Rock,
(1,'The Wall',1979,0000000012, 1, 1),


-- disco 'The Dark Side of the Moon' del 1973, non esiste barcode,
-- della Warner-Elektra-Atlantic, genere Progressive Pop,
(2, 'The Dark Side of the Moon', 1973, null, 1, 3),


-- disco 'Abbey Road' del 1969, non esiste barcode,
-- della Sony Music Entertainment, genere Art Rock,
(3, 'Abbey Road', 1969, null, 2, 2),
-- quando viene creato il disco non ci sono tracce associate quindi la durata di default è null.
-- Durante l'inserimento delle tracce interviene il trigger

-- disco 'Sgt. Pepper's Lonely Hearts Club Band' del 1967, barcode 0000000015,
-- della Sony Music Entertainment, genere Progressive Rock,
(4, "Sgt. Pepper's Lonely Hearts Club Band ", 1967, 0000000015, 4, 4),


-- disco 'Pet Sounds' del 1966 barcode 0000000018,
-- della Sony Music Entertainment, genere Art Rock,
(5, 'Pet Sounds', 1966, 0000000018, 4, 5);

-- Aggiunta di tracce a un disco.
insert into `traccia`(ID, ISRC, titolo, durata, ID_disco) values
-- tracce del disco The Wall
(1, 'EN1B3032676', 'Mother', SEC_TO_TIME(322), 1),
(2, 'EN1B3032677', 'Stop', SEC_TO_TIME(30), 1),
(3, 'EN1B3032678', 'Young Lust', SEC_TO_TIME(198), 1),
-- tracce del disco The Dark Side of the Moon
(4, 'EN3CF000276', 'Eclipse', SEC_TO_TIME(121), 2),
(5, 'EN3CF000277', 'Us and Them', SEC_TO_TIME(470), 2),
-- tracce del disco Abbey Road
(6, 'EN0KL7056885', 'Come Together', SEC_TO_TIME(260), 3),
(7, 'EN0KL7056886', 'Here Comes The Sun', SEC_TO_TIME(185), 3),
-- tracce del disco Pet Sound
(8, 'EN7AA099F88', "Wouldn't It Be Nice", SEC_TO_TIME(142), 5),
(9, 'EN77A099F89', 'God Only Knows', SEC_TO_TIME(169),5),
(10, 'EN7AA099F90', 'Caroline, No', SEC_TO_TIME(172),5);


insert into `autore` (ID, nome, IPI) values
(1,'Pink Floyd', 0000004853),
(2,'The Beatles', 0000007906),
(3, 'The Beach Boys',0000003897);

-- Inserimento dei doppioni di dischi dei collezionisti
insert into `doppione` values
(1, 4, 'CD', 'buona', 1, 1),					-- collezionista 1 (alice) ha 4 CD in buona condizione di 'The Wall'
(1, 2, 'CD', 'buona', 1, 1),					-- collezionista 1 (alice) ha 2 CD in buona condizione di 'The Wall'
(2, 5, 'vinile', 'pessima', 2, 1), 				-- collezionista 1 (alice) ha 5 vinili in pessima condizione di 'The Dark Side of the Moon'
(3, 1, 'musicassetta', 'perfetta', 3, 3),			-- collezionista 3 (tyler) ha 1 musicassetta in perfetta condizione di 'Abbey Road'
(4, 3, 'vinile', 'brutta', 3, 3) 				-- collezionista 3 (tyler) ha 3 vinili in brutta condizione di 'Abbey Road'
ON DUPLICATE KEY UPDATE quantita = quantita + VALUES(quantita); -- vincolo di aggiornamento quantità nel caso di disco già esistente

-- Aggiunta di nuove condivisioni a una collezione.
insert into `condivisa`(ID_collezionista, ID_collezione) values 
(1,1), (1,2);

-- Aggiunta di dischi a una collezione
insert into `raccolta`(ID_collezione, ID_disco) values
(2,4), (2,3),(2,5), (1,3), (1,4), (4,1), (4,3), (4,2);


-- Inserimento nella tabella composto
insert into `composto`(ID_disco, ID_autore, ruolo) values
(1,1,'compositore ed esecutore'),
(2,1,'compositore ed esecutore'),
(3,2,'compositore ed esecutore'),
(4,2,'compositore ed esecutore'),
(5,3,'compositore ed esecutore');

-- Inserimento dell'associazione tra traccia e autore
-- insert into `scritta`(ID_traccia, ID_autore) values
-- (1,1), (2,1), (3,1), (4,1), (5,1), (6,2), (7,2), (8,3), (9,3), (10,3);
```

### Implementazione dei vincoli 

  

- Abbiamo identificato due vincoli non direttamente esprimibili nel database: Il primo vincolo riguarda l'anno in cui può essere inserito un disco, poichè non ha senso aggiungere dischi che vengono scritti "nel futuro", di conseguenza, è necessario implementare un controllo per garantire che l'anno del disco sia inferiore o uguale all'anno corrente. Abbiamo scelto di creare una procedura che verifica che la data di pubblicazione sia compresa tra il 1900 e l'anno corrente che viene richiamata da un trigger che si attiva prima dell'inserimento e prima dell'aggiornamento di un disco nel database.
Il secondo vincolo riguarda il calcolo della durata totale del disco, è stata implementata una procedura che somma la durata delle singole tracce associate ad un certo disco, che viene richiamata da un trigger che si attiva dopo l'inserimento o dopo l'aggiornamento delle tracce di un determinato disco.

>Procedura per la verifica dell'anno
```sql
CREATE PROCEDURE verifica_anno(anno smallint unsigned)
BEGIN
    IF anno < 1900 OR anno > year(curdate()) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Anno non valido';
    END IF;
END$$
```

>Trigger per il controllo dell'anno
```sql
CREATE TRIGGER controllo_anno1
BEFORE INSERT ON disco
FOR EACH ROW BEGIN
CALL verifica_anno(NEW.anno_uscita);
END$$
```

>Trigger aggiornamento anno disco
```sql
CREATE TRIGGER controllo_anno2
BEFORE UPDATE ON disco
FOR EACH ROW BEGIN
IF NEW.anno_uscita != OLD.anno_uscita THEN
CALL verifica_anno(NEW.anno_uscita);
END IF;
END$$
```

>Procedura per il calcolo della durata totale di un disco.
```sql
CREATE PROCEDURE calcola_durata_totale(id_disco INTEGER UNSIGNED) 
BEGIN
    UPDATE disco
	SET disco.durata_totale = (
		SELECT SEC_TO_TIME(SUM(DISTINCT TIME_TO_SEC(traccia.durata)))
		FROM traccia
		WHERE traccia.ID_disco = id_disco
	)
	WHERE disco.ID = id_disco;		
END$$
```

>Trigger inserimento di tracce
```sql
CREATE TRIGGER inserisci_durata_totale
AFTER INSERT ON traccia
FOR EACH ROW BEGIN
  CALL calcola_durata_totale(NEW.ID_disco);
END$$
>Procedura per il calcolo della durata totale di un disco.
```

>Trigger per l'aggiornamento di tracce
```sql
CREATE TRIGGER aggiorna_durata_totale
AFTER UPDATE ON traccia
FOR EACH ROW BEGIN
CALL calcola_durata_totale(NEW.ID_disco);
END$$
```

### Implementazione funzionalità richieste 
- Assumiamo che nelle query in cui compare direttamente l’id_collezionista nei parametri di input delle procedure, questo venga generato automaticamente a partire dall’ID dell’utente che ha effettuato l’accesso ad una applicazione e che sta usando la funzionalità. 
- Le procedure create per il corretto funzionamento del database e dei suoi vincoli sono elencate dopo la dichiarazione del codice relative alle funzionalità richieste dalla specifica del progetto. 

#### Funzionalità 1 
- Viene inserita una nuova collezione con nome assegnato dall’utente e id collezione che rappresenta l’id del collezionista che vuole creare la collezione, il parametro id viene selezionato quindi in base all’utente che utilizza il database nell’applicazione e che richiama la procedura. 
> Inserimento di una nuova collezione. 
```sql 
CREATE FUNCTION query1(nomec varchar(80), id_collezionista integer unsigned) RETURNS integer unsigned 
READS SQL DATA

BEGIN

  IF id_collezionista is null or nomec is null then  
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valori inseriti errati'; 
	END IF;

  INSERT INTO collezione(nome,ID_collezionista) VALUES (nomec, id_collezionista); 
	RETURN last_insert_id();

END$$ 
``` 

#### Funzionalità 2  
- La funzionalità dell’aggiunta di dischi ad una collezione è risultata un po' onerosa ma abbiamo cercato di rendere l’inserimento più facile per l’utente, in questo modo se un utente vuole aggiungere un disco alla sua collezione virtuale può aggiungere il disco, l’autore e le informazioni sulle copie fisiche possedute al database usando un’unica procedura 
> Aggiunta di dischi a una collezione e di tracce a un disco.
```sql  
CREATE PROCEDURE query2disco ( nomecollezione varchar(80), nomed VARCHAR(100),  annod year, barcoded bigint(13), id_collezionista integer unsigned, 
  formatod varchar(20), condizioned varchar(20), quantitad smallint unsigned, nomea varchar(50), ipi integer unsigned )

BEGIN

  DECLARE id_collezione INTEGER UNSIGNED; 
  DECLARE id_disco INTEGER UNSIGNED; 
  DECLARE id_autore INTEGER UNSIGNED; 
  DECLARE id_doppione INTEGER UNSIGNED;

  -- Verifica se la collezione esiste 
  SELECT collezione.ID INTO id_collezione FROM collezione 
  WHERE collezione.nome = nomecollezione AND collezione.ID_collezionista=id_collezionista LIMIT 1;

  -- Verifica se il disco esiste 
  SELECT d.ID_disco INTO id_disco FROM dischiAutori d 
  WHERE d.titolo_disco=nomed AND d.IPI=ipi LIMIT 1 ;

  -- Se la collezione non esiste, esci dalla procedura 
  IF id_collezione IS NULL THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La collezione non esiste'; 
  END IF;

  -- Se il disco non esiste, crea il disco e lo associa a un autore 
  IF id_disco IS NULL THEN 
    INSERT INTO disco(titolo_disco, anno_uscita, barcode) VALUES 
    (nomed,annod,barcoded); 
    SET id_disco=last_insert_id(); 
    INSERT INTO autore(nome,IPI) VALUES (nomea,ipi); 
    SET id_autore=last_insert_id(); 
    INSERT INTO composto(ID_disco,ID_autore) VALUES (id_disco,id_autore); 
  END IF;

  -- Verifica se l'associazione esiste già nella tabella raccolta 
  IF not EXISTS( SELECT 1 FROM raccolta r WHERE r.ID_disco=id_disco AND r.ID_collezione=id_collezione) THEN
    -- Inserisci l'associazione nella tabella raccolta 
    INSERT INTO raccolta (ID_collezione, ID_disco) 
    VALUES (id_collezione, id_disco); 
  END IF;

  SELECT ID INTO id_doppione FROM doppione WHERE doppione.formato=formatod AND doppione.condizione=condizioned  
  AND doppione.ID_disco=id_disco;

  IF id_doppione is null THEN 
    INSERT INTO doppione(quantita, formato, condizione, ID_disco, ID_collezionista) 
    VALUES (quantitad, formatod, condizioned, id_disco, id_collezionista); 
  ELSE 
    UPDATE doppione 
    SET doppione.quantita=doppione.quantita+quantitad; 
  END IF;

END$$ 
``` 

 ```sql 
CREATE FUNCTION query2traccia(nomed varchar(100), nomea varchar(50), ipi integer unsigned, duratat smallint unsigned, 
  nomet varchar(100), isrc varchar(12)) RETURNS integer unsigned 
READS SQL DATA 

BEGIN 

  DECLARE id_traccia INTEGER UNSIGNED; 
  DECLARE id_disco INTEGER UNSIGNED; 
  DECLARE id_autore INTEGER UNSIGNED; 

  -- Verifica se il disco esiste 
  SELECT dischiAutori.ID_disco INTO id_disco 
  FROM dischiAutori WHERE dischiAutori.IPI=ipi AND dischiAutori.titolo_disco=nomed;

  IF id_disco IS NULL THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il disco non esiste'; 
  END IF; 

  SELECT ID INTO id_autore FROM autore 
	WHERE autore.IPI=ipi LIMIT 1; 

  -- Verifica se la traccia esiste 
  SELECT traccia.ID INTO id_traccia 
  FROM traccia 
  WHERE traccia.titolo=nomet AND traccia.ID_disco=id_disco; 

  -- Se la traccia non esiste viene inserita 
  IF id_traccia IS NULL THEN  
	  INSERT INTO traccia(titolo,durata,ISRC,ID_disco) VALUES  
	  (nomet,SEC_TO_TIME(duratat),isrc,id_disco); 
    SET id_traccia=last_insert_id();

      -- controllo se l'autore esiste 
      IF id_autore IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Autore non esistente'; 
      END IF; 

    INSERT INTO scritta(ID_traccia, ID_autore) VALUES (id_traccia, id_autore);

  END IF; 

  RETURN id_traccia; 

END$$ 
 ``` 

#### Funzionalità 3 

> Modifica dello stato di pubblicazione di una collezione (da privata a pubblica e viceversa) e aggiunta di nuove condivisioni a una collezione.  

```sql 
CREATE PROCEDURE modifica_stato_collezione (nomec varchar(80),id_collezionista integer unsigned)

BEGIN

  DECLARE idc integer unsigned; 
  SELECT ID INTO idc FROM collezione WHERE nome=nomec AND collezione.ID_collezionista=id_collezionista; 
  UPDATE collezione 
  SET flag = CASE 
  WHEN flag = 0 THEN 1 
  WHEN flag = 1 THEN 0 
  END 
  WHERE ID=idc;

  -- eliminiamo le condivisioni per una playlist impostata da privata a pubblica 
  IF (SELECT flag FROM collezione WHERE ID=idc) = 1 THEN 
	  DELETE  FROM condivisa WHERE ID_collezione = idc; 
  END IF; 

END$$ 
``` 

 

#### Funzionalità 4 

> Rimozione di un disco da una collezione. 

```sql 
CREATE PROCEDURE eliminazione_da_collezione( nomed varchar(100), ipi integer unsigned, nomec varchar(80), id_collezionista integer unsigned)

BEGIN

  DECLARE iddisco integer unsigned; 
  DECLARE idcollezione integer unsigned; 

  IF id_collezionista is null THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Collezionista non esistente'; 
  END IF; 

  SELECT collezione.ID INTO idcollezione FROM collezione WHERE collezione.nome=nomec AND collezione.ID_collezionista=id_collezionista;

  IF idcollezione is null THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Collezione non esistente'; 
  END IF; 

  SELECT ID_disco INTO iddisco FROM dischiAutori WHERE dischiAutori.titolo_disco=nomed AND dischiAutori.IPI=ipi; 
  DELETE FROM raccolta  
  WHERE ID_disco = iddisco and ID_collezione = idcollezione; 

END$$ 
``` 

 

#### Funzionalità 5 

> Rimozione di una collezione. 

  

```sql 

CREATE PROCEDURE query5(id_collezionista integer unsigned, nomec varchar(80)) 

BEGIN

  DECLARE idc integer unsigned; 
  IF id_collezionista IS NULL OR nomec IS NULL THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Collezione o collezionista non esistente'; 
  END IF;

  SELECT ID INTO idc FROM collezione WHERE collezione.nome=nomec AND collezione.ID_collezionista LIMIT 1; 
  DELETE FROM collezione WHERE collezione.ID=idc; 
  DELETE FROM raccolta WHERE raccolta.ID_collezione=idc; 
  DELETE FROM condivisa WHERE condivisa.ID_collezione=idc; 

END$$ 
``` 

 

#### Funzionalità 6 

> Lista di tutti i dischi in una collezione.  

```sql 

CREATE PROCEDURE lista_dischi (nomec varchar(60), id_collezionista integer unsigned) 

BEGIN 

  DECLARE id_collezione integer unsigned; 
  IF id_collezionista is null THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il collezionista non esiste'; 
  END IF;

  SELECT ID INTO id_collezione FROM collezione WHERE collezione.nome=nomec AND ID_collezionista=id_collezionista LIMIT 1;

  IF id_collezione is null THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La collezione non esiste'; 
  END IF; 

  SELECT disco.titolo_disco FROM disco  
  JOIN raccolta ON disco.ID=raccolta.ID_disco 
  WHERE raccolta.ID_collezione=id_collezione; 

END$$ 
``` 

 

#### Funzionalità 7 

> Track list di un disco. 

  

```sql 

CREATE PROCEDURE tracklist (nomed varchar(100), ipi integer unsigned) 

BEGIN 

  DECLARE id_disco integer unsigned; 
  SELECT dischiAutori.ID_disco INTO id_disco FROM dischiAutori WHERE dischiAutori.titolo_disco=nomed AND dischiAutori.IPI=ipi LIMIT 1; 

  IF id_disco is null THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il disco non esiste'; 
  END IF; 

  SELECT DISTINCT titolo, traccia.durata, titolo_disco  
  FROM disco JOIN traccia ON disco.ID=traccia.ID_disco 
  WHERE traccia.ID_disco = id_disco; 

END$$ 
``` 

 

#### Funzionalità 8 

> Ricerca di dischi in base a nomi di autori/compositori/interpreti e/o titoli. Si potrà decidere di includere nella ricerca le collezioni di un certo collezionista e/o quelle condivise con lo stesso collezionista e/o quelle pubbliche. 

  

```sql 
CREATE PROCEDURE trova_disco (id_collezionista integer unsigned, nome_autore varchar(50), titolo_disco varchar(50))

  BEGIN

  -- Ricerca in base ai nomi di autori/compositori/interpreti e/o titoli nelle collezioni private di un collezionista
  SELECT dischiAutori.titolo_disco
  FROM dischiAutori
  JOIN raccolta ON raccolta.ID_disco=dischiAutori.ID_disco
  JOIN collezione ON collezione.ID = raccolta.ID_collezione
  WHERE (dischiAutori.nome LIKE (CONCAT('%',nome_autore,'%')) OR dischiAutori.titolo_disco LIKE (CONCAT('%',titolo_disco,'%')))
    AND collezione.flag = 0
    AND collezione.ID_collezionista = id_collezionista
  UNION

  -- Ricerca in base ai nomi di autori/compositori/interpreti e/o titoli nelle collezioni condivise con un collezionista
  SELECT dischiAutori.titolo_disco
  FROM dischiAutori
  JOIN raccolta ON raccolta.ID_disco=dischiAutori.ID_disco
  JOIN collezione ON collezione.ID = raccolta.ID_collezione
  JOIN condivisa ON condivisa.ID_collezione = collezione.ID
  WHERE (dischiAutori.nome LIKE (CONCAT('%',nome_autore,'%')) OR dischiAutori.titolo_disco LIKE (CONCAT('%',titolo_disco,'%')))
    AND condivisa.ID_collezionista = id_collezionista
  UNION

  -- Ricerca in base ai nomi di autori/compositori/interpreti e/o titoli nelle collezioni pubbliche
  SELECT dischiAutori.titolo_disco
  FROM dischiAutori
  JOIN raccolta ON raccolta.ID_disco = dischiAutori.ID_disco
  JOIN dischiCPubbliche ON dischiCPubbliche.ID = raccolta.ID_disco
  WHERE (dischiAutori.nome LIKE (CONCAT('%',nome_autore,'%')) OR dischiAutori.titolo_disco LIKE (CONCAT('%',titolo_disco,'%')));

END$$
``` 

#### Funzionalità 9 

- Nel caso di questa procedura l’utente può scegliere il proprietario della playlist che vuole visualizzare, i dischi appartenenti alla collezione verranno visualizzati solo se l’utente che richiama la funzione ha i permessi necessari alla visualizzazione della collezione. 

> Verifica della visibilità di una collezione da parte di un collezionista. 

```sql 
CREATE PROCEDURE verifica_visibilita ( id_collezionista integer unsigned, nomecollezione varchar(80), nickname1 varchar(60)) 

BEGIN 

  DECLARE id_collezione integer unsigned; 
  DECLARE id_collezionista1 integer unsigned;

  IF id_collezionista is null or nickname1 is null or nomecollezione is null then 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inseriti valori errati'; 
  END IF; 

  SELECT c1.ID INTO id_collezionista1 FROM collezionista c1 WHERE c1.nickname=nickname1 LIMIT 1; 

  IF id_collezionista1 is null then 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il collezionista non esiste'; 
  END IF; 

  SELECT c.ID INTO id_collezione FROM collezione c WHERE c.nome=nomecollezione AND c.ID_collezionista=id_collezionista1 LIMIT 1; 

  IF id_collezione is null then 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La collezione non esiste'; 
  END IF; 

  SELECT disco.titolo_disco 
  FROM collezione c  
  JOIN raccolta ON raccolta.ID_collezione = c.ID 
  JOIN disco ON disco.ID=raccolta.ID_disco 
  LEFT JOIN condivisa ON raccolta.ID_collezione = condivisa.ID_collezione 
  WHERE (c.ID=id_collezione) AND (c.ID_collezionista = id_collezionista OR condivisa.ID_collezionista = id_collezionista OR c.flag = 1); 

END$$ 
``` 

 

#### Funzionalità 10 

> Numero dei brani (tracce di dischi) distinti di un certo autore (compositore, musicista) presenti nelle collezioni pubbliche. 

  

```sql 
CREATE PROCEDURE braniPerAutore(nomea varchar(50),ipi integer unsigned ) 

BEGIN 

  DECLARE ida integer unsigned; 
  SELECT autore.ID INTO ida FROM autore WHERE IPI=ipi LIMIT 1; 
  SELECT dischiAutori.nome, COUNT(DISTINCT traccia.ID) AS Numero_brani 
  FROM dischiAutori  
  JOIN traccia ON traccia.ID_disco=dischiAutori.ID_disco 
  LEFT JOIN scritta ON scritta.ID_autore=dischiAutori.ID_autore 
  JOIN dischiCPubbliche ON dischiCPubbliche.ID=dischiAutori.ID_disco 
  WHERE dischiAutori.ID_autore=ida 
  GROUP BY dischiAutori.ID_autore; 

END$$ 
``` 

 

#### Funzionalità 11 

> Minuti totali di musica riferibili a un certo autore (compositore, musicista) memorizzati nelle collezioni pubbliche. 

  

```sql 
CREATE PROCEDURE minutiPerAutore(nomea varchar(60), ipi integer unsigned) 

BEGIN 

  DECLARE ida integer unsigned; 
  SELECT ID INTO ida FROM autore WHERE autore.IPI=ipi; 
  SELECT dischiAutori.nome, SEC_TO_TIME(SUM(DISTINCT TIME_TO_SEC(traccia.durata))) AS Numero_brani 
  FROM dischiAutori 
  JOIN traccia ON traccia.ID_disco=dischiAutori.ID_disco 
  LEFT JOIN scritta ON scritta.ID_autore=dischiAutori.ID_autore 
  JOIN dischiCPubbliche ON dischiCPubbliche.ID = dischiAutori.ID_disco 
  WHERE dischiAutori.ID_autore=ida 
  GROUP BY dischiAutori.ID_autore; 

END$$ 
``` 

 

#### Funzionalità 12 

> Statistiche (una query per ciascun valore): numero di collezioni di ciascun collezionista, numero di dischi per genere nel sistema. 

  

```sql 
-- numero di collezioni di ciascun collezionista 
CREATE PROCEDURE statistiche1() 

BEGIN 

  SELECT nickname, COUNT(*) as numero_collezioni FROM collezione JOIN collezionista ON ID_collezionista=collezionista.ID 
  GROUP BY ID_collezionista; 

END$$ 
``` 

 

```sql  
-- 12.2 Statistiche: numero di dischi per genere nel sistema. 
CREATE PROCEDURE statistiche2() 

BEGIN 

  SELECT nome, COUNT(*) as numero_dischi FROM genere JOIN disco ON genere.ID = disco.ID_genere 
  GROUP BY ID_genere; 

END$$ 
``` 

 

#### Funzionalità 13 

> Opzionalmente, dati un numero di barcode, un titolo e il nome di un autore, individuare tutti i dischi presenti nelle collezioni che sono più coerenti con questi dati 

  

```sql 

CODICE 

``` 
