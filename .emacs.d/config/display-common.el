;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; builtin
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;; Color
;;

;; 普通のテキスト
(defvar my-foreground-color "#CCCCCC")
(defvar my-background-color "#333333")
(defface my-default-face `((t (:foreground ,my-foreground-color :background ,my-background-color))) nil)

;; 目立たせたくないものに使う迷彩色
(defvar my-foreground-camouflaged-color "#444444")
(defface my-camouflaged-face `((t (:foreground ,my-foreground-camouflaged-color))) nil)

;; プラスの効果
(defvar my-foreground-plus-color "#7F7FFF")
(defface my-plus-face `((t (:foreground ,my-foreground-plus-color))) nil)

;; マイナスの効果
(defvar my-foreground-minus-color "#FF7F7F")
(defface my-minus-face `((t (:foreground ,my-foreground-minus-color))) nil)

;; highlight & region
;; regionはhighlightの中にあっても輝く
(defvar my-background-region-color "#777777")
(defvar my-background-highlight-color "#555555")

;; flymake
(defvar my-background-warning-color "light blue")
(defvar my-foreground-warning-color "black")
(defface my-warning-face `((t (:foreground ,my-foreground-warning-color :background ,my-background-warning-color))) nil)

(defvar my-background-error-color "light pink")
(defvar my-foreground-error-color "black")
(defface my-error-face `((t (:foreground ,my-foreground-error-color :background ,my-background-error-color))) nil)

;; modeline
(defvar my-background-modeline-inactive-color "#333333")
(defvar my-foreground-modeline-inactive-color "#CCCCCC")
(defface my-modeline-inactive-face `((t (:foreground ,my-foreground-modeline-inactive-color :background ,my-background-modeline-inactive-color))) nil)

(defvar my-background-modeline-color "#CCCCCC")
(defvar my-foreground-modeline-color "#333333")
(defface my-modeline-face `((t (:foreground ,my-foreground-modeline-color :background ,my-background-modeline-color))) nil)

(set-foreground-color my-foreground-color)
(set-background-color my-background-color)
(set-cursor-color "#FF0000") ; カーソル色
(set-face-background 'region my-background-region-color) ; リージョン
(set-face-foreground 'mode-line my-foreground-modeline-color)
(set-face-background 'mode-line my-background-modeline-color)
(set-face-foreground 'modeline-inactive my-foreground-modeline-inactive-color)
(set-face-background 'modeline-inactive my-background-modeline-inactive-color)
(set-face-foreground 'font-lock-comment-delimiter-face "#CCCC55") ; コメントデリミタ
(set-face-foreground 'font-lock-comment-face "#CCCC55") ; コメント
(set-face-foreground 'font-lock-string-face "#7FFF7F") ; 文字列
(set-face-foreground 'font-lock-function-name-face "#BF7FFF") ; 関数名
(set-face-foreground 'font-lock-keyword-face "#FF7F7F") ; キーワード
(set-face-foreground 'font-lock-constant-face "#FFBF7F") ; 定数(this, selfなども)
(set-face-foreground 'font-lock-variable-name-face "#7F7FFF") ; 変数
(set-face-foreground 'font-lock-type-face "#FFFF7F") ; クラス
;; (set-face-foreground 'fringe "#666666") ; fringe(折り返し記号などが出る部分)
(set-face-background 'fringe "#282828") ; fringe

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; package
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
