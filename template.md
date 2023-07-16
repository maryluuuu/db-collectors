# Laboratorio di Basi di Dati:  *Progetto "Titolo"*

**Gruppo di lavoro**:

| Matricola | Nome           | Cognome | Contributo al progetto |
|:---------:|:--------------:|:-------:|:----------------------:|
|251926     |Maria Alberta   |Caradio  |                        |
|           |                |         |                        |

**Data di consegna del progetto**: gg/mm/aaaa

## Analisi dei requisiti
L'obiettivo del progetto "Collectors" è quello di sviluppare un database per la gestione delle collezioni di dischi dei collezionisti. Il database consente la registrazione di dati dei collezionisti, le loro collezioni di dischi, i dettagli e le tracce associate a ciascun disco. Il sistema offre una serie di funzionalità per l'inserimento, la modifica e la visualizzazione dei dati, nonché per la ricerca e l’analisi delle informazioni memorizzate. 

**Requisiti**: 

- Registrare i dati dei collezionisti, compresi e-mail e nickname. 
- Registrare i dati delle collezioni, consentendo ai collezionisti di creare più collezioni, ciascuna con un nome distinto. 
- Registrare i dettagli dei dischi, inclusi autori, titolo, anno di uscita, etichetta, genere, stato di conservazione, formato, numero di barcode e numero di doppioni. 
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
Abbiamo individuato le entità chiave principali che rappresentano gli oggetti rilevanti del dominio creando le seguenti entità e attributi, questi vengono elencati con i loro attributi di dominio

**Collezionista:** entità a cui sono associate le informazioni dei collezionisti
nickname: rappresenta il nome nella piattaforma associato con l'utente, è univoco quindi non possono esistere più utenti con lo stesso nickname, il dominio dell'attributo  è stringa di caratteri.
email contiene l'indirizzo email del collezionista è univoco, il dominio dell'attributo è stringa di caratteri.

**Collezione:** entità che memorizza le informazioni sulle collezioni
nome: attributo nome dell'entità collezione contiene il nome della collezione, il dominio sono le stringhe di caratteri. Il titolo di una collezione è unico per ogni          collezionista, non possono esserci due collezioni appartenenti ad un utente con lo stesso titolo.
flag: identifica lo stato della collezione se è pubblica o privata, il suo dominio è valori booleani, in questo modo si evita all'utente di scrivere delle stringhe e gli       eventuali errari, inoltre lo spazio occupato da un valore booleano è minore di quello che occupa una stringa di caratteri

**Disco**: rappresenta l'entità astratta del disco posseduto dal collezionista a cui vengono collegate le informazioni generali del disco che non dipendono dalla copia fisica posseduta dall'utente, viene collegata alle entità brano ed autore, in questo modo si evita di sovraccaricare l'entià disco con molti attributi e, nel caso in cui nel database non ci siano più copie fisiche del disco, le informazioni dell'album e le sue associazioni con le altre tabelle non vengano perse. Le informazioni sulle specifiche copie ed i relativi doppioni posseduti da un collezionista vengono salvate nell'entità doppione che è associata con disco.

titolo_disco: contiene il titolo del disco, il dominio dell'attributo è stringa di caratteri
anno_uscita: memorizza l'anno di uscita del disco, il dominio dell'attributo è quindi valori temporali.
barcode: memorizza il barcode univoco associato a disco, può essere nullo, il dominio dell'attributo è stringa di caratteri
durata_totale: attributo calcolato come somma della durata delle singole tracce associate al disco, il dominio dell'attributo è valore temporale

**Traccia** entità che memorizza le informazioni sulle tracce
titolo: contiene il titolo della traccia, il dominio dell'attributo è stringa di caratteri
durata: contiene la durata della traccia
ISRC: contiene la stringa alfanumerica di 12 caratteri che identifica il codice internazionale delle singole opere musicali, il dominio è stringa di caratteri

**Doppione** entità che memorizza le informazioni associate alle copie fisiche dei dischi posessduti dai collezionisti e contiene
quantità
formato
condizione
disco_associato
collezionista associato



, "traccia", "disco" e "collezione". Si è inoltre deciso di aggiungere un'ulteriore entità al database di nome "doppione", che contiene
- -- E' possibile infine inserire qui un glossario che riporta tutti gli oggetti di dominio individuati, con la loro semantica, i loro eventuali sinonimi e le loro proprietà.

## Progettazione concettuale

- Riportate qui il **modello ER iniziale**. Cercate di renderlo *leggibile*, altrimenti correggerlo diventerà impossibile. Se è troppo piccolo, dividetelo in parti e/o allegate anche un'immagine ad alta risoluzione alla relazione.

- Commentate gli elementi non visibili nella figura (ad esempio il contenuto degli attributi composti) nonché le scelte/assunzioni che vi hanno portato a creare determinate strutture, se lo ritenete opportuno.

### Formalizzazione dei vincoli non esprimibili nel modello ER

- Elencate gli altri **vincoli** sui dati che avete individuato e che non possono essere espressi nel diagramma ER.

## Progettazione logica

### Ristrutturazione ed ottimizzazione del modello ER

- Riportate qui il modello **ER ristrutturato** ed eventualmente ottimizzato. 

- Discutete le scelte effettuate, ad esempio nell'eliminare una generalizzazione o nello scindere un'entità.

### Traduzione del modello ER nel modello relazionale

- Riportate qui il **modello relazionale** finale, derivato dal modello ER ristrutturato della sezione precedente e che verrà implementato in SQL in quella successiva. 

- Nel modello evidenziate le chiavi primarie e le chiavi esterne.

## Progettazione fisica

### Implementazione del modello relazionale

- Inserite qui lo *script SQL* con cui **creare il database** il cui modello relazionale è stato illustrato nella sezione precedente. Ricordate di includere nel codice tutti
  i vincoli che possono essere espressi nel DDL. 

- Potete opzionalmente fornire anche uno script separato di popolamento (INSERT) del database su cui basare i test delle query descritte nella sezione successiva.

### Implementazione dei vincoli

- Nel caso abbiate individuato dei **vincoli ulteriori** che non sono esprimibili nel DDL, potrete usare questa sezione per discuterne l'implementazione effettiva, ad esempio riportando il codice di procedure o trigger, o dichiarando che dovranno essere implementati all'esterno del DBMS.

### Implementazione funzionalità richieste

- Riportate qui il **codice che implementa tutte le funzionalità richieste**, che si tratti di SQL o di pseudocodice o di entrambi. *Il codice di ciascuna funzionalità dovrà essere preceduto dal suo numero identificativo e dal testo della sua definizione*, come riportato nella specifica.

- Se necessario, riportate anche il codice delle procedure e/o viste di supporto.

#### Funzionalità 1

> Definizione come da specifica

```sql
CODICE
```

#### Funzionalità 2

> Definizione come da specifica

```sql
CODICE
```

## Interfaccia verso il database

- Opzionalmente, se avete deciso di realizzare anche una **(semplice) interfaccia** (a linea di comando o grafica) in un linguaggio di programmazione a voi noto (Java, PHP, ...) che manipoli il vostro database , dichiaratelo in questa sezione, elencando
  le tecnologie utilizzate e le funzionalità invocabili dall'interfaccia. 

- Il relativo codice sorgente dovrà essere *allegato *alla presente relazione.

-----

**Raccomandazioni finali**

- Questo documento è un modello che spero possa esservi utile per scrivere la documentazione finale del vostro progetto di Laboratorio di Basi di Dati.

- Cercate di includere tutto il codice SQL nella documentazione, come indicato in questo modello, per facilitarne la correzione. Potete comunque allegare alla documentazione anche il *dump* del vostro database o qualsiasi altro elemento che ritenete utile ai fini della valutazione.

- Ricordate che la documentazione deve essere consegnata, anche per email, almeno *una settimana prima* della data prevista per l'appello d'esame. Eventuali eccezioni a questa regola potranno essere concordate col docente.
