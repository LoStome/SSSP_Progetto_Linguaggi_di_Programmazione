SSSP (Single-Source Shortest Path) - Implementazione Lisp

Questo documento descrive l'implementazione in Common Lisp dell'algoritmo di Dijkstra per il problema dei cammini minimi a singola sorgente (SSSP). Il codice e' strutturato in tre componenti principali: la gestione del grafo, l'implementazione di una coda di priorita' (Min-Heap) e la logica dell'algoritmo di Dijkstra.

== 1. Strutture Dati e Stato (Hash Tables) ==

A differenza del Prolog che usa i fatti dinamici, in Lisp lo stato e' mantenuto all'interno di Hash Table globali (defparameter). Le chiavi di queste tabelle utilizzano spesso liste come identificatori, ad esempio '(vertex graph-id vertex-id) o '(arc graph-id u v weight).

Grafo:
- *graphs*: Hash Table che tiene traccia dei grafi creati. La chiave e' il graph-id.
- *vertices*: Memorizza i vertici. La chiave e' una lista (vertex graph-id vertex-id).
- *arcs*: Memorizza gli archi. La chiave e' una lista (arc graph-id u v weight).

Min-Heap (Coda di Priorita'):
- *heaps*: Hash Table globale che gestisce gli heap.
La struttura interna di un heap e' una lista: (heap heap-id size array_di_minheap).
L'array di minheap memorizza elementi nel formato (Distanza Nodo). La posizione 0 dell'array e' ignorata per comodita', l'albero inizia da indice 1.

Stato dell'Algoritmo di Dijkstra:
- *distances*: Memorizza le distanze minime scoperte. Chiave: (distance graph-id vertex-id).
- *previous*: Memorizza l'albero dei cammini minimi (padre di ogni nodo). Chiave: (previous graph-id vertex-id).
- *visited*: Memorizza i nodi gia' completamente esplorati. Chiave: (visited graph-id vertex-id).


== 2. API di Gestione Grafi ==

Tutte le funzioni per i grafi iniziano tipicamente chiedendo il graph-id a cui applicarsi.
- (is-graph graph-id): Verifica se il grafo esiste.
- (new-graph graph-id): Crea un nuovo grafo.
- (delete-graph graph-id): Elimina un grafo e pulisce *tutte* le relative hash table.
- (new-vertex graph-id vertex-id): Aggiunge un nuovo vertice al grafo.
- (graph-vertices graph-id): Ritorna tutte le chiavi relative ai vertici di quel grafo.
- (new-arc graph-id u v &optional (weight 1)): Crea un arco pesato tra U e V (di default 1). Se i vertici non esistono, li crea.
- (graph-arcs graph-id): Ritorna tutte le chiavi relative agli archi del grafo.
- (graph-vertex-neighbors graph-id vertex-id): Restituisce la sottolista degli archi USCENTI dal vertice indicato.
- (graph-print graph-id): Utility per stampare a schermo nodi e archi del grafo.


== 3. API del Min-Heap ==

L'heap implementato in Lisp usa le functioni ricorsive classiche per manipolare dinamicamente un make-array sottostante.

- (new-heap heap-id), (heap-delete heap-id): Creazione o eliminazione (via remhash da *heaps*).
- Funzioni getter: heap-id, heap-size, heap-actual-heap.
- (heap-empty heap-id), (heap-not-empty heap-id): Verificatori di stato.
- (resize-heap heap-rep): Raddoppia la lunghezza dell'array sottostante quando l'heap si riempie.
- (heap-insert heap-id k v): Inserisce la coppia distanza (k) e nodo (v). Gestisce il ridimensionamento automatico dell'array seguendo con una chiamata a (heapify-up).
- (heap-extract heap-id): Prende l'elemento minimo (in indice 1), sposta l'ultimo nodo attivo nella radice dell'albero e bilancia la struttura chiamando (heapify-down).
- (heap-modify-key heap-id new-key old-key v): Permette l'operazione decrease-key. Cerca il nodo V che aveva la vecchia stima di distanza (old-key), imposta un nuovo valore per la chiave (new-key) ed effettua l'up-bubbling se e' diminuita, il down-bubbling se e' aumentata (condizione atossica).
- (heapify-up array index), (heapify-down array index size): Metodi base per l'ordinamento strutturale del min-heap basati su scambi Array.


== 4. Algoritmo di Dijkstra & Shortest Path ==

Funzioni di supporto di Dijkstra:
- sssp-dist, sssp-visited, sssp-previous: Getter comodi per interrogare lo stato con controlli di sicurezza (es. se la distanza non esiste ancora, ritorna "most-positive-double-float", in emulazione ad infinito).
- sssp-change-*: Wrapper sui setf per l'aggiornamento nelle Hash.
- clear-dijkstra-tables: Elimina eventuali residui di Dijkstra precedenti riferiti al grafo sulla quale vorremmo re-iniziare iterazione (clean start).
- init-distances: Imposta il peso di default ('nf' most-positive-double-float) a tutti i nodi di graph-vertices.
- relax-edges: Cicla ricorsivamente la sub-chain "neighbors" prodotta dal Min-Heap extraction e verifica la convenienza matematica. Se `alt < dist-v`, l'arco e' rilassato (aggiornato) ed esegue l'(heap-modify-key) o (heap-insert) per includerlo.

Esecuzione:
- (sssp-dijkstra graph-id source): Main entry point. Pulisce lo stato, alloca un nuovo Min-Heap, calcola le distances base, inserisce il sorgente con distanza 0 e, successivamente, cede il controllo a (dijkstra-loop).
- (dijkstra-loop graph-id): Funzione tipicamente tail-recursive che, ad ogni rientro in stack, valuta la fine dell'array `heap-not-empty`. Esegue l'estrazione (`heap-extract`), segna il nodo elaborato con `visited` ed inoltra i relativi `neighbors` a `relax-edges`.

Ricostruzione cammino:
- (shortest-path graph-id u v): Riprende i cammini da the-v end verso la the-u origin appoggiandosi sui risultati archiviati nelle table relative a *previous*. Se un predecessore nullo viene raggiunto (impossibilita' di arrivare) o v è scollegato, genera NIL, altrimenti crea iterativamente le cons-cell della traccia finale restituendola corretta.
