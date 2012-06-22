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
(global-linum-mode t)

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
;;; flymake
;;;

;; for C/C++
(require 'flymake)

(defun flymake-cc-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (setenv "LANG" "CPP")
    (list  "g++" (list "-Wall" "-Wextra" "-fsyntax-only" "-lpthread" local-file))))
(push '("\\.cpp$" flymake-cc-init) flymake-allowed-file-name-masks)
(add-hook 'c-mode-hook '(lambda () (if (string-match "\\.cpp$" buffer-file-name)
                               (flymake-mode t))))

(defun flymake-c-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (setenv "LANG" "C")
    (list "gcc" (list "-Wall" "-Wextra" "-fsyntax-only" "-lpthread" local-file))))
(push '("\\.c$" flymake-c-init) flymake-allowed-file-name-masks)
(add-hook 'c-mode-hook '(lambda () (if (string-match "\\.c$" buffer-file-name)
                               (flymake-mode t))))
(add-hook
 'c-mode-common-hook
 '(lambda ()
    (define-key c-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)))

;; for latex
(defun flymake-tex-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
         (local-dir   (file-name-directory buffer-file-name))
         (local-file  (file-relative-name
                       temp-file
                       local-dir)))
    (list "platex" (list "-file-line-error" "-interaction=nonstopmode" local-file))))
(defun flymake-tex-cleanup-custom ()
  (let* ((base-file-name (file-name-sans-extension (file-name-nondirectory flymake-temp-source-file-name)))
          (regexp-base-file-name (concat "^" base-file-name "\\.")))
    (mapcar '(lambda (filename)
                      (when (string-match regexp-base-file-name filename)
                         (flymake-safe-delete-file filename)))
                (split-string (shell-command-to-string "ls"))))
  (setq flymake-last-change-time nil))
(push '("\\.tex$" flymake-tex-init flymake-tex-cleanup-custom) flymake-allowed-file-name-masks)
(add-hook 'LaTeX-mode-hook 'flymake-mode)
(add-hook
 'LaTeX-mode-hook
 '(lambda ()
    (define-key LaTeX-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)))

;; for perl
;; http://unknownplace.org/memo/2007/12/21#e001
(require 'set-perl5lib)

(defvar flymake-perl-err-line-patterns
  '(("\\(.*\\) at \\([^ \n]+\\) line \\([0-9]+\\)[,.\n]" 2 3 nil 1)))

(defconst flymake-allowed-perl-file-name-masks
  '(("\\.pl$" flymake-perl-init)
    ("\\.pm$" flymake-perl-init)
    ("\\.t$" flymake-perl-init)))

(defun flymake-perl-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list "perl" (list "-wc" local-file))))

(defun flymake-perl-load ()
  (interactive)
  (defadvice flymake-post-syntax-check (before flymake-force-check-was-interrupted)
    (setq flymake-check-was-interrupted t))
  (ad-activate 'flymake-post-syntax-check)
  (setq flymake-allowed-file-name-masks (append flymake-allowed-file-name-masks flymake-allowed-perl-file-name-masks))
  (setq flymake-err-line-patterns flymake-perl-err-line-patterns)
  (set-perl5lib)
  (flymake-mode t))

(add-hook 'cperl-mode-hook 'flymake-perl-load)

(add-hook
 'cperl-mode-hook
 '(lambda ()
    (define-key cperl-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)))


;;;
;;; for bash
;;; コマンドの有無等は調べてくれない（構文エラーしか見ない）
;;;
(defcustom flymake-shell-of-choice
      "/bin/sh"
      "Path of shell.")
; /bin/bashじゃなくて/bin/shじゃないと上手くいかない。-nオプションの関係？

(defcustom flymake-shell-arguments
  (list "-n")
  "Shell arguments to invoke syntax checking.")

(defconst flymake-allowed-shell-file-name-masks
  '(("\\.sh$" flymake-shell-init))
  "Filename extensions that switch on flymake-shell mode syntax checks.")

(defcustom flymake-shell-err-line-pattern-re
  '(("^\\(.+\\): line \\([0-9]+\\): \\(.+\\)$" 1 2 nil 3))
  "Regexp matching JavaScript error messages.")

(defun flymake-shell-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list flymake-shell-of-choice (append flymake-shell-arguments (list local-file)))))

(defun flymake-shell-load ()
  (setq flymake-allowed-file-name-masks (append flymake-allowed-file-name-masks flymake-allowed-shell-file-name-masks))
  (setq flymake-err-line-patterns (append flymake-err-line-patterns flymake-shell-err-line-pattern-re))
  (flymake-mode t)
  (local-set-key (kbd "C-c d") 'credmp/flymake-display-err-minibuf))
(add-hook 'sh-mode-hook 'flymake-shell-load)

;; エラーをミニバッファに表示
(defun credmp/flymake-display-err-minibuf ()
  "Displays the error/warning for the current line in the minibuffer"
  (interactive)
  (let* ((line-no             (flymake-current-line-no))
         (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
         (count               (length line-err-info-list))
         )
    (while (> count 0)
      (when line-err-info-list
        (let* ((file       (flymake-ler-file (nth (1- count) line-err-info-list)))
               (full-file  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
          (message "[%s %s]" line text)
          )
        )
      (setq count (1- count)))))

;; M-p/M-n で警告/エラー行の移動
(global-set-key "\M-p" 'flymake-goto-prev-error)
(global-set-key "\M-n" 'flymake-goto-next-error)


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

;;;
;;; perlの編集にはcperl-modeを使う
;;;
(defalias 'perl-mode 'cperl-mode)
