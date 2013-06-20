;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; builtin
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; ファイルの最後にnewline
;;;
(setq require-final-newline t)

;;;
;;; デフォルトタブ幅を4にして、タブ使用を抑制
;;;
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

;;;
;;; 末尾の半角スペースとタブを表示(プログラミング系モードのみ)
;;;
(defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
(defvar my-face-u-1 'my-face-u-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
(font-lock-add-keywords major-mode '(("[ \t]+$" 0 my-face-u-1 append))))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
(add-hook 'find-file-hooks '(lambda ()
 (if font-lock-mode nil (font-lock-mode t))
) t)
(when (boundp 'show-trailing-whitespace)
  (setq-default show-trailing-whitespace t))

;;;
;;; 全角スペースとタブを強調表示
;;;
(setq whitespace-style
      '(tabs tab-mark spaces space-mark))
(setq whitespace-space-regexp "\\(\x3000+\\)")
(setq whitespace-display-mappings
      '((space-mark ?\x3000 [?\□])
        (tab-mark   ?\t   [?\xBB ?\t])
        ))
(require 'whitespace)
(global-whitespace-mode 1)
(setq whitespace-style
      '(face tabs tab-mark spaces space-mark))
(set-face-foreground 'whitespace-space my-foreground-camouflaged-color)
(set-face-background 'whitespace-space my-background-color)
(set-face-foreground 'whitespace-tab my-foreground-camouflaged-color)
(set-face-background 'whitespace-tab my-background-color)
;;;
;;; 保存時に行末の(タブ・半角スペース)を削除(プログラミング系モードかつgitレポジトリでない場合のみ)
;;;
(defun is-project-git-repository ()
  (and
                                        ; gitリポジトリ内
   (let ((error-message (shell-command-to-string "git rev-parse")))
     (string= error-message ""))
                                        ; git管理されているファイル
   (let ((result (shell-command-to-string (concat "git ls-files " (file-truename (buffer-file-name))))))
     (message result)
     (not (string= result "")))))
(add-hook 'before-save-hook
          '(lambda () (when (not (is-project-git-repository))
                        (delete-trailing-whitespace))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; package
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
