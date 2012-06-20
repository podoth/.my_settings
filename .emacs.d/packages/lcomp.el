;;; lcomp.el --- auto close completion window

;; Copyright (C) 2002, 2004 by Taiki SUGAWARA <taiki.s@cityfujisawa.ne.jp>

;; Author: Taiki SUGAWARA <taiki.s@cityfujisawa.ne.jp>
;; Keywords: tool

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Installation:
;; If you want to use lcomp, write following code into your .emacs file.
;;	(require 'lcomp)
;;	(lcomp-install)
;; And if you want to disable lcomp, type M-x lcomp-uninstall.

;; This package is auto close *Completion* window anytime.
;; This is useful following case:
;; When you write elisp code on *scratch* buffer, you type M-TAB, then
;; *Completion* window is appeared. When your completion is finished,
;; *Completion* window is stay your emacs!! If you use lcomp, when completion
;; is finished, *Completion* window is auto close.

;;; Code:

(defvar lcomp-before-completion-winconf nil
  "This variable hold before completion window configulation.")
(defvar lcomp-completion-halfway-p nil
  "If non-nil, completion is halfway now.")
(defvar lcomp-display-completion-buffer-p nil
  "If non-nil completion buffer is displayed.")
(defvar lcomp-completion-buffer nil
  "This variable hold completion buffer.")

(defvar lcomp-select-completion-window-key "\M-v")
(defvar lcomp-select-completion-window-key-original-function nil)

(defadvice try-completion (after lcomp-ad disable)
  (setq lcomp-completion-halfway-p (stringp ad-return-value)))

(defadvice choose-completion (after lcomp-ad disable)
  (when lcomp-before-completion-winconf
    (lcomp-resume-before-completion-winconf-1)))

(defadvice delete-completion-window (around lcomp-ad disable)
  (if lcomp-before-completion-winconf
      (lcomp-resume-before-completion-winconf)
    ad-do-it))

(defun lcomp-setup-completion ()
  (when (and (not lcomp-before-completion-winconf)
	     (not (window-minibuffer-p)))
    (setq lcomp-display-completion-buffer-p t)
    (setq lcomp-completion-buffer standard-output)
    (setq lcomp-before-completion-winconf (current-window-configuration))))

(defun lcomp-resume-before-completion-winconf-1 ()
  (condition-case nil
      (set-window-configuration lcomp-before-completion-winconf)
    (error 
     (message "%s occured. bat ignore." (error-message-string err))))
  (setq lcomp-before-completion-winconf nil)
  (setq lcomp-completion-buffer nil))

(defun lcomp-resume-before-completion-winconf ()
  (when (and lcomp-before-completion-winconf
	     (not (or (and (eq this-command 'self-insert-command)
			   (string-match "\\(\\sw\\|\\s_\\)"
					 (this-command-keys)))
		      (eq (current-buffer) lcomp-completion-buffer)
		      (window-minibuffer-p)
		      lcomp-display-completion-buffer-p
		      lcomp-completion-halfway-p)))
    (let ((buf (current-buffer)))
      (lcomp-resume-before-completion-winconf-1)
      (unless (eq buf (current-buffer))
	(switch-to-buffer buf))))
  (setq lcomp-display-completion-buffer-p nil)
  (setq lcomp-completion-halfway-p nil))

(defun lcomp-select-completion-window ()
  (interactive)
  (select-window (get-buffer-window lcomp-completion-buffer)))

(defun lcomp-select-completion-window-or-original ()
  (interactive)
  (if lcomp-before-completion-winconf
      (lcomp-select-completion-window)
    (call-interactively lcomp-select-completion-window-key-original-function)))

(defun lcomp-install ()
  "Install lcomp.
This adds some hooks, advices, key definitions."
  (interactive)
  (add-hook 'completion-setup-hook 'lcomp-setup-completion)
  (add-hook 'post-command-hook 'lcomp-resume-before-completion-winconf)

  (ad-enable-regexp "^lcomp-ad$")
  (ad-activate-regexp "^lcomp-ad$" t)

  (setq lcomp-select-completion-window-key-original-function
	(lookup-key global-map lcomp-select-completion-window-key))
  (define-key global-map lcomp-select-completion-window-key
    'lcomp-select-completion-window-or-original))

(defun lcomp-uninstall ()
  "Uninstall lcomp.
This removes some hooks, advices, key definitions."
  (interactive)
  (remove-hook 'completion-setup-hook 'lcomp-setup-completion)
  (remove-hook 'post-command-hook 'lcomp-resume-before-completion-winconf)

  (ad-disable-regexp "^lcomp-ad$")

  (define-key global-map lcomp-select-completion-window-key
    lcomp-select-completion-window-key-original-function))

(provide 'lcomp)

;;; lcomp.el ends here