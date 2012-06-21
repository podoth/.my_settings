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
;; (when (not (shell-command "which pxdvi"))
;;   (setq TeX-output-view-style '(("^dvi$" "." "pxdvi %d"))))

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
;;; outline-minor-mode
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
;;; open-junk-file。ごみファイルを~/.junkに生成する
;;;
(require 'open-junk-file)
(setq open-junk-file-format "~/.junk/%Y/%m/%d/%H-%M.")
(global-set-key "\C-c\C-j" 'open-junk-file)

;;;
;;; *Completions*バッファを自動で消す
;;;
(require 'lcomp)
(lcomp-install)

;;;
;;; いきなりM-yでkill-ringをプレビュー表示
;;;
(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;;;
;;; undo-tree
;;;
(require 'undo-tree)
(global-undo-tree-mode)


;;;
;;; quickrun emacs上でプログラムのテスト実行
;;;
(require 'quickrun)
(global-set-key (kbd "<f5>") 'quickrun)


;;;
;;; migemo-isearch
;;;
(setq migemo-command "cmigemo")
(setq migemo-options '("-q" "--emacs"))
(setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
(setq migemo-user-dictionary nil)
(setq migemo-regex-dictionary nil)
(setq migemo-coding-system 'utf-8-unix)
(load-library "migemo")
(migemo-init)

;;;
;;; session。ミニバッファの入力履歴を終了後も記憶
;;;
; kill-ringやミニバッファで過去に開いたファイルなどの履歴を保存する
(when (require 'session nil t)
  (add-hook 'after-init-hook 'session-initialize)
  (setq session-initialize '(de-saveplace session keys menus places)
        session-globals-include '((kill-ring 50); kill-ring
                                  (session-file-alist 500 t); ファイル内でのカーソル位置
                                  (file-name-history 10000))); 開いたファイル
  ;;これがないと file-name-history に500個保存する前に max-string に達する
  (setq session-globals-max-string 100000000)
  ;; ミニバッファ履歴リストの長さ制限をなくす
  (setq history-length t)
  ;;ファイルを開いたとき、前とじた時の位置にカーソルを復帰
  (setq session-undo-check -1))


;;;
;;; minibuf-iserach。ミニバッファをインクリメンタル検索できるように
;;;
(require 'minibuf-isearch)

;;;
;;; アウトラインをまとめたものを表示
;;;
(setq load-path (cons "~/.emacs.d/package/ee-0.1.0" load-path))
(require 'ee-autoloads)
;; C-c o で起動。
(global-set-key "\C-co" 'ee-outline)

;;;
;;; scim-bridge
;;;
(require 'scim-bridge-ja)
(add-hook 'after-init-hook 'scim-mode-on)
; C-SPC は Set Mark に使う
(scim-define-common-key ?\C-\s nil)
; C-/ は Undo に使う
(scim-define-common-key ?\C-/ nil)
; 日本語入力中は赤いカーソル
(setq scim-cursor-color '("red"))
; インクリメンタル中はカーソルを塗りつぶさないものにする
(setq scim-isearch-cursor-type 'hollow)
