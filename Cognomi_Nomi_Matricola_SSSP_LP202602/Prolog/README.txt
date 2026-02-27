SSSP

Predicati di supporto creati per dijkstra_sssp:
-init_distances(GraphId, VerticesList): 
  Scorre la lista dei vertici. Per ognuno, asserisce dinamicamente il fatto distance(GraphId, V, inf).

-dijkstra_loop(GraphId, Heap): 
  - Caso base: se l'Heap e' vuoto (empty), termina con successo.
  - Passo ricorsivo: estrae il nodo minimo (extract), lo marca come visitato (assert(visited)), ne recupera i vicini e li passa a update_neighbors. Al termine, richiama se stesso.

-update_neighbors(GraphId, Heap, U, DistU, NeighborsList): 
  Itera ricorsivamente sulla lista degli archi adiacenti al nodo U appena estratto. Per ogni arco, invoca process_neighbor' e poi procede col resto della lista.

-process_neighbor / relax_edge: 
  - Se il nodo di destinazione V e' gia' stato visitato, viene ignorato, altrimenti, si calcola la nuova distanza potenziale (Alt = DistU + Weight).
  - La logica di relax_edge si divide in due parti:
    1. Se la vecchia distanza era 'inf', si aggiorna il database e si inserisce il nodo nell'Heap per la prima volta (insert).
    2. Se la nuova distanza Alt e' minore della vecchia DistV, si aggiorna il database e si modifica la chiave del nodo gia' presente nell'Heap (modify_key).


Predicati di supporto creati per shortest_path:
-build_path(GraphId, Source, CurrentNode, Accumulator, FinalPath): 
  E' un predicato tail-recursive che costruisce il percorso a ritroso, garantendo che la lista finale sia ordinata dalla partenza all'arrivo.
  - Caso base: quando CurrentNode coincide con Source, copia l'Accumulator in FinalPath e termina.
  - Passo ricorsivo: cerca nel database il padre di CurrentNode tramite il fatto 'previous(G, CurrentNode, Prev)'. Recupera il peso dell'arco, costruisce la struttura 'arc(G, Prev, CurrentNode, W)', 
    la aggiunge in testa all'accumulator e richiama se stesso passando 'Prev' come nuovo nodo corrente.


Predicati di supporto creati per insert/3, extract/3, modify_key/4:
-heapify_up(HeapId, Pos) / swap_up_if_needed: 
  Usato durante l'inserimento o quando una chiave viene diminuita. Confronta il nodo in posizione 'Pos' con il suo genitore ('Pos // 2'). 
  Se la chiave del nodo e' minore di quella del padre, 'swap_up_if_needed' ritratta i fatti attuali, li ri-asserisce a posizioni invertite e richiama 'heapify_up' sul nuovo indice, facendo "galleggiare" il nodo verso la radice.

-heapify_down(HeapId, Pos, Size) / swap_down_if_needed: 
  Usato durante l'estrazione (quando la radice viene rimpiazzata dall'ultima foglia). Calcola gli indici dei figli (Left, Right). 
  Tramite i predicati 'get_min_child_left' e 'get_min_child_right' individua quale dei due figli ha la chiave minore. Se questo figlio e' minore del genitore, 
  scambia le posizioni e procede ricorsivamente verso il basso per ripristinare il bilanciamento.

-adjust_heap(HeapId, Pos, NewKey, OldKey): 
  Chiamato da 'modify_key'. Decide in modo intelligente se lanciare 'heapify_up' (se la nuova distanza e' minore della vecchia) o 'heapify_down' (se e' maggiore), 
  garantendo che la struttura dell'albero venga sempre ricalcolata correttamente.