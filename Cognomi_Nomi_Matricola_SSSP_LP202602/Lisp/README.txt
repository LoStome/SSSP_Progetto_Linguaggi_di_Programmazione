SSSP

-resize-heap: Alloca dinamicamente un array di capacita' doppia qualora il numero di nodi superi la dimensione iniziale, copiando i vecchi elementi.
-heapify-up / heapify-down: Funzioni ricorsive che si occupano di ripristinare la proprieta' del Min-Heap scambiando gli elementi nell'array durante le operazioni di inserimento (heap-insert) o estrazione (heap-extract).
-heap-modify-key: Ricerca linearmente un nodo tramite 'find-heap-element-index', ne aggiorna la priorita' (distanza) e lancia 'heapify-up' o 'heapify-down' a seconda se la nuova chiave e' minore o maggiore della precedente.


Funzioni di supporto per sssp-dijkstra:
-clear-dijkstra-tables: usa 'maphash' e 'remhash' per eliminare solo le associazioni relative al grafo in esecuzione, lasciando inalterati eventuali altri grafi residenti in memoria.
-dijkstra-loop: Estrae il minimo, lo marca come visitato, delega il controllo dei vicini a 'relax-edges' e si richiama ricorsivamente finche' lo heap non si svuota.
-relax-edges: Analizza in modo ricorsivo la lista dei vicini.
  - Se il vicino ha distanza infinita, significa che e' stato appena scoperto, quindi viene inserito nell'heap.
  - Se viene trovato un percorso piu' vantaggioso per un nodo gia' noto, la sua priorita' nell'heap viene modificata.


Funzione di supporto per shortest-path:
-build-path (current acc): Funzione tail-recursive.
  - Caso base: Se il nodo 'current' corrisponde alla sorgente 'u', ritorna l'accumulatore .
  - Passo ricorsivo: Interroga la tabella *previous* per trovare il genitore del nodo corrente. Utilizza la funzione di libreria 'find-if' sui vicini del genitore per recuperare la tupla esatta dell'arco che li congiunge. Aggiunge questo arco in testa all'accumulatore e richiama se stessa passando il genitore come nuovo nodo.