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
              
               (when (and (listp key) (equal (second key) graph-id))
                
                 (remhash key hash-table)))
             hash-table))          
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


;; ==========================================
;; SCRIPT DI TEST PER CREAZIONE ARCHI (LAZY)
;; Esegui dalla REPL digitando: (test-lazy-arc)
;; ==========================================

(defun test-lazy-arc ()
  (format t "--- INIZIO TEST NEW-ARC (LAZY INITIALIZATION) ---~%")
  
  ;; 1. Setup: partiamo da un ambiente pulito
  (format t "1. Pulizia ambiente (elimino 'lazy-map se esiste)...~%")
  (delete-graph 'lazy-map)
  
  ;; 2. Creazione diretta dell'arco! NESSUN GRAFO O VERTICE CREATO PRIMA.
  (format t "2. Eseguo (new-arc 'lazy-map 'milano 'roma 500)...~%")
  (let ((arc-result (new-arc 'lazy-map 'milano 'roma 500)))
    (format t "   -> Arco restituito: ~S~%" arc-result)
    (format t "   -> (Atteso: (ARC LAZY-MAP MILANO ROMA 500))~%~%"))
    
  ;; 3. VERIFICA LA MAGIA: Il grafo esiste?
  (format t "3. Controllo se il grafo 'lazy-map e' stato creato da solo...~%")
  (format t "   -> (is-graph 'lazy-map) = ~S (Atteso: LAZY-MAP)~%" 
          (is-graph 'lazy-map))
          
  ;; 4. VERIFICA LA MAGIA: I vertici esistono?
  (format t "~%4. Controllo se i vertici sono stati creati da soli...~%")
  (multiple-value-bind (v-milano exists-m) (gethash '(vertex lazy-map milano) *vertices*)
    (format t "   -> Vertice MILANO esiste? ~S (Atteso: T)~%" exists-m))
    
  (multiple-value-bind (v-roma exists-r) (gethash '(vertex lazy-map roma) *vertices*)
    (format t "   -> Vertice ROMA esiste? ~S (Atteso: T)~%" exists-r))
    
  ;; 5. VERIFICA LA MAGIA: L'arco è stato registrato?
  (format t "~%5. Controllo se l'arco e' registrato nella tabella *arcs*...~%")
  (multiple-value-bind (a-val exists-a) (gethash '(arc lazy-map milano roma 500) *arcs*)
    (format t "   -> Arco registrato? ~S (Atteso: T)~%" exists-a))
    
  ;; 6. Pulizia finale
  (format t "~%6. Pulizia finale della memoria...~%")
  (delete-graph 'lazy-map)
  
  (format t "--- FINE TEST ---~%")
  t)