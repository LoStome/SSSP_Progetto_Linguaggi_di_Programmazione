:- dynamic graph/1.
:- dynamic vertex/2.
:- dynamic arc/3.
:- dynamic arc/4.

:- dynamic heap/2.       
:- dynamic heap_entry/4. 


%graphs 

new_graph(G) :-
    graph(G),     
    !.         

new_graph(G) :-  
    assert(graph(G)), 
    !.

delete_graph(G) :-
    retractall(vertex(G, _)),
    
    retractall(arc(G, _, _, _)),
    
    retractall(distance(G, _, _)),
    retractall(visited(G, _)),
    retractall(previous(G, _, _)),
    
    retractall(graph(G)).



new_vertex(G, V) :-
    vertex(G, V),
    !.

new_vertex(G, V) :-
    graph(G),             
    assert(vertex(G, V)), 
    !.

vertices(G, Vs) :-
    findall(V, vertex(G, V), Vs).

list_vertices(G) :-
    listing(vertex(G, _V)).




new_arc(G, U, V) :- new_arc(G, U, V, 1).

new_arc(G, U, V, _W) :-
    arc(G, U, V, _),
    !.

new_arc(G, U, V, Weight) :-
    Weight >= 0,          
    
    new_graph(G),        
    new_vertex(G, U),     
    new_vertex(G, V),      
    
    assert(arc(G, U, V, Weight)),
    !.

arcs(G, Es) :-
    findall(arc(G, U, V, Weight), arc(G, U, V, Weight), Es).


neighbors(G, V, Ns) :-
    vertex(G, V),                                   
    findall(arc(G, V, N, W), arc(G, V, N, W), Ns).  



list_arcs(G) :-
    listing(arc(G, _, _, _)).

list_graph(G) :-
    list_vertices(G),
    list_arcs(G).



%minHeap
new_heap(H) :- 
    heap(H, _Size), 
    !.

new_heap(H) :- 
    assert(heap(H, 0)),
    !.

delete_heap(H) :-
    retractall(heap_entry(H, _, _, _)),

    retractall(heap(H, _)).

empty(H) :-
    heap(H, 0).

not_empty(H) :-
    heap(H, S),
    S > 0.

head(H, K, V) :-
    heap_entry(H, 1, K, V).

insert(H, K, V) :-
    heap(H, S),                        % 1. Recupera dimensione corrente
    NewS is S + 1,                     % 2. Calcola nuova posizione
    retract(heap(H, S)),               % 3. Rimuove vecchia dimensione
    assert(heap(H, NewS)),             % 4. Aggiorna dimensione
    assert(heap_entry(H, NewS, K, V)), % 5. Inserisce elemento in fondo
    heapify_up(H, NewS),               % 6. Ripristina proprietà heap
    !.

% Caso base: Se siamo alla radice (Pos 1), abbiamo finito.
heapify_up(_, 1) :- !.

% Caso ricorsivo: Confronta con il padre
heapify_up(H, Pos) :-
    Pos > 1,                                        %controlla che non siamo alla radice
    ParentPos is Pos // 2,                          % Calcola posizione padre
    heap_entry(H, Pos, K, V),                       % Prende chiave/valore corrente
    heap_entry(H, ParentPos, PK, PV),               % Prende chiave/valore padre
    
    (K < PK ->                                      % SE la chiave corrente è minore del padre...
        retract(heap_entry(H, Pos, K, V)),          % ...Rimuovi corrente
        retract(heap_entry(H, ParentPos, PK, PV)),  % ...Rimuovi padre
        assert(heap_entry(H, Pos, PK, PV)),         % ...Metti padre giù
        assert(heap_entry(H, ParentPos, K, V)),     % ...Metti corrente su
        heapify_up(H, ParentPos)                    % ...Ricorsione sul padre
    ;
        true                                        % ALTRIMENTI: proprietà soddisfatta, stop.
    ).