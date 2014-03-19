;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; builtin
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; find-fileで無視するファイル追加
;;;
(setq completion-ignored-extensions (append completion-ignored-extensions '(".synctex.gz")))

;;;
;;; flymake
;;;
(when (executable-find "platex")
  (progn
    (require 'flymake)

    ;; 複数ファイル設定していると、platexの出力をパースしきれずにエラーになる
    ;; egrepにパイプして余計な出力を取り除く
    ;; platex -file-line-error -interaction=nonstopmode $1|egrep ".+:.+:.+"
    (defun flymake-get-tex-args (file-name)
      ;; (list "platex" (list "-file-line-error" "-interaction=nonstopmode" file-name)))
      (list "~/.emacs.d/etc/flymake-platex.sh" (list file-name)))

    ;; クリーンアップ用関数を賢くする
    (defun flymake-clean-latex-files (file-name)
      (let* ((base-file-name (file-name-sans-extension (file-name-nondirectory file-name)))
             (regexp-base-file-name (concat "^" base-file-name "\\.")))
        (mapcar '(lambda (filename)
                   (when (string-match regexp-base-file-name filename)
                     (flymake-safe-delete-file filename)))
                (split-string (shell-command-to-string "ls")))))

    (defun flymake-tex-cleanup-custom ()
      (flymake-clean-latex-files flymake-temp-source-file-name)
      (setq flymake-last-change-time nil))

    (push '("\\.tex$" flymake-simple-tex-init flymake-tex-cleanup-custom) flymake-allowed-file-name-masks)

    ;; 複数ファイルに分けたtexファイルの扱いが上手く行かないようなので、改めて設定しなおす
    ;; 先頭が数字またはsub_で始まるファイルは子ファイルと見なすようにする
    ;; また、クリーンアップ用関数を賢くする
    (defun flymake-master-cleanup-custom ()
      (flymake-clean-latex-files flymake-temp-source-file-name)
      (flymake-clean-latex-files flymake-temp-master-file-name)
      (setq flymake-last-change-time nil))
    (push '("[0-9]+.*\\.tex$" flymake-master-tex-init flymake-master-cleanup-custom) flymake-allowed-file-name-masks)
    (push '("sub_.*\\.tex$" flymake-master-tex-init flymake-master-cleanup-custom) flymake-allowed-file-name-masks)

    ;; masterファイルの\include{0-title} を \include{0-title_flymake.tex} に変換してしまうバグがある
    ;; \include{0-title_flymake}にするようにする
    (defadvice flymake-check-patch-master-file-buffer (before deal-include-command activate)
      ""
      (when (string-equal (file-name-extension (ad-get-arg 4)) "tex")
        (ad-set-arg 4 (file-name-sans-extension (ad-get-arg 4)))))

    ;; hook設定
    (add-hook 'TeX-mode-hook 'flymake-mode)
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

(eval-after-load "auctex"
  '(when window-system
     (require 'font-latex)))

;; autoディレクトリの名前を変える
(setq TeX-auto-local ".auctex")
;; latexmkへの対応
(require 'auctex-latexmk)
(auctex-latexmk-setup)
(add-hook 'TeX-mode-hook
          (function (lambda () (setq TeX-command-default "LatexMk"))))
;; pdfモード
(add-hook 'LaTeX-mode-hook 'TeX-PDF-mode)
(add-hook 'LaTeX-mode-hook 'TeX-source-correlate-mode)
;; View時のフォーカスを変更しないようにする
(defun focus-emacs ()
  (call-process-shell-command (format "xdotool windowactivate `xdotool search --onlyvisible --pid %d --name emacs`" (emacs-pid))))

(when (executable-find "xdotool")
  (defadvice TeX-evince-sync-view (after return-focus activate)
    "Viewの後にフォーカスが戻ってくるようにする"
    (focus-emacs))
  ;; (defadvice TeX-view (after return-focus activate)
  ;;   "Viewの後にフォーカスが戻ってくるようにする"
  ;;   (focus-emacs))
  )


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
      reftex-plug-into-AUCTeX			t)
(setq reftex-label-alist
      '(
        ("section" ?s "%S" "~\\secref{%s}" (nil . t)
         (regexp "parts?""chapter" "chap." "sections?" "sect?\\." "paragraphs?" "par\\." "\\\\S" "\247" "Teile?" "Kapitel" "Kap\\." "Abschnitte?" "appendi\\(x\\|ces\\)" "App\\." "Anh\"?ange?" "Anh\\."))
        ("figure" ?f "fig:" "~\\ref{%s}" caption
         (regexp "figure?[sn]?" "figs?\\." "Abbildung\\(en\\)?" "Abb\\."))
        ("figure*" ?f nil nil caption)
        ("table" ?t "tab:" "~\\ref{%s}" caption
         (regexp "tables?" "tab\\." "Tabellen?"))
        ("table*" ?t nil nil caption)
        ))
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
(eval-after-load "reftex"
  '(define-key reftex-mode-map "\C-c/" 'nil))

;;;
;;; Grammar
;;;
;; (require 'grammar)
;; (copy-face 'my-info-face 'grammar-error-face)
;; (add-hook 'LaTeX-mode-hook 'turn-on-grammar)

;; (defun grammar-check-region (start end)
;;   (interactive (list (point) (mark)))
;;   (save-excursion
;;     (goto-char start)
;;     (while (<= (point) end)
;;       (forward-sentence)
;;       (when (and (grammar-sentence-end-char-p)
;;                  (grammar-sentence-english-p))
;;         (grammar-check)))))
;; (global-set-key (kbd "C-z") 'grammar-check-region)
;; (defun grammar-check-buffer ()
;;   (interactive)
;;   (grammar-check-region (point-min) (point-max)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; for require/autoload
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun LaTeX-mode-config () (LaTeX-mode))
(provide 'LaTeX-mode-config)
