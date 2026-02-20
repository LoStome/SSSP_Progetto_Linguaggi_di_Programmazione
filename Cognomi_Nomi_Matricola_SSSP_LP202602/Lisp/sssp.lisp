(defparameter *vertices* (make-hash-table :test #'equal))
(defparameter *arcs* (make-hash-table :test #'equal))
(defparameter *graphs* (make-hash-table :test #'equal))
(defparameter *visited* (make-hash-table :test #'equal))
(defparameter *distances* (make-hash-table :test #'equal))
(defparameter *previous* (make-hash-table :test #'equal))



(defun is-graph (graph-id)
    (gethash graph-id *graphs*))

(defun new-graph (graph-id)
  (or (gethash graph-id *graphs*)
      (setf (gethash graph-id *graphs*) graph-id)))




(defun delete-graph (graph-id)
  
  (remhash graph-id *graphs*)
  
  (dolist (hash-table 
  (list *vertices* *arcs* *visited* *distances* *previous*))
    (maphash (lambda (key value)
               (declare (ignore value)) 
              
               (when (and (listp key) (equal (first key) graph-id))
                
                 (remhash key hash-table)))
             hash-table))
             
  nil)



(defun new-vertex (graph-id vertex-id)
  (let ((vertex-rep (list 'vertex graph-id vertex-id)))
    (setf (gethash vertex-rep *vertices*) vertex-rep)))



(defun graph-vertices (graph-id)
  (let ((vertex-list nil)) 
    (maphash (lambda (key value)
               (declare (ignore value))
              
               (when (and (listp key) 
                          (eql (first key) 'vertex)
                          (equal (second key) graph-id))
              
                 (push key vertex-list)))
             *vertices*)
    vertex-list)) 


(defun test-graph-vertices ()
  (format t "--- INIZIO TEST GRAPH-VERTICES ---~%")
  
  ;; 1. Setup pulito
  (delete-graph 'grafo-a)
  (delete-graph 'grafo-b)
  (new-graph 'grafo-a)
  (new-graph 'grafo-b)
  
  ;; 2. Inseriamo 3 vertici nel grafo A e 1 nel grafo B
  (new-vertex 'grafo-a 'v1)
  (new-vertex 'grafo-a 'v2)
  (new-vertex 'grafo-a 'v3)
  (new-vertex 'grafo-b 'v-intruso)
  
  ;; 3. Testiamo il recupero
  (format t "Cerco i vertici di 'grafo-a'...~%")
  (let ((lista (graph-vertices 'grafo-a)))
    (format t "-> Trovati: ~S~%" lista)
    (format t "-> Numero di vertici trovati (Atteso 3): ~D~%" (length lista)))
  
  ;; 4. Pulizia
  (delete-graph 'grafo-a)
  (delete-graph 'grafo-b)
  (format t "--- FINE TEST ---~%")
  t)



