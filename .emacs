;; ディレクトリ構成。builtinsとpackagesを完全に分けられていないので、一緒にしてもいいかもしれない
;; http://www.clear-code.com/blog/2011/2/16.html
;; https://bitbucket.org/sakito/dot.emacs.d/wiki/Home
;; .emacs.d
;; |-- init.el         ;; 基本的な設定を記述
;; |-- config          ;; 特定のモードや非標準のElispの設定をこの下に置く
;; |   |-- builtins.el ;; 標準Elispの設定
;; |   |-- packages.el ;; 非標準Elispの設定
;; |   `-- functions.el ;; package化されていないElispの設定
;; |-- packages        ;; 非標準Elispをこの下に置く
;; |-- share          ;; Emacs Lisp が利用する固定(基本いじくらない)リソース
;; |-- etc          ;; Emacs Lisp が利用する可変(基本いじる)リソース
;; `-- var          ;; キャシュファイルやバックアップファイル用
;;     `-- backup    ;; バックアップファイルをまとめる場所

(load "~/.emacs.d/init")
