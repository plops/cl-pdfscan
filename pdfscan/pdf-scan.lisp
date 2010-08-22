(time (defparameter s
   (with-output-to-string (stream)
     (sb-ext:run-program 
      "/bin/bash" '("-c" 
		    "find /home/martin|egrep /p[0-1][0-9][0-9][0-9]/|grep pdf")
      :output stream))))

(defun read-lines (stream)
  (loop with line 
     while (setf line (read-line stream nil nil)) collect
     line))

(defparameter pdf-list
 (with-input-from-string (stream s)
   (read-lines stream)))

(time
 (defparameter fulltexts
   (loop for filename in pdf-list collect
	(progn
	  (format t "~a~%" filename)
	 (list filename
	      
	       (progn
		 (sb-ext:run-program "/usr/bin/pdfinfo" 
				     (list "-meta" "-box" filename)
				     :output "/dev/shm/o" 
				     :if-output-exists :supersede)
		 (with-open-file (s "/dev/shm/o"
				    :external-format :latin-1)
		   (read-lines s)))
	       
	       (progn
		 (sb-ext:run-program "/usr/bin/pdftotext" 
				     (list "-enc" "Latin1"
					   filename "/dev/shm/o"))
		 (with-open-file (s "/dev/shm/o"
				    :external-format :latin-1)
		   (read-lines s)))
	       )))))

(time
 (with-open-file (s "/home/martin/0821/fulltexts" :direction :output
		    :if-exists :supersede :if-does-not-exist :create)
   (write fulltexts :stream s)))
