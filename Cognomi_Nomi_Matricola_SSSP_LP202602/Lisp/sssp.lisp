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
  (format t "=== GRAFO: ~S ===~%" graph-id)
  

  (format t "Vertici:~%")
  (let ((verts (graph-vertices graph-id)))
    (if verts
        (dolist (v verts)
          (format t "  ~S~%" v))
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

