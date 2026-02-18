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
    retractall(vertex(G, _V)),
    
    retractall(arc(G, _U, _V, _W)),
    
    retractall(distance(G, _V, _D)),
    retractall(visited(G, _V)),
    retractall(previous(G, _V, _U)),
    
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
    arc(G, U, V, _W),
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
    listing(arc(G, _V, _N, _W)).

list_graph(G) :-
    list_vertices(G),
    list_arcs(G).



%minHeap
new_heap(H) :- 
    heap(H, _S), 
    !.

new_heap(H) :- 
    assert(heap(H, 0)),
    !.

delete_heap(H) :-
    retractall(heap_entry(H, _P, _K, _V)),

    retractall(heap(H, _Size)).