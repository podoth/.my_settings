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
(require 'text-adjust)

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
;;; open-junk-file。ごみファイルを~/.junkに生成する
;;;
(autoload 'open-junk-file "open-junk-file")
(setq open-junk-file-format "~/.junk/%Y-%m-%d/%H-%M.")
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
;; popwinで管理
(push '(" *undo-tree*" :width 0.2 :position auto) popwin:special-display-config)

;;;
;;; quickrun emacs上でプログラムのテスト実行
;;;
(autoload 'quickrun "quickrun")
(global-set-key (kbd "<f5>") 'quickrun)
;; popwinで表示
(push '("*quickrun*") popwin:special-display-config)


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
;;; savehist and multiple Emacs sessions
;;; http://lists.gnu.org/archive/html/emacs-devel/2005-12/msg01264.html
;;;
(setq savehist-file "~/.emacs.d/var/history")
(require 'savehist)
(savehist-mode 1)
(custom-set-variables
 '(history-length t)
 '(history-delete-duplicates t)
 )
;; kill-ringも保存するようにする。
;; (setq savehist-additional-variables '(kill-ring))
;; でやってもいいが、それだと複数emacs sessionで使用した時に片方が上書きされてしまう
(add-to-list 'savehist-minibuffer-history-variables 'kill-ring)

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
  ;; (setq mozc-candidate-style 'overlay)
  (setq mozc-candidate-style 'echo-area)
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
(global-set-key (kbd "C-.") 'ace-jump-mode)

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
;;; rfringe
;;; 色々使えるらしいが、とりあえずflymakeでのエラー行表示
;;;
(require 'rfringe)
(require 'fringe-helper)
(fringe-helper-define 'rfringe-thin-dash '(top repeat)
  ".XX...XX."
  "..XX.XX.."
  "...XXX..."
  "..XX.XX.."
  ".XX...XX.")

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
;;; multiple-cursors
;;; カーソルを複製
;;;
(setq load-path (cons "~/.emacs.d/packages/multiple-cursors" load-path))
(require 'multiple-cursors)
(setq mc/list-file "~/.emacs.d/var/.mc-lists.el")
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-k C-r") 'mc/mark-all-like-this)
(global-set-key (kbd "C-c C-k C-d C-r") 'mc/mark-all-like-this-in-defun)
(global-set-key (kbd "C-c C-k C-s") 'mc/mark-all-symbols-like-this-in-defun)
(global-set-key (kbd "C-c C-k C-d C-s") 'mc/mark-all-symbols-like-this-in-defun)
(global-set-key (kbd "C-c C-k C-w") 'mc/mark-all-words-like-this-in-defun)
(global-set-key (kbd "C-c C-k C-d C-w") 'mc/mark-all-words-like-this-in-defun)

;;;
;;; breadcrumb
;;; パンくずリスト的なブックマーク。同じファイルの複数の場所を記録できる
;;;
(require 'breadcrumb)
(custom-set-variables
 '(bc-bookmark-limit 64)
 '(bc-bookmark-file "~/.emacs.d/var/.breadcrumb")
 '(bc-bookmark-hook-enabled nil)
 )
(global-set-key [(control f2)]          'bc-set)
(global-set-key [(f2)]                  'bc-previous)
(global-set-key [(shift f2)]            'bc-next)
(global-set-key [(meta f2)]             'bc-list)
;; popwinで管理
(defadvice bc-list (before bc-list-popup-window activate)
  (popwin:popup-buffer (get-buffer-create bc--menu-buffer)))
(defadvice bc-jump (before bc-jump-popup-window activate)
  (popwin:close-popup-window))

;;;
;;; guide-key
;;;
(require 'guide-key)
(setq guide-key/guide-key-sequence '("C-x r" "C-x 4" "C-c" "C-z" "C-q" "C-t"))
(custom-set-variables
 '(guide-key/polling-time 2)
 '(guide-key/popup-window-position 'bottom)
 '(guide-key/recursive-key-sequence-flag t)
 )
(guide-key-mode 1)

;;;
;;; elscreen
;;;
(setq elscreen-prefix-key "\C-z")
(setq elscreen-display-tab nil)
(setq elscreen-startup-command-line-processing nil)
(require 'elscreen)
(define-key elscreen-map (kbd "C-z") 'suspend-frame)

;;;
;;; helm-elscreen
;;;
(autoload 'helm-elscreen "helm-elscreen" nil t)
(define-key elscreen-map (kbd "C-b") 'helm-elscreen)

;;;
;;; elscreen-buffer-list
;;;
;; (setq elscreen-buffer-list-enabled t)
;; (require 'elscreen-buffer-list)
(require 'jg-elscreen-buffer-list)


;;;
;;; smooth-scroll
;;;
(require 'smooth-scroll)
(smooth-scroll-mode t)
;; 遅さを感じ無い程度、ただし目で追える程度の速さ
(setq smooth-scroll/vscroll-step-size 10)

;;;
;;; rainbow-mode
;;; 色情報を表す文字列の背景色を変更
;;;
(require 'rainbow-mode)
(define-global-minor-mode global-rainbow-mode rainbow-mode rainbow-mode)
(global-rainbow-mode t)

