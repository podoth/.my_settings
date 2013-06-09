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
;;; python-mode:非標準（少し古いけど機能充実）mode
;;; 普通に解凍後にディレクトリごと置いて、load-path通してやればOK
;;;
(setq load-path (cons "~/.emacs.d/packages/python-mode.el-6.1.1" load-path))
(autoload 'python-mode "python-mode" "Major mode for editing Python programs" t)
(autoload 'py-shell "python-mode" "Python shell" t)
(setq auto-mode-alist
      (cons (cons "\\.py$" 'python-mode) auto-mode-alist))

;;;
;;; Pymacs:pythonとemacsをつなぐフレームワーク？
;;; pythonの方は"make"&&"python setup.py install"して、
;;; emacsの方はpymacs.elだけ置いてやればOK。
;;; pymacs用のpythonファイルは、etc/pymacsに置くことにする。
;;;
(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)
(eval-after-load "pymacs"
  '(add-to-list 'pymacs-load-path "~/.emacs.d/etc/pymacs"))

;;;
;;; ropemacs:pythonのリファクタリングを行なうツール。
;;; "easy_install rope"と"easy_install ropemacs"でインストールした。
;;; インストールした後、ropeとropemacsをインストール先からpymacsのパスの通った場所へ移してやった。
;;;
(add-hook 'python-mode-hook
          '(lambda ()
	     (require 'pymacs)
	     (pymacs-load "ropemacs" "rope-")
	     ;; Automatically save project python buffers before refactorings
	     (setq ropemacs-confirm-saving 'nil)
             ))

;;;
;;; jedi:pythonの補完
;;; これが一番速くて賢いらしい
;;; "easy_install jedi" "easy_install epc"
;;; deferred.el,concurrent.el,ctable.el,epc.el,jedi.elをload-pathの通った場所におく
;;; jediepcserver.pyをjedi.elと同じ場所に置く
;;; http://www.sakito.com/2012/11/emacs-python-jedi.html
;;;
(setq load-path (cons "~/.emacs.d/packages/jedi" load-path))
(require 'jedi)
(add-hook 'python-mode-hook
          '(lambda ()
             (jedi:ac-setup)
             (define-key python-mode-map (kbd "M-\\") 'jedi:complete)
             ))


;;;
;;; python用flymake設定
;;; pyflakesとpep8で検査する
;;; "easy_install pyflakes" "easy_install pep8
;;; 以下のスクリプトをpychecker.shとして作成しておく
;;;
;;; #!/bin/bash
;;; pyflakes $1
;;; echo "## pyflakes above, pep8 below ##"
;;; pep8 --repeat $1
;;;
(custom-set-variables
 '(py-pychecker-command "~/.emacs.d/etc/pychecker.sh")
 '(py-pychecker-command-args (quote ("")))
 '(python-check-command "~/.emacs.d/etc/pychecker.sh"))

(defun flymake-pyflakes-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
		     'flymake-create-temp-inplace))
	 (local-file (file-relative-name
		      temp-file
		      (file-name-directory buffer-file-name))))
    (list "pyflakes" (list local-file))))
(add-to-list 'flymake-allowed-file-name-masks '("\\.py\\'" flymake-pyflakes-init))

(add-hook 'python-mode-hook
	  '(lambda ()
	     (flymake-mode t)
	     (define-key python-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)))
