:- dynamic graph/1.
:- dynamic vertex/2.
<<<<<<< HEAD


=======
>>>>>>> origin/branch-Fabio
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

<<<<<<< HEAD
list_vertices(G) :- listing(vertex(G, _)).
=======
list_vertices(G) :-
    listing(vertex(G, _)).
>>>>>>> origin/branch-Fabio
