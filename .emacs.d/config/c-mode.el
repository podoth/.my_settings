;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; builtin
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
;;; flymake
;;;

;; for C/C++
(require 'flymake)

(defun flymake-simple-generic-init (cmd &optional opts)
  (let* ((temp-file  (flymake-init-create-temp-buffer-copy
                      'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list cmd (append opts (list local-file)))))

; Makefileがあればそれを使い、無くてもデフォのルールでチェック

(defun does-makefile-check-syntax-exist (filepath)
  (save-window-excursion
    (let* ((bufname (generate-new-buffer "*Makefile-check-check-syntax*"))
	   (result (progn (switch-to-buffer bufname)
			  (insert-file-contents filepath)
			  (search-forward "check-syntax" nil t))))
      (erase-buffer)
      (kill-buffer bufname)
      result)
    ))

(defun flymake-simple-make-or-generic-init (cmd &optional opts)
  (if (and (file-exists-p "Makefile")
	   (does-makefile-check-syntax-exist "./Makefile"))
      (flymake-simple-make-init)
    (flymake-simple-generic-init cmd opts)))

(defun flymake-c-init ()
  (flymake-simple-make-or-generic-init
   "gcc" (list "-Wall" "-Wextra" "-Wshadow" "-fsyntax-only" "-lpthread")))

(defun flymake-cc-init ()
  (flymake-simple-make-or-generic-init
   "g++" (list "-Wall" "-Wextra" "-Wshadow" "-fsyntax-only" "-lpthread")))

(push '("\\.[cC]$" flymake-c-init) flymake-allowed-file-name-masks)
(push '("\\.\\(cc\\|cpp\\|CC\\|CPP\\)$" flymake-cc-init) flymake-allowed-file-name-masks)

(add-hook
 'c-mode-common-hook
 '(lambda ()
    (flymake-mode t)
    (define-key c-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)
    (define-key c++-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)))


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
(setq cpp-edit-list ())
(setq cpp-edit-list
      (append cpp-edit-list
	      '( ("1" nil
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
		  default both nil))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; package
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; auto-complete-clang
;;; 文脈を考慮したC/C++用の補完
;;;
;; 上手くいかないときは、yasnippetとの競合か、clang/clang++がうまく動いていないことを疑う。
;; 参考：http://d.hatena.ne.jp/illness0721/20110820/1313851919
;; 大抵、clangの最新版をソースからビルドして入れれば直る
;; (require 'auto-complete-clang)
;; (setq clang-completion-suppress-error 't)
;; (add-hook 'c-mode-common-hook
;; 	  '(lambda ()
;; 	     ;; (setq ac-auto-start nil)
;; 	     ;; (setq completion-mode t)
;; 	     ;; (setq ac-expand-on-auto-complete nil)

;; 	     (setq ac-quick-help-delay 0.1)

;; 	     (setq ac-sources (append '(ac-source-clang
;; 	     				ac-source-gtags)
;; 	     			      ac-sources))

;; 	     ; clangのバグ修正のためにインクルードパスを指定
;; 	     (setq ac-clang-flags
;; 	     	   (mapcar (lambda (item) (concat "-I" item))
;; 	     		   '("/usr/include/c++/4.5"
;; 	     		     "/usr/include/c++/4.5/i486-linux-gnu"
;; 	     		     "/usr/include/c++/4.5/i686-linux-gnu"
;; 	     		     "/usr/lib/i386-linux-gnu/gcc/i686-linux-gnu/4.5/include"
;; 	     		     "/usr/local/include"
;; 	     		     "/usr/include")))
;; 	     (define-key c-mode-base-map (kbd "M-\\") 'ac-complete-clang)))

;;;
;;; auto-complete-clang-async
;;; 文脈を考慮したC/C++用の補完。少し速いらしい
;;;
(add-hook 'c-mode-common-hook
 	  '(lambda ()
	     (require 'auto-complete-clang-async)

	     ;; (setq ac-auto-start nil)
	     ;; (setq complejjjtion-mode t)
	     ;; (setq ac-expand-on-auto-complete nil)

	     ; ac-auto-startに数値を入れるのは何故か効かない
	     (setq ac-auto-start nil)
	     ;; (setq ac-clang-async-do-autocompletion-automatically t)

	     (setq ac-clang-complete-executable "~/.emacs.d/etc/clang-complete")

	     (setq ac-quick-help-delay 0.1)

	     ; ac-source-gtagsを入れると重くなる
	     (setq ac-sources (append '(ac-source-clang-async)
	     			      ac-sources))

	     (ac-clang-launch-completion-process)

	     ;; clangのインクルードパスベタがきの仕様により、C++の方はインクルードパスを指定してやらないといけない
	     (setq ac-clang-cflags
		   (mapcar (lambda (item) (concat "-I" item))
			   (list "/usr/include/c++/4.5"
				 "/usr/include/c++/4.5/i486-linux-gnu"
				 "/usr/include/c++/4.5/i686-linux-gnu"
				 "/usr/lib/i386-linux-gnu/gcc/i686-linux-gnu/4.5/include"
				 "/usr/local/include"
				 "/usr/include")))
	     (ac-clang-update-cmdlineargs)
	     ))

;;;
;;; gtags
;;;
(autoload 'gtags-mode "gtags" "" t)
(add-hook 'c-mode-common-hook 'gtags-mode)
(add-hook 'asm-mode-hook 'gtags-mode)
(setq gtags-auto-update t)
(setq gtags-ignore-case t)
(setq gtags-mode-hook
      '(lambda ()
         (local-set-key "\M-t" 'gtags-find-tag)
         (local-set-key "\M-r" 'gtags-find-rtag)
         (local-set-key "\M-s" 'gtags-find-symbol)
         (local-set-key "\C-t" 'gtags-pop-stack)
         ))
; auto-updateを非同期にする（これで合っているかは分からない）
(defun gtags-auto-update-async ()
    (if (and gtags-mode gtags-auto-update buffer-file-name)
        (progn
          (gtags-push-tramp-environment)
	  (start-process "gtags" "*gtags*" gtags-global-command "-u" (concat "--single-update=" (gtags-buffer-file-name)))
          (gtags-pop-tramp-environment))))
(defadvice gtags-auto-update (around make-async activate)
  (gtags-auto-update-async))

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
		  ))
     ))

;;;
;;; helm-flymake
;;;
(autoload 'helm-flymake "helm-flymake")
(global-set-key (kbd "C-c e") 'helm-flymake)