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
(setq show-paren-style 'mixed)


;;;
;;; ナロウイングモードを有効化（Ctrl-x n nで選択リージョンのみを表示）
;;; Ctrl-x n w で元に戻す
;;;
(put 'set-goal-column 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;;;
;;; tramp
;;;
;; (if (locate-library "tramp")
;;     (require 'tramp))

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
; *を入力されない限り*系のバッファを隠す
(add-to-list 'iswitchb-buffer-ignore "\\`\\*")
(setq iswitchb-buffer-ignore-asterisk-orig nil)
(defadvice iswitchb-exhibit (before iswitchb-exhibit-asterisk activate)
  "*が入力されている時は*で始まるものだけを出す"
  (if (equal (char-after (minibuffer-prompt-end)) ?*)
      (when (not iswitchb-buffer-ignore-asterisk-orig)
        (setq iswitchb-buffer-ignore-asterisk-orig iswitchb-buffer-ignore)
        (setq iswitchb-buffer-ignore '("^ "))
        (iswitchb-make-buflist iswitchb-default)
        (setq iswitchb-rescan t))
    (when iswitchb-buffer-ignore-asterisk-orig
      (setq iswitchb-buffer-ignore iswitchb-buffer-ignore-asterisk-orig)
      (setq iswitchb-buffer-ignore-asterisk-orig nil)
      (iswitchb-make-buflist iswitchb-default)
      (setq iswitchb-rescan t))))
; 別のフレームでバッファを開いている時でも選択フレームで開く
(setq iswitchb-default-method 'samewindow)

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

(add-hook
 'TeX-mode-hook
 '(lambda ()
    (flymake-mode t)
    (define-key LaTeX-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)))

;; for perl
;; http://unknownplace.org/memo/2007/12/21#e001
(autoload 'set-perl5lib "set-perl5lib")

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


;; for bash
;; コマンドの有無等は調べてくれない（構文エラーしか見ない）

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
  (interactive)
  (message (mapconcat '(lambda (line-err-info)
			 (format "[%s] %s"
				 (flymake-ler-line line-err-info)
				 (flymake-ler-text line-err-info)))
		      (car (flymake-find-err-info flymake-err-info
						  (flymake-current-line-no)))
		      "\n")))

;; M-p/M-n で警告/エラー行の移動
(global-set-key "\M-p" 'flymake-goto-prev-error)
(global-set-key "\M-n" 'flymake-goto-next-error)

;; 警告を青色にする（flymakeのVersion 0.3の正規表現を修正）
;; さらに、noteをエラーにしないようにする
(defun flymake-parse-line (line)
  "Parse LINE to see if it is an error or warning.
Return its components if so, nil otherwise."
  (let ((raw-file-name nil)
	(line-no 0)
	(err-type "e")
	(err-text nil)
	(patterns flymake-err-line-patterns)
	(matched nil))
    (while (and patterns (not matched))
      (when (string-match (car (car patterns)) line)
	(let* ((file-idx (nth 1 (car patterns)))
	       (line-idx (nth 2 (car patterns))))

	  (setq raw-file-name (if file-idx (match-string file-idx line) nil))
	  (setq line-no       (if line-idx (string-to-number (match-string line-idx line)) 0))
	  (setq err-text      (if (> (length (car patterns)) 4)
				  (match-string (nth 4 (car patterns)) line)
				(flymake-patch-err-text (substring line (match-end 0)))))
	  (or err-text (setq err-text "<no error text>"))
	  (if (and err-text (string-match "[wW]arning\\|警告" err-text))
	      (setq err-type "w")
	    )
	  (if (and err-text (string-match "[nN]ote" err-text))
	      (setq err-type "i")
	    )
	  (flymake-log 3 "parse line: file-idx=%s line-idx=%s file=%s line=%s text=%s" file-idx line-idx
		       raw-file-name line-no err-text)
	  (setq matched t)))
      (setq patterns (cdr patterns)))
    (if matched
	(flymake-ler-make-ler raw-file-name line-no err-type err-text)
      ())))

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

;;;
;;; woman : emacs内のman
;;;
;; 初回起動が遅いのでキャッシュを作成(更新は C-u を付けて woman を呼ぶ)
(setq woman-cache-filename (expand-file-name "~/.emacs.d/var/woman_cache.el"))

;;;
;;; flyspell
;;;
(setq ispell-program-name "aspell")
(setq ispell-grep-command "grep")
(setq flyspell-issue-welcome-flag nil)
;; 日本語はスキップするようにする
(eval-after-load "ispell"
  '(add-to-list 'ispell-skip-region-alist '("[^\000-\377]")))
(defun my-turn-on-flyspell ()
  (flyspell-mode)
  ;; 前後の日本語を巻き込んで強調しないようにする
  ;; http://www.morishima.net/~naoto/fragments/archives/2005/12/20/flyspell/
  (setq ispell-local-dictionary-alist
	'((nil "[a-zA-Z]" "[^a-zA-Z]" "'" t ("-d" "en" "--encoding=utf-8") nil utf-8)))
  ;; このキーバインドは使わない上に他のとかぶる
  (define-key flyspell-mode-map [(control ?\,)] nil)
  (define-key flyspell-mode-map [(control ?\.)] nil)
)
