(provide 'jg-elscreen-buffer-list)
(require 'elscreen)



(defun jg-elscreen-add-buffer-to-list (arg)
  "Add the buffer to the current screen's jg-buffer-list elscreen property"
  (let* ((screen-properties (elscreen-get-screen-property (elscreen-get-current-screen)))
         (jg-buffer-list (get-alist 'jg-buffer-list screen-properties))
         (the-new-buffer (if (stringp arg)
                             (get-buffer arg)
                           arg)
                         ))
    ;;(message (buffer-name the-new-buffer))

    ;; add the new buffer to the list
    (if (null jg-buffer-list)
        (push the-new-buffer jg-buffer-list)
      (add-to-list 'jg-buffer-list the-new-buffer))

    ;; set the elscreen property to the new changed one.
    (set-alist 'screen-properties 'jg-buffer-list jg-buffer-list)
    (elscreen-set-screen-property (elscreen-get-current-screen) screen-properties)
    
    ;; "refresh" the screen/tabs display in the top line
    (elscreen-run-screen-update-hook)
  ))
                           
(defun jg-elscreen-get-buffer-list ()
  "Return the saved list of buffers which have been accessed in this screen"
  (let ((screen-properties (elscreen-get-screen-property (elscreen-get-current-screen))))
    (jg-elscreen-reorder-buffer-list 
     (remove-if-not 'buffer-live-p 
                    (or (get-alist 'jg-buffer-list screen-properties)
                        (list (get-buffer "*scratch*")))))))


;;make ido-switch-buffer (& friends) use my buffer list
(add-hook 'ido-make-buffer-list-hook 
          (lambda () (setq ido-temp-list (mapcar 'buffer-name (jg-elscreen-get-buffer-list)) )))



(defun jg-elscreen-reorder-buffer-list (the-list)
  "Set buffers in NEW-LIST to be the most recently used, in order."
    (ad-deactivate 'buffer-list)
    (setq real-buffer-list (buffer-list))
    (ad-activate 'buffer-list)

    (jg-elscreen-filter-buffer-list the-list real-buffer-list)
    
    )

(defun jg-elscreen-filter-buffer-list (the-list real-buffer-list)
  "Filter the 'real list' (the result of the original (buffer-list) call, which is a c function and returns them in order of 
most recently used) only keeping the ones that are in the-list. The purpose is to effectively sort the-list in order of most 
recently used."
  (delq nil
        (mapcar (lambda (x) 
                  (and 
                   (member (buffer-name x) (mapcar 'buffer-name the-list))
                   x ))
                real-buffer-list)))


;; these two are to add any newly shown buffer to the jg buffer list of the current screen
(defadvice display-buffer (after jg-elscreen-display-buffer-advice activate)
  ;;(message (buffer-name (current-buffer)))
  (jg-elscreen-add-buffer-to-list (current-buffer)))
(defadvice switch-to-buffer (after jg-elscreen-switch-to-buffer-advice activate)
  ;;(message (buffer-name (current-buffer)))
  (jg-elscreen-add-buffer-to-list (current-buffer)))




(defadvice buffer-list (around jg-elscreen-buffer-list activate)
  "make the built-in function (buffer-list) return MY buffer list instead"
  (setq ad-return-value (jg-elscreen-get-buffer-list))
)


(defadvice elscreen-kill (before jg-elscreen-kill-buffers activate)
  "when you kill a screen, kill all the buffers in its list."
  (mapcar '(lambda (b) (kill-buffer b)) (jg-elscreen-get-buffer-list))
  )

(defadvice switch-to-prev-buffer (around jg-elscreen-switch-to-prev-buffer activate) 
"this is for when you kill a buffer. it looks for a buffer to show next. we
want to make sure it only shows one from the list of buffers in the current
screen"
  ;; nth 1 means the 'next' one (the 'first' one is the current one we're closing)
  (let* ((last-buffer (nth 1 (jg-elscreen-get-buffer-list)))
         (the-buffer (or (and (not (eq last-buffer (window-buffer (selected-window))))
                              last-buffer)
                         (get-buffer "*scratch*"))))
    (set-window-buffer (selected-window) the-buffer)
    ))


(defadvice kill-buffer (around jg-elscreen-dont-kill-scratch activate)
  (unless (string= (buffer-name (current-buffer)) "*scratch*")
      ad-do-it)
)


(defadvice ibuffer (around jg-elscreen-turn-off-buffer-list-advice activate)
"turn off the jg buffer-list for this, so I have means to look at them all if I want to."
  (ad-deactivate 'buffer-list)
  ad-do-it
  (ad-activate 'buffer-list)
)





;; these are more low-level commands that didn't end up working out advising them.
;; they are called too many times, all the time, for the minibuffer and echo area buffers, etc.
;; even up to a dozen times or so in a singe keystroke. leaving here for a reminder that they
;; exist in case I ever come back here spelunking.
;; (defadvice set-buffer (after jg-elscreen-set-buffer-advice activate)
;;   (jg-elscreen-add-buffer-to-list (ad-get-arg 0)))

;; (defadvice set-window-buffer (after jg-elscreen-set-window-buffer-advice activate)
;;   (jg-elscreen-add-buffer-to-list (ad-get-arg 1)))

;; (defadvice pop-to-buffer (after jg-elscreen-pop-to-buffer-advice activate)
;;   (jg-elscreen-add-buffer-to-list (ad-get-arg 0)))
