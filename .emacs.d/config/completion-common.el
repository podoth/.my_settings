;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; builtin
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; Evalで補完が効くように
;;;
(define-key read-expression-map (kbd "TAB") 'lisp-complete-symbol)

;;;
;;; dabbrev
;;;
; 大文字小文字変換をしない
(setq dabbrev-case-replace nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; package
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;
;;; auto-complete
;;;
;; (setq ac-dir "~/.emacs.d/packages/auto-complete-1.3.1/")
(setq ac-dir "~/.emacs.d/packages/auto-complete/")
(add-to-list 'load-path "~/.emacs.d/packages/auto-complete/")
(require 'auto-complete-config)
(ac-config-default)
(add-to-list 'ac-dictionary-directories (concat ac-dir "ac-dict/"))
;; (global-set-key "\M-\\" 'ac-start)
;; (global-set-key "\M-\\" (lambda () (interactive)(ac-start :requires 0 :triggered nil)))
(global-set-key "\M-\\" 'auto-complete)
(setq ac-comphist-file "~/.emacs.d/var/ac-comphist.dat")
;; C-n/C-p で候補を選択
(define-key ac-complete-mode-map "\M-n" 'ac-next)
(define-key ac-complete-mode-map "\M-p" 'ac-previous)
;; 大文字・小文字を区別しない
(setq ac-ignore-case t)
;; 補完対象に大文字が含まれる場合のみ区別する
(setq ac-ignore-case 'smart)
;; 制限数をつけてフリーズしないようにする
(setq ac-candidate-limit 1000)
;; gtagsをac-sourceに使わない（多すぎるので）
(defun ac-cc-mode-setup ()
  (setq ac-sources (append '(ac-source-yasnippet) ac-sources)))

;;;
;;; yasnippet
;;;
(setq load-path (cons "~/.emacs.d/packages/yasnippet-0.6.1c" load-path))
(when (not (require 'yasnippet-bundle nil t))
  ; 存在しなければコンパイル
  (require 'yasnippet)
  (yas/compile-bundle "~/.emacs.d/packages/yasnippet-0.6.1c/yasnippet.el"
		      "~/.emacs.d/packages/yasnippet-0.6.1c/yasnippet-bundle.el"
		      "~/.emacs.d/etc/snippets"
		      ""
		      "~/.emacs.d/packages/yasnippet-0.6.1c/dropdown-list.el")
  (require 'yasnippet-bundle))
(yas/initialize-bundle)
; snippetsディレクトリを更新したらこれを呼ぶ
(defun my-compile-yasnippet-bundle ()
  (interactive)
  (yas/compile-bundle "~/.emacs.d/packages/yasnippet-0.6.1c/yasnippet.el"
		      "~/.emacs.d/packages/yasnippet-0.6.1c/yasnippet-bundle.el"
		      "~/.emacs.d/etc/snippets"
		      ""
		      "~/.emacs.d/packages/yasnippet-0.6.1c/dropdown-list.el")
  (byte-compile-file "~/.emacs.d/packages/yasnippet-0.6.1c/yasnippet-bundle.el")
  (load "yasnippet-bundle"))

;;;
;;; dabbrevの日本語対応
;;;
(load "dabbrev-ja")
