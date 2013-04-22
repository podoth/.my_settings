;;;
;;; C-c 文字は通常割り当てられていない。行儀の悪いelispが使わない限りは
;;; Meta-大文字は通常割り当てられていない。割り当てられていない場合は、自動でMeta-小文字に変換して処理する
;;;　f5~f9は自由に割り当てられる

;;;
;;; ???
;;;
;; (defvar matlab:current-system
;;   (nth 2 (split-string system-configuration "-")))

;;;
;;; ロードパスの追加
;;;
(setq load-path (append
                 '("~/.emacs.d"
                   "~/.emacs.d/packages")
                 load-path))

;;;
;;; 一時ファイルのディレクトリ
;;;
(setq user-emacs-directory "~/.emacs.d/var/")

(setq auto-save-list-file-prefix "~/.emacs.d/var/")

;;;
;;; Language
;;;
(set-language-environment "Japanese")
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system	'utf-8)
(setq default-file-name-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;;;
;;; Key customize
;;;
(global-set-key [(control h)]	'delete-backward-char)
;(global-set-key [(meta g)]	'goto-line)
(define-key global-map "\C-\\" nil)

;;;
;;; Mouse Wheel
;;;
(mwheel-install)
(setq mouse-wheel-follow-mouse t)

;;;
;;; emacsclient
;;;
;; (require 'server)
;; (unless (server-running-p) (server-start))

;;;
;;; clip_boardをXと共有
;;; daemonだと手動で評価しないと効かない？
;;;
(setq x-select-enable-clipboard t)

;;;
;;; スクリプト保存時実行権限付与
;;;
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

;;;
;;; undo-limit
;;;
(setq undo-limit 600000)
(setq undo-strong-limit 900000)
(setq undo-outer-limit 600000)

;;;
;;; 文字の大きさを変更　＋で大きく、ーで小さくする
;;;
(global-set-key "\C-x+" 'text-scale-increase)
(global-set-key "\C-x-" 'text-scale-decrease)

;;;
;;; lsなど実行時、色指定のエスケープシーケンスがバグらずちゃんと色がつくようにする
;;;
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;;;
;;; ファイルのフルパスをタイトルバーに表示
;;;
(setq frame-title-format
      (format "%%f - Emacs@%s" (system-name)))
;;;
;;; メニューバーとツールバー非表示
;;;
(tool-bar-mode 0)
(menu-bar-mode 0)

;;;
;;; 大きいファイルを開こうとしたときに警告を発生させる
;;; デフォルトでは10MBなので25MBに拡張する
;;;
(setq lage-file-warning-threshold (* 25 1024 1024))

;;;
;;; C-kで行を連結したときにインデントを減らす
;;;
(defadvice kill-line (before kill-line-and-fixup activate)
  (when (and (not (bolp)) (eolp))
    (forward-char)
    (fixup-whitespace)
    (backward-char)))

;;;
;;; バックアップファイルは.emacs.d/var/backupに作成する
;;;
(setq make-backup-files t)
(setq backup-directory-alist
  (cons (cons "\\.*$" (expand-file-name "~/.emacs.d/var/backup"))
    backup-directory-alist))

;;;
;;; auto-saveは使わない
;;;
(setq auto-save-default nil)

;;;
;;; i-search中にC-hでBackspace
;;;
(define-key isearch-mode-map "\C-h" 'isearch-delete-char)


;;;
;;; recentf。開いたファイルの履歴
;;;
;; (recentf-mode 1)
;; (setq recentf-max-menu-items 20)
;; (setq recentf-max-saved-items 1000)

;;;
;;; ウインドウのサイズ変更を手軽に
;;;
(global-set-key [(meta L)]	'enlarge-window-horizontally)
(global-set-key [(meta H)]	'shrink-window-horizontally)
(global-set-key [(meta J)]	'enlarge-window)
(global-set-key [(meta K)]	'shrink-window)

;;;
;;; C-zで休止状態に入ると厄介なので阻止
;;; サイズ変更(xmonadでmod-右クリック)すると休止状態から戻るので不要になった。けどやっぱうざいのでいれとく
;;;
(global-set-key [(control z)]	'nil)


;;;
;;; _を単語の定義に含める（単語単位の移動などに効く）
;;;
(modify-syntax-entry ?_ "w")

;;;
;;; 指定行にジャンプ
;;;
(global-set-key [(control x)(:)] 'goto-line)


;;;
;;; forward-wardで空白ではなく単語の銭湯に飛ぶ
;;;
(defun forward-word+1 ()
  "forward-word で単語の先頭へ移動する"
  (interactive)
  (forward-word)
  (forward-char))

(global-set-key (kbd "M-f") 'forward-word+1)
;; (global-set-key (kbd "C-M-f") 'forward-word+1)

;;;
;;; 末尾の半角スペースとタブを表示(プログラミング系モードのみ)
;;;
(defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
(defvar my-face-u-1 'my-face-u-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
(font-lock-add-keywords major-mode '(("[ \t]+$" 0 my-face-u-1 append))))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
(add-hook 'find-file-hooks '(lambda ()
 (if font-lock-mode nil (font-lock-mode t))
) t)

;;;
;;; 保存時に行末の(タブ・半角スペース)を削除(プログラミング系モードのみ)
;;;
;; (add-hook 'before-save-hook 'delete-trailing-whitespace)


;;;
;;; リージョンの行数と文字数をモードラインに表示
;;;
(line-number-mode t)
(column-number-mode t)
; 選択範囲の情報表示
(defun count-lines-and-chars ()
  (if mark-active
      (format "[%3d:%4d]"
              (count-lines (region-beginning) (region-end))
              (- (region-end) (region-beginning)))
    ""))
(add-to-list 'default-mode-line-format
             '(:eval (count-lines-and-chars)))

;;;
;;; 現在のバッファをkillして、さらにwindowを閉じる
;;;
(global-set-key (kbd "C-x K") 'kill-buffer-and-window)

;;;
;;; ファイルの最後にnewline
;;;
(setq require-final-newline t)

;;;
;;; 毎日0時に、一時バッファや三日間見ていないバッファをkillする
;;;
(require 'midnight)

;;;
;;; C-x kは現在のバッファをKill
;;; どうせ現在のバッファしかしないし、iswitchb-exhibitを使っていると有効
;;;
(global-set-key (kbd "C-x k") 'kill-this-buffer)

;;;
;;; C-n以上、C-v以下の上下移動手段が欲しい
;;;
(global-set-key (kbd "C-S-n") '(lambda () (interactive) (next-line 3)))
(global-set-key (kbd "C-S-p") '(lambda () (interactive) (previous-line 3)))

;;;
;;; Evalで補完が効くように
;;;
(define-key read-expression-map (kbd "TAB") 'lisp-complete-symbol)

;;;
;;; エラー対処。以下のエラーが出るため、原因は分からないが定義
;;; Symbol's value as variable is void: warning-suppress-types
;;;
(setq warning-suppress-types nil)

;;;
;;; ミニバッファで C-h でヘルプでないようにする
;;;
(load "term/bobcat")
(when (fboundp 'terminal-init-bobcat)
  (terminal-init-bobcat))

; 標準Elispの設定
(load "config/builtins")
; 非標準Elispの設定
(load "config/packages")
; 自作コマンドの設定
(load "config/functions")

