;; WORKTIME.EL v1.1
;; (c) E. Choroba 2003-06

(defvar worktime-file
  "~/.worktime"

"File to be used by worktime. ~/.worktime by default."
)

(define-minor-mode worktime-minor-mode
  "Worktime minor mode."
  :init-value t
  :lighter worktime-modeline
  )

(setq worktime-minor-mode-hook '(worktime-set-modeline))

(defun worktime-set-modeline ()
  (setq worktime-modeline 
        (shell-command-to-string 
         (concat "echo -n `worktime -s -f " worktime-file "|grep since|cut -d'[' -f1`" )))
  (if (> (length worktime-modeline) 0)
      (setq worktime-modeline (concat " {🔨" worktime-modeline "} ")))
  )

(defun worktime-list ()
  (eval 
   (read 
    (shell-command-to-string
     (concat "if [[ -e ~/.worktime ]] ; then echo -en \"'\"'('`worktime -l -f " worktime-file "| sed 's/$/\042 1)/;s/^/(\042/'`')';else echo \042'()\042;fi"
     )))
    ))

(defun worktime-list-in ()
  (eval 
   (read 
    (shell-command-to-string
     (concat "echo -n '`(';echo -en `worktime -s -f " worktime-file "| sed '1 c\\ '|sed 's/\\([^\\[]\\+\\) \\[.*/(\042\\1\042 1)/'`;echo -n ')'"))
    )))

(defun worktime-in (project &optional comment)
  "Check in to work on project."
  (interactive
   (list
    (completing-read
     "Project: " 
     (worktime-list))
    (read-string "Comment: "))
   )
  (shell-command 
   (concat "worktime -f " worktime-file " -i'" project "'"
           (if (> (length comment) 0)
               (concat " -c'" comment "'")
             ))
   )
  (worktime-set-modeline)
  (setq worktime-minor-mode t)
    )

(defun worktime-out (project &optional comment)
  "Check out from work on project (project not needed if only one is running)."
  (interactive
   (list
    (completing-read
     "Project: " 
     (worktime-list-in))
    (read-string "Comment: "))
   )
  (shell-command 
   (concat "worktime -f " worktime-file " "
           (if (> (length comment) 0)
               (concat " -c'" comment "'"))
           " -o'" project "'"
           )
   )
  (worktime-set-modeline)
  (setq worktime-minor-mode t)
  )

(defun worktime-change (project &optional comment)
  "Close all projects and check in the new one if specified."
  (interactive
   (list
    (completing-read
     "Project: " 
     (worktime-list))
    (read-string "Comment: "))
   )
  (shell-command 
   (concat "worktime -f " worktime-file
           (if (> (length comment) 0)
               (concat " -c'" comment "'")
             )
           " -x'" project "'")
   )
  (worktime-set-modeline)
  (setq worktime-minor-mode t)
  )

(defun worktime-report ()
  "Generate report of total working time."
  (interactive)
  (shell-command 
   (concat "worktime -f " worktime-file " -r" )
   (switch-to-buffer "Worktime Report")
   ))

(defun worktime-status ()
  "Show checked-in projects."
  (interactive)
  (shell-command (concat "worktime -f " worktime-file " -s"))
)

(defun worktime-visit-file ()
  "Visit the file used by worktime in a buffer."
  (interactive)
  (find-file worktime-file)
)

(worktime-set-modeline)
