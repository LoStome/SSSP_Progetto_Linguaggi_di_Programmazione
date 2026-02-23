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
  (format t "=== GRAFO: ~S ~%" graph-id)
  

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
        
        (format t "Array fisico completo: ~S~%" array)
        (format t "---~%")
        
        t)
        
      (progn
        (format t "Lo heap ~S non esiste o e' gia' stato eliminato~%" heap-id)
        nil))))

