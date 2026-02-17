:- dynamic graph/1.
:- dynamic vertex/2.
:- dynamic arc/4.

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
    listing(vertex(G, _)).


new_arc(G, U, V) :-
    new_arc(G, U, V, 1).


new_arc(G, U, V, _) :-
    arc(G, U, V, _),
    !.


new_arc(G, U, V, Weight) :-
    graph(G),                    
    vertex(G, U),               
    vertex(G, V),              
    Weight >= 0,                
    assert(arc(G, U, V, Weight)),
    !.