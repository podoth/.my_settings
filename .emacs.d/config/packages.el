;;;
;;; TeX関係
;;;

;;; auctex
(if (locate-library "auctex")
    (load "auctex.el" nil t t))
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
(when (not (shell-command "which pxdvi"))
  (setq TeX-output-view-style '(("^dvi$" "." "pxdvi %d"))))

(eval-after-load "auctex"
  '(when window-system
     (require 'font-latex)))
;;; bibtex
(setq bib-bibtex-env-variable		"TEXMFHOME")
(autoload 'turn-on-bib-cite "bib-cite")
(add-hook 'LaTeX-mode-hook 'turn-on-bib-cite)
;;; reftex
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
;;; プレビュー
(load "preview-latex.el" nil t t)
;;; xdviの設定
(setq TeX-output-view-style '(("^dvi$" "." "pxdvi %d")))
(eval-after-load "tex" '(progn
  (setq TeX-view-program-list
        (list (assoc "xdvi" TeX-view-program-list-builtin)))
  (setcar (cadr (assoc "xdvi"  TeX-view-program-list))
          "%(o?)pxdvi")))
;;;分割コンパイル可能に
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
;;; fly-spell
(add-hook 'TeX-mode
    '(lambda()
       (flyspell-mode)
       (local-set-key [(control .)] 'flyspell-auto-correct-word)))

;;;
;;; fold-dwim 3つ覚えるだけで隠したり伸ばしたりが伸縮自在に
;;;
(autoload 'fold-dwim-toggle
  "fold-dwim"
  "try to show any hidden text at the cursor" t)
(autoload 'fold-dwim-hide-all
  "fold-dwim" "hide all folds in the buffer" t)
(autoload 'fold-dwim-show-all
  "fold-dwim" "show all folds in the buffer" t)
(define-key global-map "\C-c\C-z" 'fold-dwim-toggle)

;;; outline-tree
(setq load-path (cons "~/.emacs.d/packages/ee-0.1.0" load-path))
(require 'ee-autoloads)
(setq ee-textfile-changelog-name-regexp
  "[(].*[)][ ]*\\([^<(]+?\\) [ \t]*[(<]\\([A-Za-z0-9_.-]+@[A-Za-z0-9_.-]+\\) [>)]")

;;;
;;; menu-tree.el(メニュー日本語化)
;;;
(setq load-path (cons "~/.emacs.d/packages/menu-tree-el-0.97" load-path))
(require 'menu-tree)

;;;
;;; auto-complete
;;;
(setq ac-dir "~/.emacs.d/packages/auto-complete-1.3.1/")
(add-to-list 'load-path ac-dir)
(require 'auto-complete-config)
(ac-config-default)

(add-to-list 'ac-dictionary-directories (concat ac-dir "ac-dict/"))
(global-set-key "\M-\\" 'ac-start)
(setq ac-comphist-file "~/.emacs.d/var/ac-comphist.dat")
;;; C-n/C-p で候補を選択
(define-key ac-complete-mode-map "\C-n" 'ac-next)
(define-key ac-complete-mode-map "\C-p" 'ac-previous)
;;; auto-completeにclangを使う
(require 'auto-complete-clang)
(setq clang-completion-suppress-error 't)

(defun my-c-mode-common-hook()
  (setq ac-auto-start nil)
  (setq completion-mode t)
  (setq ac-expand-on-auto-complete nil)
  (setq ac-quick-help-delay 0.3)
  (c-set-offset 'innamespace 0)
  (c-set-offset 'arglist-close 0)

  ;; compliation
  (setq compile-command "make -k -j2")
  (setq compilation-read-command nil)  ;; do not ask for make's option.
  (setq compilation-ask-about-save nil)  ;; auto-saving when you make
  (define-key c-mode-base-map "\C-cx" 'next-error)
  (define-key c-mode-base-map "\C-cc" 'compile)
  (define-key c-mode-base-map (kbd "M-\\") 'ac-complete-clang)
)

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;;;
;;; gtags
;;;
(autoload 'gtags-mode "gtags" "" t)
(setq gtags-mode-hook
      '(lambda ()
         (local-set-key "\M-t" 'gtags-find-tag)
         (local-set-key "\M-r" 'gtags-find-rtag)
         (local-set-key "\M-s" 'gtags-find-symbol)
         (local-set-key "\C-t" 'gtags-pop-stack)
         ))
;; (add-hook
;;  'c-mode-common-hook
;;  '(lambda()
;;     (gtags-mode 1)
;; ))
;; (add-hook
;;  'c++-mode-common-hook
;;  '(lambda()
;;     (gtags-mode 1)
;; ))
(add-hook 'c-mode-common-hook 'gtags-mode)
(add-hook 'asm-mode-hook 'gtags-mode)

;;;
;;; isearch中にCtrl-lで単語に色をつけたままにする
;;;
(require 'hi-lock)

(defun highlight-isearch-word ()
(interactive)
(let ((case-fold-search isearch-case-fold-search))
(isearch-exit)
(hi-lock-face-buffer-isearch isearch-string)))

(defun unhighlight-isearch-word ()
(interactive)
(isearch-exit)
(hi-lock-unface-buffer isearch-string))

(defun hi-lock-face-buffer-isearch (regexp)
(interactive)
(setq face (hi-lock-read-face-name))
(or (facep face) (setq face 'hi-yellow))
(unless hi-lock-mode (hi-lock-mode 1))
(hi-lock-set-pattern regexp face))

(define-key isearch-mode-map (kbd "C-l") 'highlight-isearch-word)
(define-key isearch-mode-map (kbd "C-u") 'unhighlight-isearch-word)

;;;
;;; 全角文字と空白文字の間に自動でスペースを開けるコマンド
;;;
(load "text-adjust")

;;;
;;; evernote-mode
;;;
(require 'evernote-mode)
(setq evernote-enml-formatter-command '("w3m" "-dump" "-I" "UTF8" "-O" "UTF8"))
(global-set-key "\C-cqc" 'evernote-create-note)
(global-set-key "\C-cqo" 'evernote-open-note)
(global-set-key "\C-cqs" 'evernote-search-notes)
(global-set-key "\C-cqS" 'evernote-do-saved-search)
(global-set-key "\C-cqw" 'evernote-write-note)
(global-set-key "\C-cqp" 'evernote-post-region)
(global-set-key "\C-cqb" 'evernote-browser)

;;;
;;; haskell-mode
;;;
(load "~/.emacs.d/packages/haskellmode-emacs/haskell-site-file.el")

;;;
;;; session。ミニバッファの入力履歴を終了後も記憶
;;;
(require 'session)
(add-hook 'after-init-hook 'session-initialize)
(setq session-undo-check -1)

;;;
;;; minibuf-iserach。ミニバッファをインクリメンタル検索できるように
;;;
(require 'minibuf-isearch)

;;;
;;; open-junk-file。ごみファイルを~/.junkに生成する
;;;
(require 'open-junk-file)
(setq open-junk-file-format "~/.junk/%Y/%m/%d/%H-%M.")
(global-set-key "\C-c\C-j" 'open-junk-file)