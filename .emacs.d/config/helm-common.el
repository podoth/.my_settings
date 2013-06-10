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
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-c o") 'helm-imenu)
(eval-after-load 'helm
  '(progn
     (define-key helm-map (kbd "C-w") 'backward-kill-word)
     (define-key helm-map (kbd "TAB") 'helm-next-line)
     (define-key helm-map (kbd "C-l") 'helm-recenter-top-bottom-other-window)
     ))
;; 自動補完を無効
(custom-set-variables '(helm-ff-auto-update-initial-value nil))
(setq helm-input-idle-delay 0.001)

;;;
;;; helm-ag
;;;
(autoload 'helm-ag "helm-ag")
(autoload 'helm-ag-this-file "helm-ag")
(global-set-key (kbd "M-g .") 'helm-ag)
(global-set-key (kbd "C-M-s") 'helm-ag-this-file)
