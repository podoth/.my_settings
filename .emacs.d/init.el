;;;
;;; C-c 文字は通常割り当てられていない。行儀の悪いelispが使わない限りは
;;; Meta-大文字は通常割り当てられていない。割り当てられていない場合は、自動でMeta-小文字に変換して処理する
;;;　f5~f9は自由に割り当てられる

;;;
;;; 環境別に設定を切り分けるための設定
;;;
(setq darwin-p  (eq system-type 'darwin)
      ns-p      (eq window-system 'ns)
      carbon-p  (eq window-system 'mac)
      linux-p   (eq system-type 'gnu/linux)
      cygwin-p  (eq system-type 'cygwin)
      nt-p      (eq system-type 'windows-nt)
      meadow-p  (featurep 'meadow)
      windows-p (or cygwin-p nt-p meadow-p))

(setq emacs22-p (string-match "^22" emacs-version)
	  emacs23-p (string-match "^23" emacs-version)
	  emacs23.0-p (string-match "^23\.0" emacs-version)
	  emacs23.1-p (string-match "^23\.1" emacs-version)
	  emacs23.2-p (string-match "^23\.2" emacs-version)
	  emacs24-p (string-match "^24" emacs-version))


;;;
;;; windowsのためのパス設定
;;;
(when windows-p
  (setq explicit-shell-file-name (executable-find "bash"))
  (setq shell-file-name (executable-find "bash")))

;;;
;;; デバッグ
;;;
;; (setq debug-on-error t)

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
;;; prefere-coding-systemは何故か他のelisp(mozcとか)によって乱されるようなので、ここと最後で二度設定するようにする
;;;
(set-language-environment "Japanese")
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(setq default-file-name-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;;;
;;; customize の出力先を変更する
;;;
(setq custom-file "~/.emacs.d/var/custom.el")
(if (file-exists-p (expand-file-name custom-file))
    (load (expand-file-name custom-file) t nil nil))

;;;
;;; 環境変数で基本英語にする
;;;
(setenv "LANG" "C")
(setenv "LC_ALL" "C")

;;;
;;; ホームディレクトリで作業する
;;;
(cd "~")

;;;
;;; メモリ使用量を多くしてGC頻度を下げる
;;;
(setq gc-cons-threshold 5000000)

;;;
;;; C-hでbackspace
;;;
(global-set-key [(control h)]	'delete-backward-char)
(define-key isearch-mode-map "\C-h" 'isearch-delete-char)
; ibus.elとの競合を起こすため下記の方法（キーマップを入れ替え）は封印
;; (load "term/bobcat")
;; (when (fboundp 'terminal-init-bobcat)
;;   (terminal-init-bobcat))

;;;
;;; 修飾キーを増やすために、C-z, C-q, C-tをすげ替える
;;;
(global-unset-key (kbd "C-z"))
(global-set-key (kbd "C-z C-z") 'suspend-frame)
(global-unset-key (kbd "C-q"))
(global-set-key (kbd "C-q C-q") 'quoted-insert)
(global-unset-key (kbd "C-t"))
(global-set-key (kbd "C-t C-t") 'transpose-chars)

;;;
;;; Mouse Wheel
;;;
(mwheel-install)
(setq mouse-wheel-follow-mouse t)

;;;
;;; emacsclient
;;; serverが起動していなければ起動する。
;;; どちらにしても、自分の名前は一意にしておく。（emacsclientを用いて指定したemacsにファイルをひらかせる需要がある）
;;;
(require 'server)
(setq server-name (concat "server-" (number-to-string (emacs-pid))))
(unless (server-running-p) (server-start))

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
;;; 起動時のスタートアップを出さない
;;;
(custom-set-variables '(inhibit-startup-screen t))

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
;;; _を単語の定義に含める（単語単位の移動などに効く）
;;;
(modify-syntax-entry ?_ "w")

;;;
;;; 指定行にジャンプ
;;;
;; (global-set-key [(control x)(:)] 'goto-line)


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
(global-set-key (kbd "C-S-f") '(lambda () (interactive) (forward-char 3)))
(global-set-key (kbd "C-S-b") '(lambda () (interactive) (backward-char 3)))

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
;;; (yes/no) を (y/n)に
;;;
(fset 'yes-or-no-p 'y-or-n-p)

;;;
;;; M-xなどで実行したときにキーバインドを通知する？
;;;
(setq suggest-key-bindings t)

;;;
;;; find-alternate-fileをrevert-bufferで置き換える。ついでに確認しないようにする。
;;; 色々リセットされなくなるが、diredモードとか利用してると不都合かもしれない
;;;
(global-set-key (kbd "C-x C-v") '(lambda () (interactive) (revert-buffer t t nil)))

;;;
;;; emacs24からmake-local-hookが無くなったが、それに対応していないelispがたくさんあるので空定義する
;;; make-local-hookを使っていた行はそのまま削除しても大丈夫らしいので
;;;
(when emacs24-p
  (defun make-local-hook (hook) nil))

;;;
;;; scrollbar
;;;
(set-scroll-bar-mode 'right)

;;;
;;; 文末の区切りを、"."の後に空白一つで認識するようにする（デフォだと空白が二つないといけない）
;;; 後、日本語用に"。"も追加する。
;;;
(setq sentence-end "[.?!。．][]\"')]*\\($\\|\t\\| \\)[ \t\n]*")

;;;
;;; find-fileの補完時に大文字小文字を無視する
;;;
(custom-set-variables
 '(read-file-name-completion-ignore-case t))

;;;
;;; find-fileで無視するファイルを追加
;;;
(setq completion-ignored-extensions (append completion-ignored-extensions '("#")))

;;;
;;; completion-ignored-extensionsをfind-fileのタブ補完時に現れるバッファにも適用
;;;
(defadvice completion-file-name-table (after ignoring-backups-f-n-completion activate)
  "filter out results when the have completion-ignored-extensions"
  (let ((res ad-return-value))
    (if (and (listp res)
          (stringp (car res))
          (cdr res)) ; length > 1, don't ignore sole match
        (setq ad-return-value
          (completion-pcm--filename-try-filter res)))))

;;;
;;; 起動時間を計測
;;;
(add-hook 'after-init-hook
  (lambda ()
    (message "init time: %.3f sec"
             (float-time (time-subtract after-init-time before-init-time)))))

;;;
;;; 時間がかかるrequireを表示
;;;
(defadvice require (around require-benchmark activate)
  (let* ((before (current-time))
	 (result ad-do-it)
	 (after (current-time))
	 (time (float-time (time-subtract after before))))
    (when (> time 0.05)
      (message "%s: %.3f sec" (ad-get-arg 0) time))))

(defadvice load (around load-benchmark activate)
  (let* ((before (current-time))
	 (result ad-do-it)
	 (after (current-time))
	 (time (float-time (time-subtract after before))))
    (when (> time 0.05)
      (message "%s: %.3f sec" (ad-get-arg 0) time))))

;; 各設定の前提となる設定
(load "config/display-common")

;; 他のelispによって使われるelispの設定
(load "config/framework-common")
(load "config/helm-common") ; helm
(load "config/completion-common") ; auto-complete

;; 標準Elispの設定
(load "config/builtins")
;; 非標準Elispの設定
(load "config/packages")
;; その他コマンドの設定
(load "config/functions")

;; 粒度の荒い設定達
(load "config/whitespace-common")
(load "config/flymake-common")
(when (executable-find "git")
  (load "config/git-common"))
(load "config/english-common")

;; モード特有の設定達
(load "config/c-mode")
(load "config/java-mode")
(load "config/linux-kernel-mode")
(autoload 'LaTeX-mode-config "config/latex-mode-config" "" t)
(autoload 'japanese-latex-mode "config/latex-mode-config" "" t)
(add-to-list 'auto-mode-alist '("\\.tex\\'" . LaTeX-mode-config))
(autoload 'python-mode-config "config/python-mode-config" "" t)
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode-config))
(load "config/rest-mode")
(load "config/perl-mode")
(load "config/ruby-mode")
(load "config/emacs-lisp-mode")
(load "config/bash-mode")
(load "config/octave-mode")
(load "config/haskell-mode")

;;;
;;; idle-require 遅延起動と、autoloadを暇なときに詠みこむ
;;; これは非標準なので注意
;;;
;; なんか動作が重くなるのでやっぱりやめ
;; (require 'idle-require)
;; (custom-set-variables
;;  '(idle-require-idle-delay 1200))
;; (idle-require-mode 1)

;;;
;;; Language
;;;
(prefer-coding-system 'utf-8)
