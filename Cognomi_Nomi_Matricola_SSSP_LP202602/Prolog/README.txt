SSSP (Single-Source Shortest Path) - Implementazione Prolog

Questo documento descrive l'implementazione in Prolog dell'algoritmo di Dijkstra per il problema dei cammini minimi a singola sorgente (SSSP). Il codice e' strutturato in tre componenti principali: la gestione del grafo, l'implementazione di una coda di priorita' (Min-Heap) e la logica dell'algoritmo di Dijkstra.

== 1. Strutture Dati e Stato (Fatti Dinamici) ==

Il programma utilizza fatti dinamici per mantenere lo stato del grafo, della coda di priorita' e le strutture di servizio necessarie all'algoritmo di Dijkstra. Ciascun fatto e' identificato dal nome del grafo (G) o dell'heap (H) per permettere la gestione concorrente di piu' istanze.

Grafo:
- graph(G): Identifica l'esistenza di un grafo dal nome G.
- vertex(G, V): Indica che nel grafo G esiste il vertice V.
- arc(G, U, V, Weight): Rappresenta un arco diretto nel grafo G dal vertice U al vertice V con il relativo peso Weight. Esiste anche la versione di comodo arc(G, U, V) con peso implicito a 1.

Min-Heap (Coda di Priorita'):
Viene utilizzato un Min-Heap simulato su un array implementato tramite asserzioni logiche.
- heap(H, Size): Mantiene la dimensione corrente (numero di elementi posizionati) nell'heap H.
- heap_entry(H, Pos, Key, Value): Memorizza un elemento nell'heap H all'indice Pos (da 1 a Size), con priorita' Key (la distanza) e valore Value (il nodo associato).

Stato dell'Algoritmo di Dijkstra:
- distance(G, V, Dist): Registra la distanza minima attuale (o provvisoria) del nodo V dalla sorgente nel grafo G. Puo' valere inf all'inizializzazione.
- previous(G, V, U): Traccia che il nodo U e' il predecessore del nodo V nel cammino minimo corrente dal nodo sorgente. Usato per la ricostruzione del cammino.
- visited(G, V): Segnala che il nodo V e' stato elaborato ("chiuso"), ovvero la sua distanza finale minima e' stata definitivamente calcolata e garantita.


== 2. API di Gestione Grafi ==

- new_graph(G): Crea un nuovo grafo con ID G. Se esiste gia', non fa nulla.
- delete_graph(G): Elimina completamente il grafo G e tutti i suoi vertici, archi e strutture dati associate all'algoritmo di Dijkstra.
- new_vertex(G, V): Aggiunge un vertice V al grafo G. Se il vertice o il grafo non esistono, vengono creati.
- vertices(G, Vs): Restituisce la lista Vs di tutti i vertici appartenenti al grafo G.
- new_arc(G, U, V, Weight) / new_arc(G, U, V): Crea un arco diretto da U a V con peso Weight (di default 1). Crea implicitamente anche i vertici U e V ed il grafo G se non gia' presenti. Fallisce se Weight < 0.
- arcs(G, Es): Restituisce la lista Es di tutti gli archi del grafo G.
- neighbors(G, V, Ns): Restituisce la lista Ns di tutti gli archi uscenti dal vertice V.
- Predicati di stampa ausiliari: list_vertices(G), list_arcs(G), list_graph(G).


== 3. API del Min-Heap ==

L'heap supporta le operazioni standard necessarie da Dijkstra.

- new_heap(H), delete_heap(H): Creano o cancellano l'intero heap H.
- empty(H), not_empty(H): Verificano se l'heap e' o non e' vuoto.
- insert(H, K, V): Inserisce l'elemento V con chiave K in coda all'heap, aggiornandone la dimensione. Richiama poi heapify_up per ripristinare la proprieta' di min-heap facendo "risalire" il nodo verso la radice.
- extract(H, K, V): Estrae il nodo con chiave minima (la radice, posizione 1). Successivamente sposta l'ultimo elemento dell'heap in radice e ripristina le proprieta' con heapify_down (facendolo scivolare verso i figli).
- modify_key(H, NewKey, OldKey, V): decrease-key essenziale per Dijkstra. Trova l'elemento V che aveva chiave OldKey, la aggiorna in NewKey, e poi esegue un ribilanciamento (heapify_up se NewKey e' diminuito, il caso d'uso in Dijkstra).
- heapify_up / heapify_down: Regole interne per mantenere l'ordine genitore-figli (Key(Parent) =< Key(Child)). I figli di un nodo a posizione i sono in 2*i e 2*i+1.


== 4. Algoritmo di Dijkstra & Shortest Path ==

Esecuzione dell'Algoritmo:
- dijkstra_sssp(G, Source): Punto d'ingresso principale dell'algoritmo SSSP.
  1. Identifica o crea lo sbocco per lo State azzerando distanze, visited e previous vecchi del grafo G.
  2. Inizializza l'heap e imposta a inf la distanza di tutti i nodi di G visti ad eccezione del Source.
  3. Il nodo Source viene configurato a distance 0 e inserito nell'heap.
  4. Avvia il dijkstra_loop(G, Heap) per l'estrazione ed esplorazione iterativa.

- dijkstra_loop(G, Heap): Finche' l'iteratore (Heap) non e' empty, estrae il nodo con priorita' minima U (a distanza minima). Lo marca come visited(G, U). Prende tutti i nodi adiacenti (Ns) uscenti da U e li rilassa delegando a update_neighbors.
  
- relax_edge(G, Heap, U, V, Alt, DistV): Prende il tracciato provvisorio di un arco (U,V).
  - Se il nodo V ha distanza inf, significa che non e' mai stato scoperto, quindi lo inserisce nello heap.
  - Se troviamo un cammino alternativo (Alt) migliore (<) della distanza attualmente calcolata (DistV) per il nodo V gia' scoperto in precedenza, invoca un aggiornamento (modify_key) nell'Heap.
  In entrambi i casi, aggiorna il database Prolog con change_distance e setta U a change_previous di V. 

Recupero del Cammino Minimo:
- shortest_path(G, Source, V, Path): Dopo l'esecuzione di dijkstra_sssp, ricompone un cammino dal nodo Source al nodo V.
  Opera richiamando build_path(G, Source, V, [], Path) navigando a ritroso dalla destinazione V verso la coda tramite i predicati previous(G, V, U) memorizzati ad ogni esecuzione vincente di Dijkstra, prepende gli archi all'accumulatore (Acc), formattandolo e incapsulandolo nell'argomento ritornato Path.
