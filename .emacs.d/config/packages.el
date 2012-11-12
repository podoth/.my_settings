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
(setq gtags-auto-update t)
(setq gtags-ignore-case t)

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
(global-undo-tree-mode t)


;;;
;;; quickrun emacs上でプログラムのテスト実行
;;;
(require 'quickrun)
(global-set-key (kbd "<f5>") 'quickrun)


;;;
;;; migemo-isearch
;;;
(when (and (executable-find "cmigemo")
 (require 'migemo nil t))
(setq migemo-command "cmigemo")
(setq migemo-options '("-q" "--emacs"))
(setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
(setq migemo-user-dictionary nil)
(setq migemo-regex-dictionary nil)
(setq migemo-coding-system 'utf-8-unix)
(load-library "migemo")
(define-key isearch-mode-map (kbd "RET") 'migemo-toggle-isearch-enable)
(migemo-init)
)

;;;
;;; session。ミニバッファの入力履歴を終了後も記憶
;;;
; kill-ringやミニバッファで過去に開いたファイルなどの履歴を保存する
;; (when (require 'session nil t)
;;   (add-hook 'after-init-hook 'session-initialize)
;;   (setq session-initialize '(de-saveplace session keys menus places)
;;         session-globals-include '((kill-ring 50); kill-ring
;;                                   (session-file-alist 500 t); ファイル内でのカーソル位置
;;                                   (file-name-history 10000))); 開いたファイル
;;   ;;これがないと file-name-history に500個保存する前に max-string に達する
;;   (setq session-globals-max-string 100000000)
;;   ;; ミニバッファ履歴リストの長さ制限をなくす
;;   (setq history-length t)
;;   ;;ファイルを開いたとき、前とじた時の位置にカーソルを復帰
;;   (setq session-undo-check -1)

;;   ;; sessionはファイルを開いた履歴を保存するためだけに使っている
;;   ;; 自分はマルチプロセスで使いたいので、このままだと上手く使えない
;;   ;; なので、以下の設定で擬似的にプロセス間で同期を行なう
;;   (run-with-idle-timer 10 t '(session-save-session)) ; マルチプロセスで使うための設定:定期的に保存
;;   (defadvice find-file (around save-history activate compile) ; マルチプロセスで使うための設定:ファイルを開くたびにロードして保存
;;     ""
;;     (progn
;;       (load-file "~/.emacs.d/var/.session")
;;       ad-do-it
;;       (session-save-session)))
;;   )

;;;
;;; マルチプロセスでsave-hist保存時に一番新しいsave-histを保存するようにしたsave-hist?
;;;
(setq savehist-file "~/.emacs.d/var/history")
(require 'savehist)
(savehist-mode 1)
(custom-set-variables
'(savehist-length nil))
 
(custom-set-variables
'(history-length t)
'(history-delete-duplicates t)
)


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
;;; mozc
;;; モードラインが表示されないときは、uim-elをアンインストールすること
;;;
(when (require 'mozc nil t)
  (setq default-input-method "japanese-mozc")
  (setq mozc-candidate-style 'overlay)
  (global-set-key (kbd "S-SPC") 'toggle-input-method) 
  ;; faces
  ;; (set-face-attribute 'mozc-cand-overlay-even-face 'nil
  ;;                     :background "white" :foreground "black")
  ;; (set-face-attribute 'mozc-cand-overlay-odd-face 'nil
  ;;                     :background "white" :foreground "black"))
  )
(define-key isearch-mode-map (kbd "S-SPC") 'isearch-edit-string)

;;;
;;; point-undo.el
;;; カーソル移動についてのundo
;;;
(require 'point-undo)
(define-key global-map [f7] 'point-undo)
(define-key global-map [S-f7] 'point-redo)


;;;
;;; rst.el
;;; ReST編集の決定版
;;;
(require 'rst)
(setq auto-mode-alist
      (append '(("\\.rst$" . rst-mode)
		("\\.rest$" . rst-mode)) auto-mode-alist))
;; 全部スペースでインデントしましょう
(add-hook 'rst-mode-hook '(lambda() (setq indent-tabs-mode nil)))

;;;
;;; jaunte.el 
;;; hit-a-hint
;;;
;; (require 'jaunte)
;; (global-set-key (kbd "C-c C-f") 'jaunte)

;;;
;;; ace-jump-mode
;;; 最初の一文字だけ手動入力するhit-a-hint
;;;
(require 'ace-jump-mode)
(global-set-key (kbd "C-c C-f") 'ace-jump-mode)

;;;
;;; sequential-command
;;; 連続したコマンドに意味を持たせるフレームワーク
;;;
(require 'sequential-command)

;;;
;;; expand-region
;;; 微妙なさじかげんでリージョンを拡大していく
;;;
(setq load-path (cons "~/.emacs.d/packages/expand-region.el" load-path))
(require 'expand-region)
;; C-SPC連続実行で発動。
;; 何回やればいいのか分からないので、とりあえず並べまくる
(define-sequential-command seq-SPC
  cua-set-mark er/expand-region er/expand-region er/expand-region er/expand-region er/expand-region er/expand-region)
(global-set-key (kbd "C-SPC") 'seq-SPC)

;;;
;;; key-combo
;;; '=' => ' = 'にしたり、',' => ', 'にしたり色々。
;;;
(setq load-path (cons "~/.emacs.d/packages/key-combo" load-path))
(require 'key-combo)
(key-combo-load-default)


;;;
;;; auto-install
;;;
(require 'auto-install)
(setq auto-install-directory "~/.emacs.d/packages/auto-install/")
(auto-install-update-emacswiki-package-name t)
(auto-install-compatibility-setup)             ; 互換性確保
(setq load-path (cons "~/.emacs.d/packages/auto-install" load-path))

;;;
;;; eldoc
;;;
(require 'eldoc)
(require 'eldoc-extension)
(setq eldoc-idle-delay 0.20)
(setq eldoc-echo-area-use-multiline-p t)
(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)

;;;
;;; c-eldoc
;;; 関数呼び出しを書くときに仮引数をミニバッファに表示したり
;;;
(setq c-eldoc-includes "`pkg-config gtk+-2.0 --cflags` -I./ -I../ ")
(load "c-eldoc")
(add-hook 'c-mode-hook
          (lambda ()
            (set (make-local-variable 'eldoc-idle-delay) 0.20)
            (c-turn-on-eldoc-mode)
            ))
;; (add-hook 'c-mode-hook 'c-turn-on-eldoc-mode)

;;;
;;; ack
;;;
(load "ack")
(setq ack-command "ack-grep --nocolor --nogroup ")
