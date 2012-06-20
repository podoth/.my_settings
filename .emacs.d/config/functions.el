;;;
;;; 開いているファイルをリネーム
;;; C-c C-r
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
(global-set-key [(control c)(control r)]	'rename-file-and-buffer)

;;;
;;; .emacsを読み直す
;;;
(defun reload-emacs-settings ()
  "Reload ~/.emacs"
  (interactive)
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