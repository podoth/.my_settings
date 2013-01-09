;;;
;;; 一個のファイルにするには小さすぎるlisp達
;;; コピペと自作が混在
;;;

;;;
;;; 開いているファイルをリネーム
;;;
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
    (filename (buffer-file-name)))
    (if (not filename)
    (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
      (message "A buffer named '%s' already exists!" new-name)
    (progn
      (rename-file name new-name 1)
      (rename-buffer new-name)
      (set-visited-file-name new-name)
      (set-buffer-modified-p nil))))))
(global-set-key [(control c)(control t)]	'rename-file-and-buffer)

;;;
;;; .emacsを読み直す
;;; switch系のもののために二回読む
;;;
(defun reload-emacs-settings ()
  "Reload ~/.emacs"
  (interactive)
  (load-file "~/.emacs")
  (load-file "~/.emacs"))
(global-set-key [(control c)(control e)]	'reload-emacs-settings)

;;;
;;; jump window with C-,
;;; switch buffer with C-M-,
;;;
(defun other-window-or-split ()
  (interactive)
  (when (one-window-p)(split-window-horizontally))
  (other-window 1))
(global-set-key (kbd "C-,") 'other-window-or-split)
(global-set-key (kbd "C-M-,") 'next-buffer)

;;;
;;; open file as root
;;; read-onlyファイルを開くときにtrampを使いrootで開くか尋ねる
;;;
(defun th-rename-tramp-buffer ()
  (when (file-remote-p (buffer-file-name))
    (rename-buffer
     (format "%s:%s"
             (file-remote-p (buffer-file-name) 'method)
             (buffer-name)))))

(add-hook 'find-file-hook
          'th-rename-tramp-buffer)

(defadvice find-file (around th-find-file activate)
  "Open FILENAME using tramp's sudo method if it's read-only."
  (if (and (not (file-writable-p (ad-get-arg 0)))
           (y-or-n-p (concat "File "
                             (ad-get-arg 0)
                             " is read-only.  Open it as root? ")))
      (th-find-file-sudo (ad-get-arg 0))
    ad-do-it))

(defun th-find-file-sudo (file)
  "Opens FILE with root privileges."
  (interactive "F")
  (set-buffer (find-file (concat "/sudo::" file))))

;;;
;;; 現在のバッファのファイルを任意のコマンドで開く（デフォルトはgedit）
;;;
(defun open-with-command ()
  "open with gedit"
  (interactive)
  (setq command-string (read-from-minibuffer "Command:" "gedit"))
  (shell-command (concat command-string " " (buffer-file-name))))
(global-set-key [(control c)(control c)]	'open-with-command)


;;;
;;; プリント用コマンド
;;; http://www-section.cocolog-nifty.com/blog/2008/11/emacs-b4fb.html
;;;
(setq my-print-command-format "nkf -e | e2ps -a4 -p -nh | lpr -P ")
(defun my-print-region (begin end)
   (interactive "r")
   (setq printer-string (read-from-minibuffer "Printer:" "atlas"))
   (shell-command-on-region begin end (concat my-print-command-format printer-string)))
(defun my-print-buffer ()
   (interactive)
   (my-print-region (point-min) (point-max)))

;;;
;;; kill-ringに保存しないkill-line
;;;
(defun delete-line () "delete line, take it out of kill ring. bind this func to C-z"
 (interactive)
 (setq last-command 'delete-line)
 (kill-line)
 (setq kill-ring (cdr kill-ring))
 (setq kill-ring-yank-pointer kill-ring)
 (setq last-command 'delete-line)
)
(global-set-key [(control K)]	'delete-line)

;;;
;;; M-wと同じだけど、コピー後にリージョンを消さない
;;;
(defun my-copy-region-as-kill (beg end)
       "Save the region as if killed, but don't kill it.
     In Transient Mark mode, deactivate the mark.
     If `interprogram-cut-function' is non-nil, also save the text for a window
     system cut and paste."
       (interactive "r")
       (if (eq last-command 'kill-region)
           (kill-append (filter-buffer-substring beg end) (< end beg))
         (kill-new (filter-buffer-substring beg end)))
       nil)
(global-set-key [(control meta w)]	'my-copy-region-as-kill)

;;;
;;; カーソル位置の単語を削除
;;;
(defun kill-word-at-point ()
      (interactive)
      (let ((char (char-to-string (char-after (point)))))
        (cond
         ((string= " " char) (delete-horizontal-space))
         ((string-match "[\t\n -@\[-`{-~]" char) (kill-word 1))
         (t (forward-char) (backward-word) (kill-word 1)))))
(global-set-key "\M-d" 'kill-word-at-point)



;;;
;;; 範囲指定していない時、C-wで前の単語を削除
;;;
(defadvice kill-region (around kill-word-or-kill-region activate)
  (if (and (interactive-p) transient-mark-mode (not mark-active))
      (backward-kill-word 1)
    ad-do-it))
;; minibuffer用
(define-key minibuffer-local-completion-map "\C-w" 'backward-kill-word)



(setq auto-clear-buffer-name (list "*Messages*" "*Completions*"))
(defun clear-temp-buffers()
  "登録された一時バッファを削除"
  (interactive)
  (let ((fn))
    (dolist (bf (buffer-list))
      (setq fn (buffer-name bf))
      (when (member fn auto-clear-buffer-name)
	(progn	  (kill-buffer fn)
		  (print fn)))
      )
    )
  )

;;;
;;; 句読点を論文スタイルに変換
;;;
(defun replace-kutoten ()
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (replace-string "、" "，" )
    (replace-string "。" "．" ))
)

;;;
;;; yank時にIndentもする
;;;
;; (defun yank-and-indent ()
;;   "Yank and then indent the newly formed region according to mode."
;;   (interactive)
;;   (yank)
;;   (call-interactively 'indent-region))
;; (global-set-key [(control Y)]	'yank-and-indent)


;;;
;;; region内の検索と関数内の検索
;;; http://www.jaist.ac.jp/~n-yoshi/tips/elisp_tips.html#cskip
;;;
(defun my-search-region (point str flag)
  (and (integerp point)
       (not (string= str ""))
       (if (and (<= my-region-beginning point)
		(<= point my-region-end))
	   flag (not flag))))

(defun my-search-defun (point str flag)
  (and (integerp point)
       (not (string= str ""))
       (if (and (<= my-defun-beginning point)
		(<= point my-defun-end))
	   flag (not flag))))


;; リージョン内以外を無視する (re-)search-forward(-regexp)
(defadvice search-forward (around my-region-only disable)
  (while (my-search-region ad-do-it (ad-get-arg 0) nil)))
(defadvice search-forward-regexp (around my-region-only disable)
  (while (my-search-region ad-do-it (ad-get-arg 0) nil)))
(defadvice re-search-forward (around my-region-only disable)
  (while (my-search-region ad-do-it (ad-get-arg 0) nil)))
;; 関数内以外を無視する (re-)search-forward(-regexp)
(defadvice search-forward (around my-defun-only disable)
  (while (my-search-defun ad-do-it (ad-get-arg 0) nil)))
(defadvice search-forward-regexp (around my-defun-only disable)
  (while (my-search-defun ad-do-it (ad-get-arg 0) nil)))
(defadvice re-search-forward (around my-defun-only disable)
  (while (my-search-defun ad-do-it (ad-get-arg 0) nil)))
(defadvice search-backward (around my-defun-only disable)
  (while (my-search-defun ad-do-it (ad-get-arg 0) nil)))
(defadvice search-backward-regexp (around my-defun-only disable)
  (while (my-search-defun ad-do-it (ad-get-arg 0) nil)))
(defadvice re-search-backward (around my-defun-only disable)
  (while (my-search-defun ad-do-it (ad-get-arg 0) nil)))


(fset 'isearch-forward-region 'isearch-forward)
(fset 'isearch-forward-defun 'isearch-forward)
(fset 'isearch-backward-defun 'isearch-backward)

;; isearch-forward (migemo-forward) が内部で使っている search-forward
;; (search-forward-regexp, re-search-forward) を変更
(defadvice isearch-forward-region (before my-ad-activate activate)
  (defvar my-region-beginning (region-beginning))
  (defvar my-region-end (region-end))
  (deactivate-mark)
  (mapcar
   (lambda (x) (ad-enable-advice x 'around 'my-region-only) (ad-activate x))
   (list 'search-forward 'search-forward-regexp 're-search-forward)))

(defadvice isearch-forward-defun (before my-ad-activate activate)
  (save-excursion 
    (c-beginning-of-defun)
    (defvar my-defun-beginning (point))
    (c-end-of-defun)
    (defvar my-defun-end (point)))
  (mapcar
   (lambda (x) (ad-enable-advice x 'around 'my-defun-only) (ad-activate x))
   (list 'search-forward 'search-forward-regexp 're-search-forward 'search-backward 'search-backward-regexp 're-search-backward)))

(defadvice isearch-backward-defun (before my-ad-activate activate)
  (save-excursion 
    (c-beginning-of-defun)
    (defvar my-defun-beginning (point))
    (c-end-of-defun)
    (defvar my-defun-end (point)))
  (mapcar
   (lambda (x) (ad-enable-advice x 'around 'my-defun-only) (ad-activate x))
   (list 'search-forward 'search-forward-regexp 're-search-forward 'search-backward 'search-backward-regexp 're-search-backward)))


(add-hook 'isearch-mode-end-hook
          (lambda ()
            (mapcar
             (lambda (x)
               (ad-deactivate x)
               (ad-disable-advice x 'around 'my-region-only)
               (ad-disable-advice x 'around 'my-defun-only)
               (ad-activate x))
             (list 'search-forward 'search-forward-regexp 're-search-forward))))
(add-hook 'isearch-mode-end-hook
          (lambda ()
            (mapcar
             (lambda (x)
               (ad-deactivate x)
               (ad-disable-advice x 'around 'my-defun-only)
               (ad-activate x))
             (list 'search-backward 'search-backward-regexp 're-search-backward))))

;; region内検索は結局使ってない
(add-hook
 'c-mode-common-hook
 '(lambda ()
    (define-key c-mode-map (kbd "C-c C-s") 'isearch-forward-defun)
    (define-key c-mode-map (kbd "C-c C-r") 'isearch-backward-defun)))

