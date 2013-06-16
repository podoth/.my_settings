;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; builtin
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; 使わない割に重いvcを無効化
;;;
(setq vc-handled-backends ())
(remove-hook 'find-file-hook 'vc-find-file-hook)
(remove-hook 'kill-buffer-hook 'vc-kill-buffer-hook)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; package
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; modeline-git-branch
;;; vcより軽く、モードラインにブランチ名を表示
;;;
(require 'modeline-git-branch)
(modeline-git-branch-mode 1)

;;;
;;; git-gutter.el
;;; gitのdiffを使って更新点を強調表示
;;;
(require 'git-gutter-fringe)
(global-git-gutter-mode t)
;;更新頻度を下げる
(setq git-gutter:update-hooks '(find-file-hook after-save-hook after-revert-hook))
;; M-P/M-N でdiffの移動
(global-set-key "\M-N" 'git-gutter:next-hunk)
(global-set-key "\M-P" 'git-gutter:previous-hunk)

;;;
;;; magit
;;;
(autoload 'magit-status "magit")
(global-set-key (kbd "C-c g") 'magit-status)

;; rebase-mode
(require' rebase-mode)

;; diffの色付け
(eval-after-load 'magit
  '(progn
     (set-face-foreground 'magit-diff-add "blue")
     (set-face-foreground 'magit-diff-del "red")
     (set-face-foreground 'magit-diff-file-header "#4040ff")))

;; 複数選択可能にするための設定
;; http://d.hatena.ne.jp/ken_m/20111225/1324833439
(defvar my-magit-selected-files ()
  "選択されているファイルの名前のリスト。")

(defconst my-magit-file-beginning-regexp
  "^\t\\(Unmerged +\\|New +\\|Deleted +\\|Renamed +\\|Modified +\\|\\? +\\)?"
  "ファイルを表す行の行頭の正規表現。")

(defface my-magit-selected-face
  '((((class color) (background light))
     :background "LightGoldenRod")
    (((class color) (background dark))
     :background "DarkGoldenRod"))
  "選択中のファイルを表すフェイス。")

(defun my-magit-valid-buffer-p ()
  "操作可能な Magit のバッファかどうか。"
  (or (and (boundp 'magit-version)
           (eq major-mode 'magit-status-mode)) ; ver >= 1.1.0
      (eq major-mode 'magit-mode))) ; ver < 1.1.0

(defun my-magit-select-files (prefix)
  "ポイントのある行、もしくはリージョンのある行のファイルを選択。
PREFIX が t の場合 (前置引数がある場合) は、これまでの選択を一旦破棄してから処理します。"
  (interactive "P")
  (when (my-magit-valid-buffer-p)
    (when prefix (my-magit-clear-selected-files))
    (let (beg end lines)
      (if (and transient-mark-mode mark-active)
          (progn
            (setq mark-active nil)
            (setq beg (min (point) (mark)))
            (setq end (max (point) (mark)))
            (save-excursion
              (goto-char beg)
              (setq beg (line-beginning-position))
              (goto-char end)
              (unless (eq end (line-beginning-position))
                (setq end (line-end-position)))))
        (setq beg (line-beginning-position))
        (setq end (line-end-position)))
      (setq lines (split-string (buffer-substring-no-properties beg end) "[\n]+"))
      (while lines
        (let ((line (car lines)))
          (setq lines (cdr lines))
          (when (string-match (concat my-magit-file-beginning-regexp "\\(.+\\)") line)
            (let* ((file (match-string 2 line))
                   (hi-regexp (concat my-magit-file-beginning-regexp (regexp-quote file))))
              (if (member file my-magit-selected-files)
                  (progn
                    (setq my-magit-selected-files (delete file my-magit-selected-files))
                    (hi-lock-unface-buffer hi-regexp))
                (setq my-magit-selected-files (cons file my-magit-selected-files))
                (hi-lock-face-phrase-buffer hi-regexp 'my-magit-selected-face)))))))))

(defun my-magit-clear-selected-files ()
  "`my-magit-select-files' で選択されたファイルを全て破棄する。"
  (interactive)
  (when (my-magit-valid-buffer-p)
    (while my-magit-selected-files
      (hi-lock-unface-buffer (concat my-magit-file-beginning-regexp
                                     (regexp-quote (car my-magit-selected-files))))
      (setq my-magit-selected-files (cdr my-magit-selected-files)))))

(defun my-magit-re-hi-lock (&optional buffer)
  "`my-magit-select-files' で選択されたファイルを再度強調表示する。"
  (when (my-magit-valid-buffer-p)
    (let ((files my-magit-selected-files))
      (while files
        (let ((hi-regexp (concat my-magit-file-beginning-regexp
                                 (regexp-quote (car files)))))
          (hi-lock-unface-buffer hi-regexp)
          (hi-lock-face-phrase-buffer hi-regexp 'my-magit-selected-face)
          (setq files (cdr files)))))))

(defadvice magit-refresh-buffer (after my-hi-lock activate)
  "Magit のバッファの表示が更新された際には選択中のファイルを再度強調表示する。"
  (with-current-buffer (or buffer (current-buffer))
    (my-magit-re-hi-lock buffer)))

(defun my-magit-selected-files-string ()
  "`my-magit-select-files' で選択されたファイルを空白区切りの文字列として返す。"
  (if my-magit-selected-files
      (mapconcat (lambda (x) (concat "'" x "'")) my-magit-selected-files " ")
    ""))

(defun my-magit-insert-selected-files ()
  "`my-magit-select-files' で選択されたファイルを空白区切りの文字列としてバッファに挿入する。"
  (interactive)
  (insert (my-magit-selected-files-string)))


(add-hook 'magit-mode-hook
          ;; Magit で有効なキー設定
          (lambda ()
            (local-set-key (kbd "@") 'my-magit-select-files)
            (local-set-key (kbd "`") 'my-magit-clear-selected-files)))

(global-set-key (kbd "C-c i") 'my-magit-insert-selected-files)
