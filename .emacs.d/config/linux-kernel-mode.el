;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; builtin
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
(setq auto-mode-alist (cons '("/nfs/repo/orthros/[^o].*\\.[ch]$" . linux-c-mode)
                       auto-mode-alist))

;;;
;;; c/c++でif 0, if 1の偽部分を灰色にする
;;;
(setq cpp-edit-list
      (append cpp-edit-list
	      '(("NOT_CFORK" my-camouflaged-face default both nil)
		("NOT_ORTHROS_COPY" my-camouflaged-face default both nil)
		("NOT_ORTHROS" my-camouflaged-face default both nil))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; package
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; Linux kernel向けflymake
;;; 編集しているマシンでコンパイルするため、アーキテクチャの違いによるエラーの違いとかはでてしまう
;;;
(setq flymake-kernel-script "~/.emacs.d/etc/flymake-kernel.sh")
(setq flymake-kernel-temporary-directory "~/.emacs.d/var/flymake-kernel")

(make-variable-buffer-local 'flymake-kernel-source-dir)
(make-variable-buffer-local 'flymake-kernel-build-dir)
(make-variable-buffer-local 'flymake-kernel-config-file)
(make-variable-buffer-local 'flymake-kernel-make-flags)

(defun replace-slash-with-exclamations (s)
  (replace-regexp-in-string "/" "!" s))

(defun flymake-kernel-init (source-dir config-file  &optional make-flags)
  (let* ((temp-file  (flymake-init-create-temp-buffer-copy
		      'flymake-create-temp-inplace))
	 (r-source-dir (expand-file-name source-dir))
	 (r-config-file (expand-file-name config-file))
	 (build-dir (concat (file-name-as-directory flymake-kernel-temporary-directory)
			    (replace-slash-with-exclamations r-source-dir)))
	 (r-build-dir (expand-file-name build-dir)))
    (setq flymake-kernel-source-dir r-source-dir)
    (setq flymake-kernel-build-dir r-build-dir)
    (setq flymake-kernel-config-file r-config-file)
    (setq flymake-kernel-config-file make-flags)
    (if make-flags
	(list flymake-kernel-script (list r-source-dir r-build-dir temp-file r-config-file make-flags))
      (list flymake-kernel-script (list r-source-dir r-build-dir temp-file r-config-file)))
))

(defun flymake-kernel-rebuild ()
  (interactive)
    (call-process flymake-kernel-script nil nil nil flymake-kernel-source-dir flymake-kernel-build-dir "clean" flymake-kernel-config-file))

(push '("/nfs/repo/orthros/[^o].*\\.c$" (lambda () (flymake-kernel-init
					 "/nfs/repo/orthros"
					 "~/.emacs.d/etc/flymake-kernel.config"
					 "ARCH=x86_64 KCFLAGS+=\"-Wall\" KCFLAGS+=\"-Wextra\" KCFLAGS+=\"-Wshadow\"")))
      flymake-allowed-file-name-masks)
 ;; (setq flymake-log-level 3)
