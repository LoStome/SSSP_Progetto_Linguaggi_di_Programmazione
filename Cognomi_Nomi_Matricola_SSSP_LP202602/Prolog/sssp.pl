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
    
    (K < PK ->                                      
        retract(heap_entry(H, Pos, K, V)),         
        retract(heap_entry(H, ParentPos, PK, PV)),  
        assert(heap_entry(H, Pos, PK, PV)),        
        assert(heap_entry(H, ParentPos, K, V)),    
        heapify_up(H, ParentPos)                    
    ;
        true                                        
    ).


extract(H, K, V) :-
    heap(H, S), 
    S > 0,
    
    heap_entry(H, 1, K, V),
    retract(heap_entry(H, 1, K, V)),
    
    (   S =:= 1 ->
        retract(heap(H, 1)),
        assert(heap(H, 0))
    ;
        heap_entry(H, S, LastK, LastV),
        retract(heap_entry(H, S, LastK, LastV)),
        
        assert(heap_entry(H, 1, LastK, LastV)),
        
        NewS is S - 1,
        retract(heap(H, S)),
        assert(heap(H, NewS)),
        
        heapify_down(H, 1, NewS)
    ),
    !.


heapify_down(H, Pos, Size) :-
    Left is Pos * 2,
    Right is Pos * 2 + 1,
    
    (   Left =< Size ->
        heap_entry(H, Pos, PosK, _),
        heap_entry(H, Left, LeftK, _),
        (   LeftK < PosK -> Min1 = Left ; Min1 = Pos )
    ;   
        Min1 = Pos
    ),
    
    (   Right =< Size ->
        heap_entry(H, Min1, Min1K, _),
        heap_entry(H, Right, RightK, _),
        (   RightK < Min1K -> MinPos = Right ; MinPos = Min1 )
    ;   
        MinPos = Min1
    ),
    
    (   MinPos \= Pos ->
        heap_entry(H, Pos, K1, V1),
        heap_entry(H, MinPos, K2, V2),
        
        retract(heap_entry(H, Pos, K1, V1)),
        retract(heap_entry(H, MinPos, K2, V2)),
        assert(heap_entry(H, Pos, K2, V2)),
        assert(heap_entry(H, MinPos, K1, V1)),
        
        heapify_down(H, MinPos, Size)
    ;   
        true
    ).


modify_key(H, NewKey, OldKey, V) :-
    heap_entry(H, Pos, OldKey, V),
    
    retract(heap_entry(H, Pos, OldKey, V)),
    assert(heap_entry(H, Pos, NewKey, V)),
    
    (   NewKey < OldKey ->
        heapify_up(H, Pos)
    ;   NewKey > OldKey ->
        heap(H, Size),
        heapify_down(H, Pos, Size)
    ;   
        true
    ),
    !.
list_heap(H) :-
    listing(heap(H, _)),
    listing(heap_entry(H, _, _, _)).