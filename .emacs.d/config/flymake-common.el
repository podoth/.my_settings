;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; builtin
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; flymake
;;;
(require 'flymake)

;; 色設定
(copy-face  'my-error-face 'flymake-errline)
(copy-face  'my-warning-face 'flymake-warnline)
;; エラーをミニバッファに表示
(defun credmp/flymake-display-err-minibuf ()
  (interactive)
  (message (mapconcat '(lambda (line-err-info)
			 (format "[%s] %s"
				 (flymake-ler-line line-err-info)
				 (flymake-ler-text line-err-info)))
		      (car (flymake-find-err-info flymake-err-info
						  (flymake-current-line-no)))
		      "\n")))
(add-hook 'flymake-mode-hook (lambda () (local-set-key "\C-cd" 'credmp/flymake-display-err-minibuf)))

;; M-p/M-n で警告/エラー行の移動
(global-set-key "\M-p" 'flymake-goto-prev-error)
(global-set-key "\M-n" 'flymake-goto-next-error)

;; 警告を青色にする（flymakeのVersion 0.3の正規表現を修正）
;; さらに、noteをエラーにしないようにする
(defun flymake-parse-line (line)
  "Parse LINE to see if it is an error or warning.
Return its components if so, nil otherwise."
  (let ((raw-file-name nil)
	(line-no 0)
	(err-type "e")
	(err-text nil)
	(patterns flymake-err-line-patterns)
	(matched nil))
    (while (and patterns (not matched))
      (when (string-match (car (car patterns)) line)
	(let* ((file-idx (nth 1 (car patterns)))
	       (line-idx (nth 2 (car patterns))))

	  (setq raw-file-name (if file-idx (match-string file-idx line) nil))
	  (setq line-no       (if line-idx (string-to-number (match-string line-idx line)) 0))
	  (setq err-text      (if (> (length (car patterns)) 4)
				  (match-string (nth 4 (car patterns)) line)
				(flymake-patch-err-text (substring line (match-end 0)))))
	  (or err-text (setq err-text "<no error text>"))
	  (if (and err-text (string-match "[wW]arning\\|警告" err-text))
	      (setq err-type "w")
	    )
	  (if (and err-text (string-match "[nN]ote" err-text))
	      (setq err-type "i")
	    )
	  (flymake-log 3 "parse line: file-idx=%s line-idx=%s file=%s line=%s text=%s" file-idx line-idx
		       raw-file-name line-no err-text)
	  (setq matched t)))
      (setq patterns (cdr patterns)))
    (if matched
	(flymake-ler-make-ler raw-file-name line-no err-type err-text)
      ())))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; package
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; helm-flymake
;;;
(autoload 'helm-flymake "helm-flymake")
(global-set-key (kbd "C-c e") 'helm-flymake)
