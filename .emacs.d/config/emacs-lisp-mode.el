;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; builtin
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; package
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; auto-async-byte-compile
;;;
(require 'auto-async-byte-compile)
(setq auto-async-byte-compile-exclude-files-regexp "~/.junk/")
(add-hook 'emacs-lisp-mode-hook 'enable-auto-async-byte-compile-mode)

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
