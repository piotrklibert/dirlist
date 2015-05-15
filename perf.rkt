#lang racket
(require plot)

(define run-count 10)
(define runnables
  (list
   "/home/cji/projects/klibert_pl/walkfiles/main-cpp"
   "/home/cji/projects/klibert_pl/walkfiles/main-dylan"
   "/home/cji/projects/klibert_pl/walkfiles/main-haxe-cpp"
   "/home/cji/projects/klibert_pl/walkfiles/main-haxe-neko"
   "/home/cji/projects/klibert_pl/walkfiles/main-nim"
   "/home/cji/projects/klibert_pl/walkfiles/main-ocaml"
   "/home/cji/projects/klibert_pl/walkfiles/main-ocamlopt"
   "/home/cji/projects/klibert_pl/walkfiles/main-py"))


(define-syntax-rule (fold1 fun lst)
  (foldl fun (car lst) (cdr lst)))

(define (basename string-path)
  (let-values ([(base name _) (split-path string-path)])
    (path->string name)))

(define (run-it r)
  (define-values
    (a b ms c)
    (time-apply system (list (string-append  r " >/dev/null"))))
  ms)

(define (get-data)
  (for/list ([r runnables])
    (define times (for/list ([_ run-count])
                    (run-it r)))
    (define avg (exact->inexact
                 (/ (fold1 + times) run-count)))
    (vector (basename r) avg)))



(define (pt-cmp x y)
  (< (vector-ref x 1)
     (vector-ref y 1)))

(define (plot-times data)
  (parameterize ([plot-x-tick-label-anchor 'top-right]
                 [plot-x-tick-label-angle 35])
    (plot (discrete-histogram data #:y-min 10 #:y-max 400)
          #:y-label "time (milliseconds)" #:x-label #f
          #:out-file (build-path (current-directory)
                                 "perf.png"))))

(module+ main
  (plot-times (sort (get-data) pt-cmp))
  (displayln "Done!"))
