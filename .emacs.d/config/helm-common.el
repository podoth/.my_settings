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
(custom-set-variables '(helm-kill-ring-threshold 0))
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-c o") 'helm-imenu)
(global-set-key (kbd "C-c C-M-s") 'helm-occur)
(eval-after-load 'helm
  '(progn
     (define-key helm-map (kbd "C-w") 'backward-kill-word)
     (define-key helm-map (kbd "TAB") 'helm-next-line)
     (define-key helm-map (kbd "C-l") 'helm-recenter-top-bottom-other-window)
     (define-key helm-map (kbd "C-S-n") (lambda () (interactive) (helm-next-line)(helm-next-line)(helm-next-line)))
     (define-key helm-map (kbd "C-S-p") (lambda () (interactive) (helm-previous-line)(helm-previous-line)(helm-previous-line)))
     ))
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
