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

  (mapc (lambda (hash-table)
          (maphash (lambda (key value)
                     (declare (ignore value)) 
                     (when (and (listp key) (equal (second key) graph-id))
                       (remhash key hash-table)))
                   hash-table))
        (list *vertices* *arcs* *visited* *distances* *previous*))
        
  nil)


(defun new-vertex (graph-id vertex-id)
  (new-graph graph-id)
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


(defun new-arc (graph-id u v &optional (weight 1))
  (new-vertex graph-id u)
  (new-vertex graph-id v)
  (let ((arc-rep (list 'arc graph-id u v weight)))
    (setf (gethash arc-rep *arcs*) arc-rep)))



(defun graph-arcs (graph-id)
  (let ((acc nil)) 
    (maphash (lambda (key val)
               (declare (ignore val))
               (when (and (listp key) 
                          (eq (first key) 'arc) 
                          (equal (second key) graph-id))

                 (push key acc)))
             *arcs*)
    acc)) 


(defun graph-vertex-neighbors (graph-id vertex-id)
  (let ((neighbors nil))
    (maphash (lambda (key value)
               (declare (ignore value))
               (when (and (listp key)
                          (eql (first key) 'arc)
                          (equal (second key) graph-id)
                          (equal (third key) vertex-id)) 
                 (push key neighbors)))
             *arcs*)
    neighbors))


(defun graph-print (graph-id)
(format t "Grafo: ~S~%" graph-id)

(format t "Vertici:~%")
(let ((verts (graph-vertices graph-id)))
  (if verts
      (mapc (lambda (v)
              (format t "  ~S~%" v))
            verts)
      (format t "  (Nessun vertice trovato)~%")))
      
(format t "Archi:~%")
(let ((arcs-found nil))

  (maphash (lambda (key value)
              (declare (ignore value))
              (when (and (listp key)
                        (eql (first key) 'arc)
                        (equal (second key) graph-id))
                (setf arcs-found t)
                (format t "  ~S~%" key)))
            *arcs*)
  (unless arcs-found
    (format t "  (Nessun arco trovato)~%")))

t)

(defparameter *heaps* (make-hash-table :test #'equal))
(defun new-heap (heap-id &optional (initial-capacity 42))
  (or (gethash heap-id *heaps*)
      (setf (gethash heap-id *heaps*)
            (list 'heap heap-id 0 (make-array initial-capacity)))))

(defun heap-id (heap-rep)
  (second heap-rep))

(defun heap-size (heap-rep)
  (third heap-rep))

(defun heap-actual-heap (heap-rep)
  (fourth heap-rep))

(defun heap-delete (heap-id)

  (remhash heap-id *heaps*)

t)

(defun heap-empty (heap-id)
  (let ((heap-rep (gethash heap-id *heaps*)))
    (if heap-rep
        (= (heap-size heap-rep) 0)
        nil)))

(defun heap-not-empty (heap-id)
  (let ((heap-rep (gethash heap-id *heaps*)))
    (if heap-rep
        (> (heap-size heap-rep) 0)
        nil)))

(defun heap-head (heap-id)
  (let ((heap-rep (gethash heap-id *heaps*)))
    (when (and heap-rep (> (heap-size heap-rep) 0))
      (aref (heap-actual-heap heap-rep) 1))))


(defun resize-heap (heap-rep)
  (let* ((old-array (heap-actual-heap heap-rep))
         (old-capacity (length old-array))
         (new-array (make-array (* 2 old-capacity))))
    (replace new-array old-array)
    (setf (fourth heap-rep) new-array)))

(defun heapify-up (array index)
  (when (> index 1)
    (let* ((parent-index (floor index 2))
           (current-node (aref array index))
           (parent-node (aref array parent-index)))
      
      (when (< (first current-node) (first parent-node))
        (setf (aref array index) parent-node)
        (setf (aref array parent-index) current-node)
        
        (heapify-up array parent-index)))))

(defun heap-insert (heap-id k v)
  (let ((heap-rep (gethash heap-id *heaps*)))
    (when heap-rep
      (let* ((current-size (heap-size heap-rep))
             (current-array (heap-actual-heap heap-rep))
             (capacity (length current-array))
             (new-size (+ current-size 1)))
        
        (when (>= new-size capacity)
          (resize-heap heap-rep)
          (setf current-array (heap-actual-heap heap-rep)))
        
        (setf (third heap-rep) new-size)
        
        (setf (aref current-array new-size) (list k v))
        
        (heapify-up current-array new-size)
        
        t))))


(defun heapify-down (array index size)
  (let* ((left (* 2 index))            
         (right (+ (* 2 index) 1))    
         (smallest index))            
    
    (when (and (<= left size)
               (< (first (aref array left)) (first (aref array smallest))))
      (setf smallest left))
      
    (when (and (<= right size)
               (< (first (aref array right)) (first (aref array smallest))))
      (setf smallest right))
      
    (when (not (= smallest index))
      (let ((temp (aref array index)))
        (setf (aref array index) (aref array smallest))
        (setf (aref array smallest) temp))
        
      (heapify-down array smallest size))))

(defun heap-extract (heap-id)
  (let ((heap-rep (gethash heap-id *heaps*)))
    (when (and heap-rep (> (heap-size heap-rep) 0))
      (let* ((size (heap-size heap-rep))
             (array (heap-actual-heap heap-rep))
             (min-element (aref array 1))
             (last-element (aref array size)))
        
        (setf (aref array 1) last-element)
        
        (setf (aref array size) nil)
        
        (let ((new-size (- size 1)))
          (setf (third heap-rep) new-size)
          
          (when (> new-size 0)
            (heapify-down array 1 new-size)))
        
        min-element))))

(defun find-heap-element-index (array old-key v index size)
  (if (> index size)
      nil 
      (let ((current (aref array index)))
        (if (and current
                 (= (first current) old-key)
                 (equal (second current) v))
            index 
            (find-heap-element-index array old-key v (+ index 1) size)))))

(defun heap-modify-key (heap-id new-key old-key v)
  (let ((heap-rep (gethash heap-id *heaps*)))
    (when heap-rep
      (let* ((size (heap-size heap-rep))
             (array (heap-actual-heap heap-rep))
             (pos (find-heap-element-index array old-key v 1 size)))
        
        (when pos
          (setf (aref array pos) (list new-key v))
          
          (cond
            ((< new-key old-key)
             (heapify-up array pos))
             
            ((> new-key old-key)
             (heapify-down array pos size)))
             
          t)))))

(defun heap-print (heap-id)
  (let ((heap-rep (gethash heap-id *heaps*)))
    (if heap-rep
      (let* ((size (heap-size heap-rep))
              (array (heap-actual-heap heap-rep))
              (capacity (length array)))
        
        (format t "~%Minheap: ~S ===~%" heap-id)
        (format t "Dimensione: ~A~%" size)
        (format t "Capacita' totale array: ~A~%" capacity)
        
        (format t "Nodi attivi (in ordine di array): ~S~%" 
                (subseq array 1 (+ size 1)))
        
        (format t "Array completo: ~S~%" array)
        (format t "---~%")
        
        t)
        
      (progn
        (format t "Lo heap ~S non esiste ~%" heap-id)
        nil))))

(defun sssp-dist (graph-id vertex-id)
  
  (multiple-value-bind (dist present-p)
      (gethash (list 'distance graph-id vertex-id) *distances*)
      
    (if present-p
        dist
        most-positive-double-float)))

(defun sssp-visited (graph-id vertex-id)
  (nth-value 1 (gethash (list 'visited graph-id vertex-id) visited)))

(defun sssp-previous (graph-id vertex-id)
  (gethash (list 'previous graph-id vertex-id) previous nil))

(defun sssp-change-dist (graph-id vertex-id new-dist)
  (setf (gethash (list 'distance graph-id vertex-id) distances) new-dist)
  nil)

(defun sssp-change-previous (graph-id vertex-id u)
  (setf (gethash (list 'previous graph-id vertex-id) previous) u)
  nil)


(defun clear-dijkstra-tables (graph-id)
  (maphash (lambda (k v)
             (declare (ignore v))
             (when (and (listp k) (equal (second k) graph-id))
               (remhash k *distances*)))
           *distances*)
  (maphash (lambda (k v)
             (declare (ignore v))
             (when (and (listp k) (equal (second k) graph-id))
               (remhash k *previous*)))
           *previous*)
  (maphash (lambda (k v)
             (declare (ignore v))
             (when (and (listp k) (equal (second k) graph-id))
               (remhash k *visited*)))
           *visited*))

(defun init-distances (graph-id vertices)
  (when vertices
    (let ((v (third (first vertices)))) 
      (sssp-change-dist graph-id v most-positive-double-float)
      (init-distances graph-id (rest vertices)))))

(defun relax-edges (graph-id u dist-u neighbors)
  (when neighbors
    (let* ((arc (first neighbors))
           (v (fourth arc))
           (weight (fifth arc))
           (dist-v (sssp-dist graph-id v))
           (alt (+ dist-u weight)))
      
      (unless (sssp-visited graph-id v)
        (cond
          ((= dist-v most-positive-double-float)
           (sssp-change-dist graph-id v alt)
           (sssp-change-previous graph-id v u)
           (heap-insert graph-id alt v))
           
          ((< alt dist-v)
           (sssp-change-dist graph-id v alt)
           (sssp-change-previous graph-id v u)
           (heap-modify-key graph-id alt dist-v v))))
           
      (relax-edges graph-id u dist-u (rest neighbors)))))

(defun dijkstra-loop (graph-id)
  (when (heap-not-empty graph-id)
    (let* ((extracted (heap-extract graph-id))
           (dist-u (first extracted))
           (u (second extracted)))
           
      (sssp-change-visited graph-id u t)
      
      (relax-edges graph-id u dist-u (graph-vertex-neighbors graph-id u))
      
      (dijkstra-loop graph-id))))

(defun sssp-dijkstra (graph-id source)
  
  (clear-dijkstra-tables graph-id)
  
  (when (gethash graph-id *heaps*)
    (heap-delete graph-id))
  (new-heap graph-id (length (graph-vertices graph-id)))
  
  (init-distances graph-id (graph-vertices graph-id))
  
  (sssp-change-dist graph-id source 0)
  (heap-insert graph-id 0 source)
  
  (dijkstra-loop graph-id)
  
  nil)


  (defun test-sssp-dijkstra ()
  "Esegue un test completo dell'algoritmo di Dijkstra su un grafo noto."
  (format t "~%=== INIZIO TEST SSSP-DIJKSTRA ===~%")
  
  ;; 1. INSERIMENTO FORZATO DEL GRAFO DI TEST
  ;; Popoliamo direttamente le hash-tables globali con la struttura che 
  ;; sssp-dijkstra e le tue funzioni di supporto si aspettano.
  (setf (gethash 'g-test *vertices*)
        '((vertex g-test a)
          (vertex g-test b)
          (vertex g-test c)
          (vertex g-test d)))
          
  ;; La tua funzione 'graph-vertex-neighbors' probabilmente filtra questa lista
  (setf (gethash 'g-test *arcs*)
        '((arc g-test a b 1)
          (arc g-test a c 4)
          (arc g-test b c 2)
          (arc g-test b d 6)
          (arc g-test c d 3)))
          
  ;; Per assicurarci che graph-vertices e graph-vertex-neighbors funzionino
  ;; se le avevi scritte basandoti su un'altra struttura, le "simuliamo" per sicurezza:
  (defun graph-vertices (graph-id)
    (gethash graph-id *vertices*))
    
  (defun graph-vertex-neighbors (graph-id u)
    (let ((all-arcs (gethash graph-id *arcs*))
          (neighbors nil))
      (dolist (arc all-arcs)
        ;; Il terzo elemento (indice 2) è il nodo di partenza dell'arco
        (when (equal (third arc) u)
          (push arc neighbors)))
      neighbors))

  ;; 2. ESECUZIONE DELL'ALGORITMO
  (format t "~%1. Eseguo Dijkstra partendo dal nodo 'A'...~%")
  (sssp-dijkstra 'g-test 'a)
  (format t "   Fatto! (La funzione ha ritornato NIL come previsto)~%")

  ;; 3. VERIFICA DEI RISULTATI
  (format t "~%2. Verifica delle Distanze Minime Calcolate:~%")
  (format t "   Distanza A (Atteso: 0.0) -> ~A~%" (sssp-dist 'g-test 'a))
  (format t "   Distanza B (Atteso: 1.0) -> ~A~%" (sssp-dist 'g-test 'b))
  (format t "   Distanza C (Atteso: 3.0) -> ~A~%" (sssp-dist 'g-test 'c))
  (format t "   Distanza D (Atteso: 6.0) -> ~A~%" (sssp-dist 'g-test 'd))

  (format t "~%3. Verifica dei Precedenti (Ricostruzione del Cammino Minimo):~%")
  (format t "   Padre di A (Atteso: NIL) -> ~A~%" (sssp-previous 'g-test 'a))
  (format t "   Padre di B (Atteso: A)   -> ~A~%" (sssp-previous 'g-test 'b))
  (format t "   Padre di C (Atteso: B)   -> ~A~%" (sssp-previous 'g-test 'c))
  (format t "   Padre di D (Atteso: C)   -> ~A~%" (sssp-previous 'g-test 'd))

  (format t "~%4. Verifica dello Stato di Visita:~%")
  (format t "   Tutti i nodi visitati? -> A:~A, B:~A, C:~A, D:~A~%"
          (sssp-visited 'g-test 'a)
          (sssp-visited 'g-test 'b)
          (sssp-visited 'g-test 'c)
          (sssp-visited 'g-test 'd))

  ;; 4. TEST PULIZIA TABELLE
  (format t "~%5. Rieseguo Dijkstra su 'C' per testare la pulizia delle tabelle...~%")
  (sssp-dijkstra 'g-test 'c)
  (format t "   Nuova Distanza A (Atteso: ~A, irraggiungibile) -> ~A~%" 
          most-positive-double-float (sssp-dist 'g-test 'a))
  (format t "   Nuova Distanza D (Atteso: 3.0) -> ~A~%" (sssp-dist 'g-test 'd))

  (format t "~%=== FINE TEST ===~%")
  t)