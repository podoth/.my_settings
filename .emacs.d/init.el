;;;
;;; MATSUO & TSUMURA lab.
;;;   ~/.emacs template
;;;  feel free to edit this file at your own risk
;;;
;;; Last Modified: 2010/04/26
;;; Created:       2007/04/03

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
(require 'server)
(unless (server-running-p) (server-start))

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

;;;
;;; 文字の大きさを変更　＋で大きく、ーで小さくする
;;;
(global-set-key "\C-c+" 'text-scale-increase)
(global-set-key "\C-c-" 'text-scale-decrease)

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
;;; clip_boardをXと共有
;;;
(cond (window-system
(setq x-select-enable-clipboard t)
)) 

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
;;; i-search中にC-hでBackspace
;;;
(define-key isearch-mode-map "\C-h" 'isearch-delete-char)


;;;
;;; recentf。開いたファイルの履歴
;;;
(recentf-mode 1)
(setq recentf-max-menu-items 20)
(setq recentf-max-saved-items 1000)

;;;
;;; ウインドウのサイズ変更を手軽に
;;;
(global-set-key [(meta L)]	'enlarge-window-horizontally) 
(global-set-key [(meta H)]	'shrink-window-horizontally) 
(global-set-key [(meta J)]	'enlarge-window) 
(global-set-key [(meta K)]	'shrink-window) 

;;;
;;; C-zで休止状態に入ると厄介なので阻止
;;; サイズ変更(xmonadでmod-右クリック)すると休止状態から戻るので不要になった
;;;
;(global-set-key [(control z)]	'nil) 
 	

;;;
;;; _を単語の定義に含める（単語単位の移動などに効く）
;;;
(modify-syntax-entry ?_ "w")



(setq auto-load-list-prefix "~/.emacs.d/var")

; 標準Elispの設定
(load "config/builtins")
; 非標準Elispの設定
(load "config/packages")
; 自作コマンドの設定
(load "config/functions")
