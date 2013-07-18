(require 'indicators)
(require 'fringe-helper)

;; TODO Remove fringe indicators when flymake mode is disabled or when bufffer
;; is reverted (or ...)

(defcustom flymake-error-bitmap '(exclamation-mark error)
  "Bitmap (a symbol) used in the fringe for indicating errors.
The value may also be a list of two elements where the second
element specifies the face for the bitmap.  For possible bitmap
symbols, see `fringe-bitmaps'.  See also `flymake-warning-bitmap'.

The option `flymake-fringe-indicator-position' controls how and where
this is used."
  :group 'flymake
  :version "24.3"
  :type '(choice (symbol :tag "Bitmap")
                 (list :tag "Bitmap and face"
                       (symbol :tag "Bitmap")
                       (face :tag "Face"))))

(defcustom flymake-warning-bitmap 'question-mark
  "Bitmap (a symbol) used in the fringe for indicating warnings.
The value may also be a list of two elements where the second
element specifies the face for the bitmap.  For possible bitmap
symbols, see `fringe-bitmaps'.  See also `flymake-error-bitmap'.

The option `flymake-fringe-indicator-position' controls how and where
this is used."
  :group 'flymake
  :version "24.3"
  :type '(choice (symbol :tag "Bitmap")
                 (list :tag "Bitmap and face"
                       (symbol :tag "Bitmap")
                       (face :tag "Face"))))

(defcustom flymake-info-bitmap 'question-mark
  "Bitmap (a symbol) used in the fringe for indicating infos.
The value may also be a list of two elements where the second
element specifies the face for the bitmap.  For possible bitmap
symbols, see `fringe-bitmaps'.  See also `flymake-error-bitmap'.

The option `flymake-fringe-indicator-position' controls how and where
this is used."
  :group 'flymake
  :version "24.3"
  :type '(choice (symbol :tag "Bitmap")
                 (list :tag "Bitmap and face"
                       (symbol :tag "Bitmap")
                       (face :tag "Face"))))


(fringe-helper-define 'underline-bitmap '(center repeat)
  "...XXX."
  "...XXX."
  "..XXX.."
  "..XXX.."
  )

;; TODO support when only bitmap is specified : (defcustom flymake-info-bitmap 'question-mark
(setq flymake-info-bitmap '(underline-bitmap
                            flymake-indicator-info)
      flymake-warning-bitmap '(underline-bitmap
                               flymake-indicator-warning)
      flymake-error-bitmap '(underline-bitmap
                             flymake-indicator-error))

(defadvice flymake-post-syntax-check (after
                                      indicators-flymake-status
                                      activate compile)

  (let ((err-count (flymake-get-err-count flymake-err-info "e"))
        (warn-count (flymake-get-err-count flymake-err-info "w"))
        (info-count (flymake-get-err-count flymake-err-info "i")))
    ;; TODO clear only own indicators
    (ind-clear-indicators)
    (if (or (/= 0 err-count) (/= 0 warn-count) (/= 0 info-count))
        (mapc (lambda (item)
                (let* ((line (car item))
                       (level  (flymake-ler-type (car (cadr item))))
                       (bitmap (cond ((string= level "i") flymake-info-bitmap)
                                     ((string= level "w") flymake-warning-bitmap)
                                     (t   flymake-error-bitmap))))
                  ;; (message "rfringe: marking error at line %d %s" line (cadr bitmap))
                  (ind-create-indicator-at-line line
                                                :fringe 'right-fringe
                                                :managed t
                                                :dynamic t
                                                :face (cadr bitmap)
                                                :priority (cond ((string= level "i") 10 )
                                                                ((string= level "w") 50)
                                                                (t  100))
                                                :bitmap (car bitmap)
                                                :relative t)))

              ;; (rfringe-create-relative-indicator (rfringe--char-pos-for-line (car item))))
              flymake-err-info))))

(provide 'scrap-flymake-indicators)
