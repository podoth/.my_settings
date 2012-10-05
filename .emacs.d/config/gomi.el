;;; frame-bufs
;;; フレームローカルなbuffer-listを得ることが出来る
;;; iswitchbのデフォの挙動をこれを使うように上書きして、現フレームのバッファリストのみを表示するようにする
;;; これとemacsclientを用いて、マルチプロセスとclientの中間的な動作にする
;;;　一クライアント一フレームの前提でつくってあるのでその制約を破ると動作がおかしいこともある
;;; 最後のクライアントを閉じる時はdaemonごと閉じる
;;;
(require 'frame-bufs)
(frame-bufs-mode t)

;; (setf buffer-list-original 'buffer-list)

;; (defun buffer-list-per-frame (&optional frame)
;;   (interactive)
;;   (letf (((symbol-function 'buffer-list)
;; 	  'buffer-list-original))
;;     (frame-bufs-reset-frame)
;;     (if frame
;; 	(frame-bufs-buffer-list frame)
;;       (frame-bufs-buffer-list nil))))

;; ; iswitchbで自分のフレームのバッファだけ表示する
;; (defun iswitchb-buffer-per-frame ()
;;   (interactive)
;;   (letf (((symbol-function 'buffer-list)
;; 	  (symbol-function 'buffer-list-per-frame)))
;;     (iswitchb-buffer))
;;   )
(defun iswitchb-make-buflist-per-frame (default)
  "Set `iswitchb-buflist' to the current list of buffers.
Currently visible buffers are put at the end of the list.
The hook `iswitchb-make-buflist-hook' is run after the list has been
created to allow the user to further modify the order of the buffer names
in this list.  If DEFAULT is non-nil, and corresponds to an existing buffer,
it is put to the start of the list."
  (setq iswitchb-buflist
        (let* ((iswitchb-current-buffers (iswitchb-get-buffers-in-frames 'current))
               (iswitchb-temp-buflist
		(delq nil
                      (mapcar
                       (lambda (x)
                         (let ((b-name (buffer-name x)))
                           (if (not
                                (or
                                 (iswitchb-ignore-buffername-p b-name)
                                 (memq b-name iswitchb-current-buffers)))
                               b-name)))
                       (frame-bufs-buffer-list (and iswitchb-use-frame-buffer-list
                                         (selected-frame)))))))
          (setq iswitchb-temp-buflist
                (nconc iswitchb-temp-buflist iswitchb-current-buffers))
          (run-hooks 'iswitchb-make-buflist-hook)
         ;; Should this be after the hooks, or should the hooks be the
          ;; final thing to be run?
          (if default
              (progn
                (setq iswitchb-temp-buflist
                      (delete default iswitchb-temp-buflist))
                (setq iswitchb-temp-buflist
                      (cons default iswitchb-temp-buflist))))
          iswitchb-temp-buflist)))

;           iswitchb
(defun iswitchb-buffer-per-frame ()
  (interactive)
  (letf (((symbol-function 'iswitchb-make-buflist)
	  (symbol-function 'iswitchb-make-buflist-per-frame)))
    (iswitchb-buffer))
  )
(global-set-key "\C-xb" 'iswitchb-buffer-per-frame)
(global-set-key "\C-x\C-\M-b" 'iswitchb-buffer)


; 終了時に自分のフレームのバッファだけ保存するか問い合わせる
; 最後のフレームの場合emacs-serverを終了し、全てのバッファについて問い合わせる
(defun save-some-buffers-per-frame (&optional arg pred)
  "Save some modified file-visiting buffers.  Asks user about each one.
You can answer `y' to save, `n' not to save, `C-r' to look at the
buffer in question with `view-buffer' before deciding or `d' to
view the differences using `diff-buffer-with-file'.

Optional argument (the prefix) non-nil means save all with no questions.
Optional second argument PRED determines which buffers are considered:
If PRED is nil, all the file-visiting buffers are considered.
If PRED is t, then certain non-file buffers will also be considered.
If PRED is a zero-argument function, it indicates for each buffer whether
to consider it or not when called with that buffer current.

See `save-some-buffers-action-alist' if you want to
change the additional actions you can take on files."
  (interactive "P")
  (save-window-excursion
    (let* (queried some-automatic
	   files-done abbrevs-done)
      (dolist (buffer (frame-bufs-buffer-list nil))
	;; First save any buffers that we're supposed to save unconditionally.
	;; That way the following code won't ask about them.
	(with-current-buffer buffer
	  (when (and buffer-save-without-query (buffer-modified-p))
	    (setq some-automatic t)
	    (save-buffer))))
      ;; Ask about those buffers that merit it,
      ;; and record the number thus saved.
      (setq files-done
	    (map-y-or-n-p
	     (function
	      (lambda (buffer)
		(and (buffer-modified-p buffer)
		     (not (buffer-base-buffer buffer))
		     (or
		      (buffer-file-name buffer)
		      (and pred
			   (progn
			     (set-buffer buffer)
			     (and buffer-offer-save (> (buffer-size) 0)))))
		     (or (not (functionp pred))
			 (with-current-buffer buffer (funcall pred)))
		     (if arg
			 t
		       (setq queried t)
		       (if (buffer-file-name buffer)
			   (format "Save file %s? "
				   (buffer-file-name buffer))
			 (format "Save buffer %s? "
				 (buffer-name buffer)))))))
	     (function
	      (lambda (buffer)
		(set-buffer buffer)
		(save-buffer)))
	     (frame-bufs-buffer-list nil)
	     '("buffer" "buffers" "save")
	     save-some-buffers-action-alist))
      ;; Maybe to save abbrevs, and record whether
      ;; we either saved them or asked to.
      (and save-abbrevs abbrevs-changed
	   (progn
	     (if (or arg
		     (eq save-abbrevs 'silently)
		     (y-or-n-p (format "Save abbrevs in %s? "
				       abbrev-file-name)))
		 (write-abbrev-file nil))
	     ;; Don't keep bothering user if he says no.
	     (setq abbrevs-changed nil)
	     (setq abbrevs-done t)))
      (or queried (> files-done 0) abbrevs-done
	  (message (if some-automatic
		       "(Some special files were saved without asking)"
		     "(No files need saving)"))))))

(defun delete-frame-and-kill-emacs ()
  "delete frame and if(last client) kill-emacs"
  (interactive)
  (if (frame-parameter (selected-frame) 'client)
      (progn
	(if (equal 1 (length server-clients))
	    (save-some-buffers)
	  (save-some-buffers-per-frame))
	(delete-frame)
	(when (equal 0 (length server-clients))
	  (kill-emacs))
	)
    (save-buffers-kill-terminal))　; clientではなく通常起動時には普通の終了方法
  )

(global-set-key [(control x)(control c)] 'delete-frame-and-kill-emacs)
;TODO:kill-bufferをframe-bus-dismiss-bufferで置き換える


