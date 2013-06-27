;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; builtin
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; java-modeというより、殆どeclimとの設定

;;;
;;; eclim
;;; eclipseとの連携
;;;
(setq load-path (cons "~/.emacs.d/packages/emacs-eclim" load-path))
(require 'eclim)
(require 'eclimd)
; eclipse-dirs -> eclim-executable -> eclimd-executableの順に設定しないと検索が上手くいかない
(custom-set-variables
 '(eclim-eclipse-dirs '("/opt/eclipse"))
 '(eclimd-default-workspace "~/workspace"))
(custom-set-variables `(eclim-executable ,(eclim-executable-find)))
(custom-set-variables `(eclimd-executable ,(eclimd--executable-path)))

;; eclimdを起動かつ対象プロジェクトの場合のみモードを有効化
;; eclimdのデフォルトディレクトリかつeclimdを起動していない場合は警告
(defun find-file-hook-turnon-eclim-mode ()
  (if (and (string-match "\\.java$" buffer-file-name)
           (eclim--file-managed-p buffer-file-name))
      (eclim-mode)
    (when (string-match (concat (expand-file-name (file-name-as-directory eclimd-default-workspace)) ".+\\.java$") buffer-file-name)
      (message "eclim daemon is not started !"))))
(add-hook 'find-file-hook 'find-file-hook-turnon-eclim-mode)

;; error表示の設定
(copy-face 'my-error-face 'eclim-problems-highlight-error-face)
(copy-face 'my-warning-face 'eclim-problems-highlight-warning-face)
(define-key eclim-mode-map (kbd "C-c d") (lambda () (interactive) (message "%s" (help-at-pt-kbd-string))))
(define-key eclim-mode-map (kbd "C-c c") 'eclim-problems-correct)

;; eclimでautocomplete
(require 'ac-emacs-eclim-source)
;; requiresを0にしてやらないと、"."を打った時に補完ができない。
;; また、色も嫌なので変える
(ac-define-source emacs-eclim
  '((candidates . eclim--completion-candidates)
    (action . eclim--completion-action)
    (prefix . eclim-completion-start)
    (requires . 0)
    (document . eclim--completion-documentation)
    (cache)
    ;; (selection-face . ac-emacs-eclim-selection-face)
    ;; (candidate-face . ac-emacs-eclim-candidate-face)
    (symbol . "f")))
(add-hook 'eclim-mode-hook (lambda ()
                             (ac-emacs-eclim-config)
                             (setq ac-auto-start 3)
                             (my-set-autocomplete-trigger (kbd "."))))

;; タグジャンプっぽいの
 (define-key eclim-mode-map "\M-t" 'eclim-java-find-declaration)
(define-key eclim-mode-map "\M-r" 'eclim-java-find-references)

;;;
;;; eclimでflymake
;;;
;; (defvar flymake-eclipse-batch-compiler-path
;;   "/opt/eclipse/plugins/org.eclipse.jdt.core_3.8.3.v20130121-145325.jar")

;; ;; TODO fix hardcoded 1.6
;; (defvar flymake-java-version "1.6")

;; (defun flymake-java-ecj-init ()
;;   (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                      'flymake-ecj-create-temp-file))
;;          (local-file (file-relative-name
;;                       temp-file
;;                       (file-name-directory buffer-file-name))))
;;     (list "java" (list "-jar" flymake-eclipse-batch-compiler-path "-Xemacs" "-d" "none"
;;                        "-warn:+over-ann,uselessTypeCheck";;,allJavadoc"
;;                        "-source" flymake-java-version "-target" flymake-java-version "-proceedOnError"
;;                        "-classpath" (eclim/project-classpath)
;;                        ;; "-log" "c:/temp/foo.xml"
;;                        local-file))))

;; (defun flymake-java-ecj-cleanup ()
;;   "Cleanup after `flymake-java-ecj-init' -- delete temp file and dirs."
;;   (flymake-safe-delete-file flymake-temp-source-file-name)
;;   (when flymake-temp-source-file-name
;;     (flymake-safe-delete-directory (file-name-directory flymake-temp-source-file-name))))
;; (defun flymake-ecj-create-temp-file (file-name prefix)
;;   "Create the file FILE-NAME in a unique directory in the temp directory."
;;   (file-truename (expand-file-name (file-name-nondirectory file-name)
;;                                    (expand-file-name (int-to-string (abs (random))) (flymake-get-temp-dir)))))
;; (push '(".+\\.java$" flymake-java-ecj-init flymake-java-ecj-cleanup) flymake-allowed-file-name-masks)

;; (provide 'flymake-eclim-java)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; package
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
