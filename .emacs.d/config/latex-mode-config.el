;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; builtin
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; flymake
;;;
(when (executable-find "platex")
  (progn
    (require 'flymake)

    ;; for latex
    (defun flymake-tex-init ()
      (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                           'flymake-create-temp-inplace))
             (local-dir   (file-name-directory buffer-file-name))
             (local-file  (file-relative-name
                           temp-file
                           local-dir)))
        (list "platex" (list "-file-line-error" "-interaction=nonstopmode" local-file))))
    (defun flymake-tex-cleanup-custom ()
      (let* ((base-file-name (file-name-sans-extension (file-name-nondirectory flymake-temp-source-file-name)))
             (regexp-base-file-name (concat "^" base-file-name "\\.")))
        (mapcar '(lambda (filename)
                   (when (string-match regexp-base-file-name filename)
                     (flymake-safe-delete-file filename)))
                (split-string (shell-command-to-string "ls"))))
      (setq flymake-last-change-time nil))
    (push '("\\.tex$" flymake-tex-init flymake-tex-cleanup-custom) flymake-allowed-file-name-masks)

    (add-hook
     'TeX-mode-hook
     '(lambda ()
        (flymake-mode t)
        (define-key LaTeX-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)))
    ))

;;;
;;; flyspell
;;;
(setq ispell-program-name "aspell")
(when (executable-find ispell-program-name)
  (progn
    (setq ispell-grep-command "grep")
    (setq flyspell-issue-welcome-flag nil)
    ;; 日本語はスキップするようにする
    (eval-after-load "ispell"
      '(add-to-list 'ispell-skip-region-alist '("[^\000-\377]")))
    (defun my-turn-on-flyspell ()
      (flyspell-mode)
      ;; 前後の日本語を巻き込んで強調しないようにする
      ;; http://www.morishima.net/~naoto/fragments/archives/2005/12/20/flyspell/
      (setq ispell-local-dictionary-alist
            '((nil "[a-zA-Z]" "[^a-zA-Z]" "'" t ("-d" "en" "--encoding=utf-8") nil utf-8)))
      ;; このキーバインドは使わない上に他のとかぶる
      (define-key flyspell-mode-map [(control ?\,)] nil)
      (define-key flyspell-mode-map [(control ?\.)] nil))
    (add-hook 'TeX-mode-hook 'my-turn-on-flyspell)
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; package
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; auctex
;;;
(when linux-p
  (setq load-path (cons "~/.emacs.d/packages/auctex" load-path))
  (load "~/.emacs.d/packages/auctex/auctex")
  (require 'tex-jp))
(when windows-p
  (setq load-path (cons "~/.emacs.d/packages/auctex-win" load-path))
  (setq load-path (cons "~/.emacs.d/packages/auctex-win/site-start.d" load-path))
  (setq load-path (cons "~/.emacs.d/packages/auctex-win/auctex" load-path))
  (load "~/.emacs.d/packages/auctex-win/site-start.d/auctex")
  (require 'tex-jp))

(setq TeX-japanese-process-input-coding-system  'japanese-iso-8bit
      TeX-japanese-process-output-coding-system 'iso-2022-jp
      LaTeX-version			"2e"
      japanese-LaTeX-default-style	"jarticle"
      TeX-default-mode			'japanese-latex-mode
      TeX-force-default-mode		t
      LaTeX-top-caption-list		'("table" "tabular")
      TeX-command-default		"pLaTeX"
      TeX-parse-self			t
      japanese-LaTeX-command-default	"pLaTeX"
      LaTeX-float			"tn"
      LaTeX-figure-label		"fig:"
      LaTeX-table-label			"tab:"
      LaTeX-section-label		"sec:")
;; (when (not (shell-command "which pxdvi"))
;;   (setq TeX-output-view-style '(("^dvi$" "." "pxdvi %d"))))

(eval-after-load "auctex"
  '(when window-system
     (require 'font-latex)))

;;;
;;; bibtex
;;;
(setq bib-bibtex-env-variable		"TEXMFHOME")
(autoload 'turn-on-bib-cite "bib-cite")
(add-hook 'LaTeX-mode-hook 'turn-on-bib-cite)

;;;
;;; reftex
;;;
(setq reftex-texpath-environment-variables	'("TEXMFHOME")
      reftex-bibpath-environment-variables	'("~/texmf//")
      reftex-plug-into-AUCTeX			t
      reftex-label-alist
      '(("figure"       ?F "fig:" "\\figref{%s}" caption nil)
	("figure*"      ?F nil nil caption)
	("table"        ?T "tab:" "\\tabref{%s}" caption nil)
	("table*"       ?T nil nil caption)))
(autoload 'reftex-mode     "reftex" "RefTeX Minor Mode" t)
(autoload 'turn-on-reftex  "reftex" "RefTeX Minor Mode" nil)
(autoload 'reftex-citation "reftex-cite" "Make citation" nil)
(autoload 'reftex-index-phrase-mode "reftex-index" "Phrase mode" t)
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)   ; with AUCTeX LaTeX mode

;;;
;;; プレビュー
;;;
(when linux-p
  (setq load-path (cons "~/.emacs.d/packages/auctex/preview" load-path)))
(when windows-p
  (setq load-path (cons "~/.emacs.d/packages/auctex-win/site-start.d" load-path)))
(require 'preview-latex)


;;;
;;; outline-minor-mode
;;;
(add-hook 'LaTeX-mode-hook '(lambda () (outline-minor-mode t)
			      (local-set-key [(meta n)] 'outline-next-visible-heading)
			      (local-set-key [(meta p)] 'outline-previous-visible-heading)))

;;; xdviの設定
;; (setq TeX-output-view-style '(("^dvi$" "." "pxdvi %d")))
;; (eval-after-load "tex" '(progn
;;   (setq TeX-view-program-list
;;         (list (assoc "xdvi" TeX-view-program-list-builtin)))
;;   (setcar (cadr (assoc "xdvi"  TeX-view-program-list))
;;           "%(o?)pxdvi")))

;;;
;;;分割コンパイル可能に
;;;
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

;;;
;;; 邪魔なキーバインドを排除
;;;
(define-key TeX-mode-map "\C-c\C-w" 'nil)
(define-key LaTeX-mode-map "\C-c\C-j" 'nil)

;;;
;;; Grammar
;;;
(require 'grammar)
(copy-face 'my-info-face 'grammar-error-face)
(add-hook 'LaTeX-mode-hook 'turn-on-grammar)

(defun grammar-check-region (start end)
  (interactive (list (point) (mark)))
  (save-excursion
    (goto-char start)
    (while (<= (point) end)
      (forward-sentence)
      (when (and (grammar-sentence-end-char-p)
                 (grammar-sentence-english-p))
        (grammar-check)))))
(global-set-key (kbd "C-z") 'grammar-check-region)
(defun grammar-check-buffer ()
  (interactive)
  (grammar-check-region (point-min) (point-max)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; for require/autoload
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun LaTeX-mode-config () (LaTeX-mode))
(provide 'LaTeX-mode-config)
