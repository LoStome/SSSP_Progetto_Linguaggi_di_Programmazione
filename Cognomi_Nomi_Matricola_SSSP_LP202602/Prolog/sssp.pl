:- dynamic graph/1.
:- dynamic vertex/2.
:- dynamic arc/3.
:- dynamic arc/4.

:- dynamic heap/2.       
:- dynamic heap_entry/4. 

:- dynamic distance/3.
:- dynamic visited/2.
:- dynamic previous/3.

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
    new_graph(G),        
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
    graph(G),        
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

empty(H) :- heap(H, 0).

not_empty(H) :- 
    heap(H, S), 
    S > 0.

head(H, K, V) :- 
    heap_entry(H, 1, K, V).

insert(H, K, V) :-
    heap(H, S),
    NewS is S + 1,
    retract(heap(H, S)),
    assert(heap(H, NewS)),
    assert(heap_entry(H, NewS, K, V)),
    heapify_up(H, NewS),
    !.


heapify_up(_, 1) :- !.
heapify_up(H, Pos) :-
    Pos > 1,
    ParentPos is Pos // 2,
    heap_entry(H, Pos, K, V),
    heap_entry(H, ParentPos, PK, PV),
    swap_up_if_needed(H, Pos, ParentPos, K, V, PK, PV).

swap_up_if_needed(H, Pos, ParentPos, K, V, PK, PV) :-
    K < PK, !,                                 
    retract(heap_entry(H, Pos, K, V)),
    retract(heap_entry(H, ParentPos, PK, PV)),
    assert(heap_entry(H, Pos, PK, PV)),
    assert(heap_entry(H, ParentPos, K, V)),
    heapify_up(H, ParentPos).
swap_up_if_needed(_, _, _, _, _, _, _).         

extract(H, K, V) :-
    heap(H, S), S > 0,
    heap_entry(H, 1, K, V),
    retract(heap_entry(H, 1, K, V)),
    extract_update_heap(H, S),
    !.

extract_update_heap(H, 1) :- !,                 
    retract(heap(H, 1)),
    assert(heap(H, 0)).
extract_update_heap(H, S) :-                  
    heap_entry(H, S, LastK, LastV),
    retract(heap_entry(H, S, LastK, LastV)),
    assert(heap_entry(H, 1, LastK, LastV)),
    NewS is S - 1,
    retract(heap(H, S)),
    assert(heap(H, NewS)),
    heapify_down(H, 1, NewS).


heapify_down(H, Pos, Size) :-
    Left is Pos * 2,
    Right is Pos * 2 + 1,
    get_min_child_left(H, Pos, Left, Size, Min1),
    get_min_child_right(H, Min1, Right, Size, MinPos),
    swap_down_if_needed(H, Pos, MinPos, Size).


get_min_child_left(H, Pos, Left, Size, Min1) :-
    Left =< Size,
    heap_entry(H, Pos, PosK, _),
    heap_entry(H, Left, LeftK, _),
    LeftK < PosK, !, Min1 = Left.
get_min_child_left(_, Pos, _, _, Pos).


get_min_child_right(H, Min1, Right, Size, MinPos) :-
    Right =< Size,
    heap_entry(H, Min1, Min1K, _),
    heap_entry(H, Right, RightK, _),
    RightK < Min1K, !, MinPos = Right.
get_min_child_right(_, Min1, _, _, Min1).


swap_down_if_needed(H, Pos, MinPos, Size) :-
    MinPos \= Pos, !,
    heap_entry(H, Pos, K1, V1),
    heap_entry(H, MinPos, K2, V2),
    retract(heap_entry(H, Pos, K1, V1)),
    retract(heap_entry(H, MinPos, K2, V2)),
    assert(heap_entry(H, Pos, K2, V2)),
    assert(heap_entry(H, MinPos, K1, V1)),
    heapify_down(H, MinPos, Size).
swap_down_if_needed(_, _, _, _).


modify_key(H, NewKey, OldKey, V) :-
    heap_entry(H, Pos, OldKey, V),
    retract(heap_entry(H, Pos, OldKey, V)),
    assert(heap_entry(H, Pos, NewKey, V)),
    adjust_heap(H, Pos, NewKey, OldKey),
    !.

adjust_heap(H, Pos, NewKey, OldKey) :-
    NewKey < OldKey, !, heapify_up(H, Pos).    
adjust_heap(H, Pos, NewKey, OldKey) :-
    NewKey > OldKey, !, heap(H, Size), heapify_down(H, Pos, Size).
adjust_heap(_, _, _, _).                       

list_heap(H) :-
    listing(heap(H, _)),
    listing(heap_entry(H, _, _, _)).


% ALGORITMO DI DIJKSTRA 
change_distance(G, V, NewDist) :-
    retractall(distance(G, V, _)),
    assert(distance(G, V, NewDist)),
    !.

change_previous(G, V, U) :-
    retractall(previous(G, V, _)),
    assert(previous(G, V, U)),
    !.

safe_delete_heap(H) :- heap(H, _), !, delete_heap(H).
safe_delete_heap(_).

dijkstra_sssp(G, Source) :-
    retractall(distance(G, _, _)),
    retractall(previous(G, _, _)),
    retractall(visited(G, _)),
    
    safe_delete_heap(G),
    new_heap(G),
    
    vertices(G, Vs),
    init_distances(G, Vs),
    
    change_distance(G, Source, 0),
    insert(G, 0, Source),
    
    dijkstra_loop(G, G),
    !.

init_distances(_, []).
init_distances(G, [V|Vs]) :-
    assert(distance(G, V, inf)),
    init_distances(G, Vs).

dijkstra_loop(_, Heap) :-
    empty(Heap), !.
dijkstra_loop(G, Heap) :-
    extract(Heap, DistU, U),
    assert(visited(G, U)),
    neighbors(G, U, Ns),
    update_neighbors(G, Heap, U, DistU, Ns),
    dijkstra_loop(G, Heap).


update_neighbors(_, _, _, _, []).
update_neighbors(G, Heap, U, DistU, [arc(G, U, V, Weight) | Ns]) :-
    process_neighbor(G, Heap, U, DistU, V, Weight),
    update_neighbors(G, Heap, U, DistU, Ns).


process_neighbor(G, _, _, _, V, _) :-
    visited(G, V), !.


process_neighbor(G, Heap, U, DistU, V, Weight) :-
    Alt is DistU + Weight,
    distance(G, V, DistV),
    relax_edge(G, Heap, U, V, Alt, DistV).


relax_edge(G, Heap, U, V, Alt, inf) :-
    !,
    change_distance(G, V, Alt),
    change_previous(G, V, U),
    insert(Heap, Alt, V).

relax_edge(G, Heap, U, V, Alt, DistV) :-
    Alt < DistV, !,
    change_distance(G, V, Alt),
    change_previous(G, V, U),
    modify_key(Heap, Alt, DistV, V).


relax_edge(_, _, _, _, _, _).


shortest_path(G, Source, V, Path) :-
    build_path(G, Source, V, [], Path).

build_path(_, Source, Source, Path, Path) :- !.
build_path(G, Source, Current, Acc, Path) :-
    previous(G, Current, Prev),               
    arc(G, Prev, Current, W),                 
    !,                                        
    build_path(G, Source, Prev, [arc(G, Prev, Current, W) | Acc], Path).



% ==========================================
% SCRIPT DI TEST GLOBALE (PROLOG PURO)
% Esegui dalla console digitando: ?- esegui_test.
% ==========================================

esegui_test :-
    write('--- INIZIO TEST GLOBALE SSSP ---'), nl,
    
    % 1. Pulizia e Creazione Grafo
    write('1. Creazione del grafo di test...'), nl,
    delete_graph(test_g),
    new_graph(test_g),
    
    new_vertex(test_g, s),
    new_vertex(test_g, a),
    new_vertex(test_g, b),
    new_vertex(test_g, c),
    new_vertex(test_g, d),
    
    % Inserimento archi con pesi strategici
    new_arc(test_g, s, a, 10),
    new_arc(test_g, s, c, 5),
    new_arc(test_g, c, a, 2),  % Scorciatoia per 'a' (costo totale 7 invece di 10)
    new_arc(test_g, a, b, 1),
    new_arc(test_g, c, d, 9),
    new_arc(test_g, b, d, 4),  % Scorciatoia per 'd' passando per 'b' (costo 12 invece di 14)
    
    % 2. Esecuzione Dijkstra
    write('2. Esecuzione dijkstra_sssp(test_g, s)...'), nl,
    dijkstra_sssp(test_g, s),
    write('   Algoritmo terminato con successo!'), nl, nl,
    
    % 3. Verifica Distanze
    write('3. VERIFICA DISTANZE CALCOLATE:'), nl,
    distance(test_g, s, Ds), write('   Distanza s -> s (Atteso: 0)  = '), write(Ds), nl,
    distance(test_g, a, Da), write('   Distanza s -> a (Atteso: 7)  = '), write(Da), nl,
    distance(test_g, b, Db), write('   Distanza s -> b (Atteso: 8)  = '), write(Db), nl,
    distance(test_g, c, Dc), write('   Distanza s -> c (Atteso: 5)  = '), write(Dc), nl,
    distance(test_g, d, Dd), write('   Distanza s -> d (Atteso: 12) = '), write(Dd), nl, nl,
    
    % 4. Verifica Percorso Minimo
    write('4. VERIFICA CAMMINO MINIMO PER "d":'), nl,
    shortest_path(test_g, s, d, PathD),
    write('   Cammino trovato:'), nl,
    write('   '), write(PathD), nl,
    
    % Pulizia finale
    delete_graph(test_g),
    write('--- FINE TEST ---'), nl, !.