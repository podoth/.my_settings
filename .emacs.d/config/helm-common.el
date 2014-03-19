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
;;; helm
;;;
(add-to-list 'load-path "~/.emacs.d/packages/helm")
(require 'helm-config)
(global-set-key (kbd "C-c b") 'helm-mini)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(custom-set-variables
 '(helm-kill-ring-threshold 0)
 '(helm-kill-ring-max-lines-number 5))

(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-c o") 'helm-imenu)
(global-set-key (kbd "C-c C-M-s") 'helm-occur)
(eval-after-load 'helm
  '(progn
     (define-key helm-map (kbd "C-w") 'backward-kill-word)
     (define-key helm-map (kbd "TAB") 'helm-next-line)
     (define-key helm-map (kbd "C-l") 'helm-recenter-top-bottom-other-window)
     (define-key helm-map (kbd "C-h") 'delete-backward-char)
     (define-key helm-map (kbd "C-S-n") '(lambda () (interactive) (helm-next-line)(helm-next-line)(helm-next-line)))
     (define-key helm-map (kbd "C-S-p") '(lambda () (interactive) (helm-previous-line)(helm-previous-line)(helm-previous-line)))
     (custom-set-variables
      '(helm-mp-matching-method 'multi3p))
     ))

;; multilineのseparatorの長さをウインドウに併せて変える
;; あと、faceをfont-lock-faceにする
(eval-after-load 'helm
  '(set-face-foreground 'helm-separator my-foreground-separator-color))
(defadvice helm-insert-candidate-separator (before helm-flexible-candidate-separator activate)
  "Insert separator of candidates into the helm buffer."
  (setq helm-candidate-separator (make-string (- (window-body-width) 10) ?-)))
;; 自動補完を無効
(custom-set-variables '(helm-ff-auto-update-initial-value nil))
(setq helm-input-idle-delay 0.001)
;; popwinで表示
(setq helm-samewindow nil)
(push '("\\*helm.*\\*" :regexp t :height 0.4 :stick t) popwin:special-display-config)

;;;
;;; helm-ag
;;;
(autoload 'helm-ag "helm-ag" nil t)
(autoload 'helm-ag-this-file "helm-ag" nil t)
(global-set-key (kbd "C-c /") 'helm-ag)
;; (global-set-key (kbd "C-M-s") 'helm-ag-this-file)

;;;
;;; helm-descbinds
;;;
(autoload 'helm-descbinds "helm-descbinds" nil t)
(defalias 'helm-describe-bindings 'helm-descbinds)
(eval-after-load 'helm-descbinds
  '(progn
     (setq helm-descbinds-window-style 'split-window)
     ))

;;;
;;; helm-migemo
;;;
(eval-after-load "helm"
  '(progn
     (require 'helm-migemo)
     (helm-migemize-command helm-imenu)))

;;;
;;; all-ext
;;;
;; なんか使えない
;; (eval-after-load "helm"
;;   '(progn
;;      (require 'all-ext)
;;      (require 'view)
;;      (defun all-mode-quit ()
;;        (interactive)
;;        (view-mode 1) (View-quit))

;;      (define-key all-mode-map (kbd "C-c C-q") 'all-mode-quit)))
