;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;
;;; 一般的な項目
;;;
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; 現在の関数名を画面の上に表示する
;;;
(which-func-mode 1)
(setq which-func-modes t)

;;;
;;; linum 行番号を表示する
;;;
(require 'linum)
(global-linum-mode)

;;;
;;; highlight
;;;
(require 'font-lock)
;(turn-on-font-lock-if-enabled)
(global-font-lock-mode t)
; markを目立たせる
(transient-mark-mode t)
; 対となる括弧を目立たせる
(require 'paren)
(show-paren-mode t)

;;;
;;; ナロウイングモードを有効化（Ctrl-x n nで選択リージョンのみを表示）
;;; Ctrl-x n w で元に戻す
;;;
(put 'set-goal-column 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;;;
;;; tramp
;;;
(if (locate-library "tramp")
    (require 'tramp))

;;;
;;; iswitchb-mode
;;; C-s and C-r to rotate
;;;
(iswitchb-mode 1)
(setq read-buffer-function 'iswitchb-read-buffer)
(setq iswitchb-regexp nil)
(setq iswitchb-prompt-newbuffer nil)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

;;;
;;; ファイル名が重複していたらプロンプトにディレクトリ名を追加する。
;;;
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)


;;;
;;; cue-mode
;;; C-Enterで矩形選択
;;;
(cua-mode t)
(setq cua-enable-cua-keys nil) ;; 変なキーバインド禁止
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;
;;; モードに関する項目
;;;
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; hide-show(Cの括弧を隠したり表示したり)
;;;
(add-hook 'c-mode-common-hook
	  '(lambda()
	     (hs-minor-mode 1))) 
; コメントは、隠さず表示する。
(setq hs-hide-comments-when-hiding-all nil)

;;;
;;; uncrustifyによるCソース整形。いまんとこCだけ
;;;
 (defun uncrustify-region ()
   "Run uncrustify on the current region."
   (interactive)
   (save-excursion
     (shell-command-on-region (point) (mark) "uncrustify -l C -q" nil t)))
 (defun uncrustify-defun ()
   "Run uncrustify on the current defun."
   (interactive)
   (save-excursion (mark-defun)
                   (uncrustify-region)))
(define-key global-map "\C-c\C-v" 'uncrustify-region)

;;;
;;; flymake for C/C++
;;;
(require 'flymake)

(defun flymake-cc-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (setenv "LANG" "CPP")
    (list  "g++" (list "-Wall" "-Wextra" "-fsyntax-only" "-lpthread" "-I/application/gtest" "-I/application/gtest/include" local-file))))
(push '("\\.cpp$" flymake-cc-init) flymake-allowed-file-name-masks)
(add-hook 'c-mode-hook '(lambda () (if (string-match "\\.cpp$" buffer-file-name)
                               (flymake-mode t))))
;; (add-hook 'c++-mode-hook
;;           '(lambda ()
;;              (flymake-mode t)))


(defun flymake-c-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (setenv "LANG" "C")
    (list "gcc" (list "-Wall" "-Wextra" "-fsyntax-only" "-lpthread" "-I/application/gtest" "-I/application/gtest/include" local-file))))
(push '("\\.c$" flymake-c-init) flymake-allowed-file-name-masks)
(add-hook 'c-mode-hook '(lambda () (if (string-match "\\.c$" buffer-file-name)
                               (flymake-mode t))))
;; (add-hook 'c-mode-hook
;;           '(lambda ()
;;              (flymake-mode t)))

;;;
;;; linux カーネル編集モード
;;;
(defun linux-c-mode ()
  "C mode with adjusted defaults for use with the Linux kernel."
  (interactive)
  (c-mode)
  (c-set-style "K&R")
  (setq tab-width 8)
  (setq indent-tabs-mode t)
  (setq c-basic-offset 8))
(setq auto-mode-alist (cons '("/nfs/repo/orthros/.*/.*\\.[ch]$" . linux-c-mode)
                       auto-mode-alist))

;;;
;;; c/c++でif 0, if 1の偽部分を灰色にする
;;;
(add-hook
 'c-mode-common-hook
 '(lambda()
    (cpp-highlight-buffer t)
))
(setq cpp-known-face
      '(background-color . "light gray"))
(setq cpp-unknown-face 'default)
(setq cpp-face-type 'light)
(setq cpp-known-writable 't)
(setq cpp-unknown-writable 't)
(setq cpp-edit-list
      '(("1" nil
	 (progn
	 (foreground-color . "gray")
	 (background-color . "light gray")
	 )
	 both nil)
	("0"
	 (progn
	 (foreground-color . "gray")
	 (background-color . "light gray")
	 )
	 default both nil)
	("NOT_CFORK"
	 (progn
	 (foreground-color . "gray")
	 (background-color . "light gray")
	 )
	 default both nil)
	("NOT_ORTHROS_COPY"
	 (progn
	 (foreground-color . "gray")
	 (background-color . "light gray")
	 )
	 default both nil)
	("NOT_ORTHROS"
	 (progn
	 (foreground-color . "gray")
	 (background-color . "light gray")
	 )
	 default both nil)))

;;; Octave-mode
(autoload 'octave-mode "octave-mod" nil t)
(setq auto-mode-alist
           (cons '("\\.m$" . octave-mode) auto-mode-alist))
(add-hook 'octave-mode-hook
               (lambda ()
                 (abbrev-mode 1)
                 (auto-fill-mode 1)
                 (if (eq window-system 'x)
                     (font-lock-mode 1))))
