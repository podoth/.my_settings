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
;;; sdic
;;; 翻訳
;;;
(setq load-path (cons "~/.emacs.d/packages/sdic" load-path))
(autoload 'sdic-describe-word-at-point "sdic" nil t)
(autoload 'sdic-describe-word "sdic" nil t)
(global-set-key "\C-c\C-w" 'sdic-describe-word-at-point)
(global-set-key "\C-cw" 'sdic-describe-word)
(eval-after-load "sdic"
  '(progn
     ;; 英辞郎.saryのための設定
     ;; http://d.hatena.ne.jp/syohex/20110116/1295158441
     (setq sdic-default-coding-system 'utf-8)
     (autoload 'sdic-describe-word "sdic" "search word" t nil)
     (eval-after-load "sdic"
       '(progn
	  (setq sdicf-array-command "/usr/local/bin/sary") ;; sary command path
	  ;; (setq sdic-eiwa-dictionary-list
	  ;;   '((sdicf-client "/usr/share/dict/eijiro126.sdic"
	  ;;   		(strategy array))))
	  ;; (setq sdic-waei-dictionary-list
	  ;;   '((sdicf-client "/usr/share/dict/waeijiro126.sdic"
	  ;;   		(strategy array))))
	  (setq sdic-eiwa-dictionary-list
		'((sdicf-client "/nfs/dict/sdic/eijiro126.sdic.utf8"
				(strategy array))))
	  (setq sdic-waei-dictionary-list
		'((sdicf-client "/nfs/dict/sdic/waeijiro126.sdic.utf8"
				(strategy array))))

	  ;; saryを直接使用できるように sdicf.el 内に定義されている
	  ;; arrayコマンド用関数を強制的に置換
	  (fset 'sdicf-array-init 'sdicf-common-init)
	  (fset 'sdicf-array-quit 'sdicf-common-quit)
	  (fset 'sdicf-array-search
		(lambda (sdic pattern &optional case regexp)
		  (sdicf-array-init sdic)
		  (if regexp
		      (signal 'sdicf-invalid-method '(regexp))
		    (save-excursion
		      (set-buffer (sdicf-get-buffer sdic))
		      (delete-region (point-min) (point-max))
		      (apply 'sdicf-call-process
			     sdicf-array-command
			     (sdicf-get-coding-system sdic)
			     nil t nil
			     (if case
				 (list "-i" pattern (sdicf-get-filename sdic))
			       (list pattern (sdicf-get-filename sdic))))
		      (goto-char (point-min))
		      (let (entries)
			(while (not (eobp)) (sdicf-search-internal))
			(nreverse entries))))))
	  ;; omake
	  (defadvice sdic-forward-item (after sdic-forward-item-always-top activate)
	    (recenter 0))
	  (defadvice sdic-backward-item (after sdic-backward-item-always-top activate)
	    (recenter 0))))
     ;; 検索結果表示ウインドウの高さ
     (setq sdic-window-height 10)
     ;; 検索結果表示ウインドウにカーソルを移動しないようにする
     (setq sdic-disable-select-window t)
     ;; sdicバッファのundo量が大きくなりすぎるのを防ぐ
     ;; いい方法が思いつかないので、実行されるたびに無効化するようにする。
     ;; 一回目は失敗するけど、対象になるのは長時間バッファが存在する時だけだからおｋ
     (defadvice sdic-describe-word-at-point (after sdic-disable-undo activate)
       (save-current-buffer
	 (set-buffer (get-buffer sdic-buffer-name))
	 (buffer-disable-undo)
	 (undo-tree-mode -1)))
     (defadvice sdic-describe-word (after sdic-disable-undo activate)
       (save-current-buffer
	 (set-buffer (get-buffer sdic-buffer-name))
	 (buffer-disable-undo)
	 (undo-tree-mode -1)))
     )
  )
;; popwinで表示
(push '("*sdic*" :stick t) popwin:special-display-config)
(defadvice sdic-display-buffer (around sdic-display-buffer-normalize activate)
  "sdic のバッファ表示を普通にする。"
  (setq ad-return-value (buffer-size))
  (let ((p (or (ad-get-arg 0)
               (point))))
    (and sdic-warning-hidden-entry
         (> p (point-min))
         (message "この前にもエントリがあります。"))
    (goto-char p)
    (display-buffer (get-buffer sdic-buffer-name))
    (set-window-start (get-buffer-window sdic-buffer-name) p)))
(defadvice sdic-other-window (around sdic-other-normalize activate)
  "sdic のバッファ移動を普通にする。"
  (other-window 1))
(defadvice sdic-close-window (around sdic-close-normalize activate)
  "sdic のバッファクローズを普通にする。"
  (bury-buffer sdic-buffer-name))

;;;
;;; text-translator
;;; webサービスを使ってリージョン翻訳
;;;
(setq load-path (cons "~/.emacs.d/packages/text-translator" load-path))
(require 'text-translator-load)
(eval-after-load "text-translator"
  '(progn
     ;; 自動選択に使用する関数を設定
     (setq text-translator-auto-selection-func
	   'text-translator-translate-by-auto-selection-enja)))
;; グローバルキーを設定
(global-set-key "\C-c\C-a" 'text-translator-translate-by-auto-selection)
(global-set-key "\C-ca" 'text-translator-translate-last-string)
;; popwinで表示
;; text-translator-clientのsave-selected-windowを無効化する必要がある
(custom-set-variables
 '(text-translator-auto-window-adjust nil)
 )
(push '("*translated*" :height 4) popwin:special-display-config)

;;;
;;; lookup
;;; 辞書検索
;;;
(setq load-path (cons "~/.emacs.d/packages/lookup" load-path))
;; (autoload 'lookup "lookup" nil t)
;; (autoload 'lookup-region "lookup" nil t)
(autoload 'lookup-pattern "lookup" nil t)
(setq lookup-enable-splash nil)
(setq lookup-window-height 3)
(global-set-key "\C-c\C-y" 'lookup-pattern)
;; (setq lookup-search-agents '((ndeb "/usr/share/epwing/GENIUS")))
(setq lookup-search-agents '((ndeb "/nfs/dict/lookup/GENIUS")))
(setq lookup-default-dictionary-options '((:stemmer .  stem-english)))
;; popwinで表示するために色々書き換える
;; 内部動作を理解しているわけではないのでbuggy
(push '(" *Entry*" :stick t) popwin:special-display-config)
(push '(" *Content*" :stick t :noselect t) popwin:special-display-config)

(setq lookup-my-entry-buffer-display t)
(defalias 'lookup-pattern-without-entry 'lookup-pattern)
(defadvice lookup-pattern (around lookup-patternfdsa activate)
  ""
  (let ((lookup-my-entry-buffer-display (not (equal this-command 'lookup-pattern-without-entry))))
    ad-do-it))
(global-set-key (kbd "C-c y") 'lookup-pattern-without-entry)

(defadvice lookup-pop-to-buffer (around lookup-pop-to-buffer-normalize activate)
  ""
  (let ((buffer (ad-get-arg 0)))
    (setq buffer (or (current-buffer)))
    (if (and buffer lookup-my-entry-buffer-display)
        (display-buffer buffer))
    (if (and (window-live-p lookup-main-window)
             (if (fboundp 'frame-visible-p)
                 (frame-visible-p (window-frame lookup-main-window))))
        (display-buffer (get-buffer-window lookup-main-window)))
    buffer))
(defadvice lookup-display-buffer (around lookup-display-buffer-normalize activate)
  ""
  (let ((buffer (ad-get-arg 0)))
    (if (window-live-p lookup-sub-window)
        (set-window-buffer lookup-sub-window buffer)
      )    (display-buffer buffer)

    buffer))
(defadvice lookup-content-display (around lookup-content-display-normalize activate)
  ""
  (let ((entry (ad-get-arg 0)))
    (let ((last-window (selected-window))
          (last-buffer (current-buffer))
          (buffer (lookup-open-buffer (lookup-content-buffer))))
      (when (get-buffer-window buffer)
        (select-window (get-buffer-window buffer)))
      (set-buffer buffer)
      (kill-all-local-variables)
      (setq lookup-content-current-entry entry
            lookup-content-line-heading (lookup-entry-heading entry))
      (when (boundp 'nobreak-char-display)
        (make-local-variable 'nobreak-char-display)
        (setq nobreak-char-display nil))
      (let ((inhibit-read-only t))
        (erase-buffer)
        (if (lookup-reference-p entry)
            (insert "(no contents)")
          (lookup-vse-insert-content entry)))
      (lookup-content-mode)
      ;; (lookup-display-buffer (current-buffer))
      (set-buffer last-buffer)
      (select-window last-window)
      )))
