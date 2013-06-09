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
;;; flymake
;;;
(require 'flymake)

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
;;; woman : emacs内のman
;;;
;; 初回起動が遅いのでキャッシュを作成(更新は C-u を付けて woman を呼ぶ)
(setq woman-cache-filename (expand-file-name "~/.emacs.d/var/woman_cache.el"))

;;;
;;; dabbrev
;;;
; 大文字小文字変換をしない
(setq dabbrev-case-replace nil)
