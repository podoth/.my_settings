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
	  (setq sdicf-array-command "/usr/bin/sary") ;; sary command path
	  (setq sdic-eiwa-dictionary-list
		'((sdicf-client "/usr/share/dict/eijiro126.sdic"
				(strategy array))))
	  (setq sdic-waei-dictionary-list
		'((sdicf-client "/usr/share/dict/waeijiro126.sdic"
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


;;;
;;; text-translator
;;; webサービスを使ってリージョン翻訳
;;;
(autoload 'text-translator-translate-by-auto-selection "text-translator")
(autoload 'text-translator-translate-last-string "text-translator")
(eval-after-load "text-translator"
  '(progn
     ;; 自動選択に使用する関数を設定
     (setq text-translator-auto-selection-func
	   'text-translator-translate-by-auto-selection-enja)))
;; グローバルキーを設定
(global-set-key "\C-c\C-a" 'text-translator-translate-by-auto-selection)
(global-set-key "\C-ca" 'text-translator-translate-last-string)

;;;
;;; lookup
;;; 辞書検索
;;;
(autoload 'lookup "lookup" nil t)
(autoload 'lookup-region "lookup" nil t)
(autoload 'lookup-pattern "lookup" nil t)
(setq lookup-enable-splash nil)
(setq lookup-window-height 3)
(global-set-key "\C-c\C-y" 'lookup-pattern)
(setq lookup-search-agents '((ndeb "/usr/share/epwing/GENIUS")))
(setq lookup-default-dictionary-options '((:stemmer .  stem-english)))
