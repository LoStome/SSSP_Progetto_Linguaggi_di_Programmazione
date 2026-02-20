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