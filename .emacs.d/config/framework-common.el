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
;;; dash
;;;
(setq load-path (cons "~/.emacs.d/packages/dash.el" load-path))
(require 'dash)

;;;
;;; sequential-command
;;; 連続したコマンドに意味を持たせるフレームワーク
;;;
(require 'sequential-command)

;;;
;;; popup
;;; オーバーレイでバッファを表示するフレームワーク
;;;
(add-to-list 'load-path "~/.emacs.d/packages/popup-el/")
(require 'popup)

;;;
;;; popwin
;;; 補完や一時バッファ等のバッファの表示を固定したりして快適にする
;;;
(setq load-path (cons "~/.emacs.d/packages/popwin-el" load-path))
(require 'popwin)
(setq display-buffer-function 'popwin:display-buffer)
;; position:autoを使用可能にする
(defadvice  popwin:create-popup-window (before popwin-auto-window-position activate)
  (when (equal (ad-get-arg 1) 'auto)
    (ad-set-arg 1 (let ((w (frame-width))
                        (h (frame-height)))
                    (if (and (< 200 w)         ; フレームの幅が200桁より大きくて
                             (< h w))          ; 横長の時に
                        'right                 ; 右へ出す
                      'bottom)))))

;;;
;;; flex-autopair
;;;
;; (setq load-path (cons "~/.emacs.d/packages/flex-autopair" load-path))
;; (require 'flex-autopair)
;; (flex-autopair-mode 1)

;;;
;;; smartparens
;;;
(setq load-path (cons "~/.emacs.d/packages/smartparens" load-path))
(require 'smartparens-config)
(smartparens-global-mode)
