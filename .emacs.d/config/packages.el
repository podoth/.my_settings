;;;
;;; auto-async-byte-compile
;;;
(require 'auto-async-byte-compile)
(setq auto-async-byte-compile-exclude-files-regexp "~/.junk/")
(add-hook 'emacs-lisp-mode-hook 'enable-auto-async-byte-compile-mode)

;;;
;;; TeX関係
;;;

;; auctex
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

;; bibtex
(setq bib-bibtex-env-variable		"TEXMFHOME")
(autoload 'turn-on-bib-cite "bib-cite")
(add-hook 'LaTeX-mode-hook 'turn-on-bib-cite)
;; reftex
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
;; プレビュー
(load "preview-latex.el" nil t t)
;; outline-minor-mode
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
;;分割コンパイル可能に
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
;; fly-spell
(add-hook 'LaTeX-mode-hook 'my-turn-on-flyspell)
;;使わないし邪魔なので削除
(define-key TeX-mode-map "\C-c\C-w" 'nil)

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

;;;
;;; menu-tree.el(メニュー日本語化)
;;;
;; (setq load-path (cons "~/.emacs.d/packages/menu-tree-el-0.97" load-path))
;; (require 'menu-tree)

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
;; C-n/C-p で候補を選択
(define-key ac-complete-mode-map "\M-n" 'ac-next)
(define-key ac-complete-mode-map "\M-p" 'ac-previous)


;;;
;;; auto-complete-clang
;;; 文脈を考慮したC/C++用の補完
;;;
;; 上手くいかないときは、yasnippetとの競合か、clang/clang++がうまく動いていないことを疑う。
;; 参考：http://d.hatena.ne.jp/illness0721/20110820/1313851919
(require 'auto-complete-clang)
(setq clang-completion-suppress-error 't)
(add-hook 'c-mode-common-hook 
	  '(lambda ()
	     (setq ac-auto-start nil)
	     (setq completion-mode t)
	     (setq ac-expand-on-auto-complete nil)
	     (setq ac-quick-help-delay 0.3)
	     (define-key c-mode-base-map (kbd "M-\\") 'ac-complete-clang)))

;;;
;;; gtags
;;;
(autoload 'gtags-mode "gtags" "" t)
(add-hook 'c-mode-common-hook 'gtags-mode)
(add-hook 'asm-mode-hook 'gtags-mode)
(setq gtags-auto-update t)
(setq gtags-ignore-case t)
;; (defun gtags-parse-current-file ()
;;   (interactive)
;;   (if (gtags-get-rootpath)
;;       (let*
;;           ((root (gtags-get-rootpath))
;;            (path (buffer-file-name))
;;            (gtags-path-style 'root)
;;            (gtags-rootdir root))
;;         (if (string-match (regexp-quote root) path)
;;             (gtags-goto-tag
;;              (replace-match "" t nil path)
;;              "f" nil)
;;           ;; delegate to gtags-parse-file
;;           (gtags-parse-file)))
;;     ;; delegate to gtags-parse-file
;;     (gtags-parse-file)))
(setq gtags-mode-hook
      '(lambda ()
         (local-set-key "\M-t" 'gtags-find-tag)
         (local-set-key "\M-r" 'gtags-find-rtag)
         (local-set-key "\M-s" 'gtags-find-symbol)
         (local-set-key "\C-t" 'gtags-pop-stack)
         ;; (local-set-key "\C-co" 'gtags-parse-current-file)
         ))

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
;; (require 'evernote-mode)
;; (setq evernote-enml-formatter-command '("w3m" "-dump" "-I" "UTF8" "-O" "UTF8"))
;; (global-set-key "\C-cqc" 'evernote-create-note)
;; (global-set-key "\C-cqo" 'evernote-open-note)
;; (global-set-key "\C-cqs" 'evernote-search-notes)
;; (global-set-key "\C-cqS" 'evernote-do-saved-search)
;; (global-set-key "\C-cqw" 'evernote-write-note)
;; (global-set-key "\C-cqp" 'evernote-post-region)
;; (global-set-key "\C-cqb" 'evernote-browser)

;;;
;;; haskell-mode
;;;
(load "~/.emacs.d/packages/haskellmode-emacs/haskell-site-file.el")

;;;
;;; open-junk-file。ごみファイルを~/.junkに生成する
;;;
(autoload 'open-junk-file "open-junk-file")
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
(autoload 'quickrun "quickrun")
(global-set-key (kbd "<f5>") 'quickrun)


;;;
;;; migemo-isearch
;;;
(when (and (executable-find "cmigemo")
	   (autoload 'migemo-init "migemo" nil t))
  (add-hook 'isearch-mode-hook 'migemo-init)
  (eval-after-load "migemo"
    '(progn
       (setq migemo-command "cmigemo")
       (setq migemo-options '("-q" "--emacs"))
       (setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
       (setq migemo-user-dictionary nil)
       (setq migemo-regex-dictionary nil)
       (setq migemo-coding-system 'utf-8-unix)
       (define-key isearch-mode-map (kbd "RET") 'migemo-toggle-isearch-enable)
       (migemo-init)
       )))

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
;; (setq load-path (cons "~/.emacs.d/packages/ee-0.1.0" load-path))
;; (require 'ee-autoloads)
;; ;; C-c o で起動。
;; (global-set-key "\C-co" 'ee-outline)

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
;; 上下左右の単純移動はカウントしないようにする
(defun point-undo-pre-command-hook ()
  "Save positions before command."
  (unless (or (eq this-command 'point-undo)
              (eq this-command 'point-redo)
	      (eq this-command 'next-line)
	      (eq this-command 'previous-line)
	      (eq this-command 'forward-char)
	      (eq this-command 'backward-char))
    
    (let ((cell (cons (point) (window-start))))
      (unless (equal cell (car point-undo-list))
       (setq point-undo-list (cons cell point-undo-list))))
    (setq point-redo-list nil)))

(define-key global-map [f7] 'point-undo)
(define-key global-map [S-f7] 'point-redo)

;;;
;;; rst.el
;;; ReST編集の決定版
;;;
(autoload 'rst-mode "rst")
(setq auto-mode-alist
      (append '(("\\.rst$" . rst-mode)
		("\\.rest$" . rst-mode)) auto-mode-alist))
(eval-after-load "rst"
  ;; 全部スペースでインデントしましょう
  (add-hook 'rst-mode-hook '(lambda() (setq indent-tabs-mode nil))))

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
(setq load-path (cons "~/.emacs.d/packages/expand-region" load-path))
(require 'expand-region)
;; C-SPC連続実行で発動。
;; 何回やればいいのか分からないので、とりあえず並べまくる
(define-sequential-command seq-SPC
  cua-set-mark er/expand-region er/expand-region er/expand-region er/expand-region er/expand-region er/expand-region)
(global-set-key (kbd "C-SPC") 'seq-SPC)

;;;
;;; auto-install
;;;
;; (require 'auto-install)
;; (setq auto-install-directory "~/.emacs.d/packages/auto-install/")
;; (auto-install-update-emacswiki-package-name t)
;; (auto-install-compatibility-setup)             ; 互換性確保
;; (setq load-path (cons "~/.emacs.d/packages/auto-install" load-path))

;;;
;;; eldoc
;;;
(autoload 'turn-on-eldoc-mode "eldoc-extension")
(eval-after-load "eldoc-extension"
  '(progn
     (setq eldoc-idle-delay 0.20)
     (setq eldoc-echo-area-use-multiline-p t)))
(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)

;;;
;;; c-eldoc
;;; 関数呼び出しを書くときに仮引数をミニバッファに表示したり
;;;
;; (setq c-eldoc-includes "`pkg-config gtk+-2.0 --cflags` -I./ -I../ ")
;; (load "c-eldoc")
;; (add-hook 'c-mode-hook
;;           (lambda ()
;;             (set (make-local-variable 'eldoc-idle-delay) 0.20)
;;             (c-turn-on-eldoc-mode)
;;             ))

;;;
;;; ack
;;;
;; (load "ack")
;; (setq ack-command "ack-grep --nocolor --nogroup ")

;;;
;;; goto-chg
;;; 変更箇所にジャンプ
;;;
(require 'goto-chg)
(global-set-key (kbd "M-.") 'goto-last-change)
(global-set-key (kbd "M-,")'goto-last-change-reverse)


;;;
;;; 括弧に色付けする
;;;
(require 'highlight-parentheses)
(setq hl-paren-colors '("red" "blue" "yellow" "green" "magenta" "peru" "cyan"))
(set-face-attribute 'hl-paren-face nil :weight 'bold)
;; (add-hook 'emacs-lisp-mode-hook 'highlight-parentheses-mode)
;; (add-hook 'c-mode-hook 'highlight-parentheses-mode)
(define-globalized-minor-mode global-highlight-parentheses-mode
  highlight-parentheses-mode
  (lambda ()
    (highlight-parentheses-mode t)))
(global-highlight-parentheses-mode t)


;;;
;;; sdic
;;; 翻訳
;;;
(autoload 'sdic-describe-word-at-point "sdic" nil t)
(autoload 'sdic-describe-word "sdic" nil t)
(global-set-key "\C-c\C-w" 'sdic-describe-word-at-point)
(global-set-key "\C-cw" 'sdic-describe-word)
(eval-after-load "sdic"
  '(progn
     ;; 英辞郎.saryのための設定
     ;; http://d.hatena.ne.jp/syohex/20110116/1295158441
     (setq sdic-default-coding-system 'utf-8)
     (autoload 'sdic-describe-word "sdic" "search word" t nil)
     (eval-after-load "sdic"
       '(progn
	  (setq sdicf-array-command "/usr/bin/sary") ;; sary command path
	  (setq sdic-eiwa-dictionary-list
		'((sdicf-client "/usr/share/dict/eijiro126.sdic"
				(strategy array))))
	  (setq sdic-waei-dictionary-list
		'((sdicf-client "/usr/share/dict/waeijiro126.sdic"
				(strategy array))))
	  ;; saryを直接使用できるように sdicf.el 内に定義されている
	  ;; arrayコマンド用関数を強制的に置換
	  (fset 'sdicf-array-init 'sdicf-common-init)
	  (fset 'sdicf-array-quit 'sdicf-common-quit)
	  (fset 'sdicf-array-search
		(lambda (sdic pattern &optional case regexp)
		  (sdicf-array-init sdic)
		  (if regexp
		      (signal 'sdicf-invalid-method '(regexp))
		    (save-excursion
		      (set-buffer (sdicf-get-buffer sdic))
		      (delete-region (point-min) (point-max))
		      (apply 'sdicf-call-process
			     sdicf-array-command
			     (sdicf-get-coding-system sdic)
			     nil t nil
			     (if case
				 (list "-i" pattern (sdicf-get-filename sdic))
			       (list pattern (sdicf-get-filename sdic))))
		      (goto-char (point-min))
		      (let (entries)
			(while (not (eobp)) (sdicf-search-internal))
			(nreverse entries))))))
	  ;; omake
	  (defadvice sdic-forward-item (after sdic-forward-item-always-top activate)
	    (recenter 0))
	  (defadvice sdic-backward-item (after sdic-backward-item-always-top activate)
	    (recenter 0))))
     ;; 検索結果表示ウインドウの高さ
     (setq sdic-window-height 10)
     ;; 検索結果表示ウインドウにカーソルを移動しないようにする
     (setq sdic-disable-select-window t)
     ;; sdicバッファのundo量が大きくなりすぎるのを防ぐ
     ;; いい方法が思いつかないので、実行されるたびに無効化するようにする。
     ;; 一回目は失敗するけど、対象になるのは長時間バッファが存在する時だけだからおｋ
     (defadvice sdic-describe-word-at-point (after sdic-disable-undo activate)
       (save-current-buffer
	 (set-buffer (get-buffer sdic-buffer-name))
	 (buffer-disable-undo)
	 (undo-tree-mode -1)))
     (defadvice sdic-describe-word (after sdic-disable-undo activate)
       (save-current-buffer
	 (set-buffer (get-buffer sdic-buffer-name))
	 (buffer-disable-undo)
	 (undo-tree-mode -1)))
     )
  )


;;;
;;; text-translator
;;; webサービスを使ってリージョン翻訳
;;;
(autoload 'text-translator-translate-by-auto-selection "text-translator")
(autoload 'text-translator-translate-last-string "text-translator")
(eval-after-load "text-translator"
  '(progn
     ;; 自動選択に使用する関数を設定
     (setq text-translator-auto-selection-func
	   'text-translator-translate-by-auto-selection-enja)))
;; グローバルキーを設定
(global-set-key "\C-c\C-a" 'text-translator-translate-by-auto-selection)
(global-set-key "\C-ca" 'text-translator-translate-last-string)

;;;
;;; lookup
;;; 辞書検索
;;;
(autoload 'lookup "lookup" nil t)
(autoload 'lookup-region "lookup" nil t)
(autoload 'lookup-pattern "lookup" nil t)
(setq lookup-enable-splash nil)
(setq lookup-window-height 3)
(global-set-key "\C-c\C-y" 'lookup-pattern)
(setq lookup-search-agents '((ndeb "/usr/share/epwing/GENIUS")))
(setq lookup-default-dictionary-options '((:stemmer .  stem-english)))

;;;
;;; git-gutter.el
;;; gitのdiffを使って更新点を強調表示
;;;
(require 'git-gutter-fringe)
(global-git-gutter-mode t)
;;更新頻度を下げる
(setq git-gutter:update-hooks '(find-file-hook after-save-hook after-revert-hook))

;;;
;;; helm
;;;
(add-to-list 'load-path "~/.emacs.d/packages/helm")
(require 'helm-config)
(global-set-key (kbd "C-c b") 'helm-mini)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-c o") 'helm-imenu)
(eval-after-load 'helm
  '(progn
     (define-key helm-map (kbd "C-w") 'backward-kill-word)
     (define-key helm-map (kbd "TAB") 'helm-next-line)
     (define-key helm-map (kbd "C-l") 'helm-recenter-top-bottom-other-window)
     ))
;; 自動補完を無効
(custom-set-variables '(helm-ff-auto-update-initial-value nil))
(setq helm-input-idle-delay 0.001)

;;;
;;; helm-gtags
;;;
(add-to-list 'load-path "~/.emacs.d/packages/emacs-helm-gtags")
(autoload 'helm-gtags-mode "helm-gtags")
(add-hook 'c-mode-hook 'helm-gtags-mode)
(add-hook 'c++-mode-hook 'helm-gtags-mode)
(add-hook 'asm-mode-hook 'helm-gtags-mode)
(eval-after-load "helm-gtags"
  '(progn
     (setq helm-gtags-ignore-case t)
     (add-hook 'helm-gtags-mode-hook
	       '(lambda ()
		  (local-set-key (kbd "M-T") 'helm-gtags-find-tag)
		  (local-set-key (kbd "M-R") 'helm-gtags-find-rtag)
		  (local-set-key (kbd "M-S") 'helm-gtags-find-symbol)
		  (local-set-key (kbd "C-T") 'helm-gtags-pop-stack)
		  ;; (local-set-key (kbd "C-t") '(lambda ()
		  ;; 				    (interactive)
		  ;; 				     (helm-gtags-pop-stack)
		  ;; 				     (helm-resume 1))
		  ;; 		     )
		  ))
     ))

;;;
;;; helm-ag
;;;
(autoload 'helm-ag "helm-ag")
(autoload 'helm-ag-this-file "helm-ag")
(global-set-key (kbd "M-g .") 'helm-ag)
(global-set-key (kbd "C-M-s") 'helm-ag-this-file)

;;;
;;; auto-highlight-symbol
;;;
(setq load-path (cons "~/.emacs.d/packages/auto-highlight-symbol" load-path))
(require 'auto-highlight-symbol)
(global-auto-highlight-symbol-mode t)

;;;
;;; highlight-symbol
;;;
(require 'highlight-symbol)
(global-set-key (kbd "C-c h") 'highlight-symbol-at-point)
(global-set-key (kbd "C-c n") 'highlight-symbol-next)
(global-set-key (kbd "C-c p") 'highlight-symbol-prev)

;;;
;;; yasnippet
;;;
(setq load-path (cons "~/.emacs.d/packages/yasnippet-0.6.1c" load-path))
(idle-require 'yasnippet)
(eval-after-load "yasnippet"
    '(progn
       (yas/initialize)
       (yas/load-directory "~/.emacs.d/etc/snippets")))

;;;
;;; magit
;;;
(autoload 'magit-status "magit")
(global-set-key (kbd "C-c g") 'magit-status)

;; 複数動作可能にするための設定
;; http://d.hatena.ne.jp/ken_m/20111225/1324833439
(defvar my-magit-selected-files ()
  "選択されているファイルの名前のリスト。")

(defconst my-magit-file-beginning-regexp
  "^\t\\(Unmerged +\\|New +\\|Deleted +\\|Renamed +\\|Modified +\\|\\? +\\)?"
  "ファイルを表す行の行頭の正規表現。")

(defface my-magit-selected-face
  '((((class color) (background light))
     :background "LightGoldenRod")
    (((class color) (background dark))
     :background "DarkGoldenRod"))
  "選択中のファイルを表すフェイス。")

(defun my-magit-valid-buffer-p ()
  "操作可能な Magit のバッファかどうか。"
  (or (and (boundp 'magit-version)
           (eq major-mode 'magit-status-mode)) ; ver >= 1.1.0
      (eq major-mode 'magit-mode))) ; ver < 1.1.0

(defun my-magit-select-files (prefix)
  "ポイントのある行、もしくはリージョンのある行のファイルを選択。
PREFIX が t の場合 (前置引数がある場合) は、これまでの選択を一旦破棄してから処理します。"
  (interactive "P")
  (when (my-magit-valid-buffer-p)
    (when prefix (my-magit-clear-selected-files))
    (let (beg end lines)
      (if (and transient-mark-mode mark-active)
          (progn
            (setq mark-active nil)
            (setq beg (min (point) (mark)))
            (setq end (max (point) (mark)))
            (save-excursion
              (goto-char beg)
              (setq beg (line-beginning-position))
              (goto-char end)
              (unless (eq end (line-beginning-position))
                (setq end (line-end-position)))))
        (setq beg (line-beginning-position))
        (setq end (line-end-position)))
      (setq lines (split-string (buffer-substring-no-properties beg end) "[\n]+"))
      (while lines
        (let ((line (car lines)))
          (setq lines (cdr lines))
          (when (string-match (concat my-magit-file-beginning-regexp "\\(.+\\)") line)
            (let* ((file (match-string 2 line))
                   (hi-regexp (concat my-magit-file-beginning-regexp (regexp-quote file))))
              (if (member file my-magit-selected-files)
                  (progn
                    (setq my-magit-selected-files (delete file my-magit-selected-files))
                    (hi-lock-unface-buffer hi-regexp))
                (setq my-magit-selected-files (cons file my-magit-selected-files))
                (hi-lock-face-phrase-buffer hi-regexp 'my-magit-selected-face)))))))))

(defun my-magit-clear-selected-files ()
  "`my-magit-select-files' で選択されたファイルを全て破棄する。"
  (interactive)
  (when (my-magit-valid-buffer-p)
    (while my-magit-selected-files
      (hi-lock-unface-buffer (concat my-magit-file-beginning-regexp
                                     (regexp-quote (car my-magit-selected-files))))
      (setq my-magit-selected-files (cdr my-magit-selected-files)))))

(defun my-magit-re-hi-lock (&optional buffer)
  "`my-magit-select-files' で選択されたファイルを再度強調表示する。"
  (when (my-magit-valid-buffer-p)
    (let ((files my-magit-selected-files))
      (while files
        (let ((hi-regexp (concat my-magit-file-beginning-regexp
                                 (regexp-quote (car files)))))
          (hi-lock-unface-buffer hi-regexp)
          (hi-lock-face-phrase-buffer hi-regexp 'my-magit-selected-face)
          (setq files (cdr files)))))))

(defadvice magit-refresh-buffer (after my-hi-lock activate)
  "Magit のバッファの表示が更新された際には選択中のファイルを再度強調表示する。"
  (with-current-buffer (or buffer (current-buffer))
    (my-magit-re-hi-lock buffer)))

(defun my-magit-selected-files-string ()
  "`my-magit-select-files' で選択されたファイルを空白区切りの文字列として返す。"
  (if my-magit-selected-files
      (mapconcat (lambda (x) (concat "'" x "'")) my-magit-selected-files " ")
    ""))

(defun my-magit-insert-selected-files ()
  "`my-magit-select-files' で選択されたファイルを空白区切りの文字列としてバッファに挿入する。"
  (interactive)
  (insert (my-magit-selected-files-string)))


(add-hook 'magit-mode-hook
          ;; Magit で有効なキー設定
          (lambda ()
            (local-set-key (kbd "@") 'my-magit-select-files)
            (local-set-key (kbd "`") 'my-magit-clear-selected-files)))

(global-set-key (kbd "C-c i") 'my-magit-insert-selected-files)


;;;
;;; python-mode:非標準（少し古いけど機能充実）mode
;;; 普通に解凍後にディレクトリごと置いて、load-path通してやればOK
;;;
(setq load-path (cons "~/.emacs.d/packages/python-mode.el-6.1.1" load-path))
(autoload 'python-mode "python-mode" "Major mode for editing Python programs" t)
(autoload 'py-shell "python-mode" "Python shell" t)
(setq auto-mode-alist
      (cons (cons "\\.py$" 'python-mode) auto-mode-alist))

