#lang racket
(require plot)

(define (pt-cmp x y)
  (< (vector-ref x 1) (vector-ref y 1)))

(define (plot-times data)
  (parameterize ([plot-x-tick-label-anchor 'top-right]
                 [plot-x-tick-label-angle 35])
    (plot (discrete-histogram data #:y-min 10 #:y-max 400)
          #:y-label "time (milliseconds)" #:x-label #f
          #:out-file "/home/cji/g.png")))

(define-syntax (sorted-points stx)
  (syntax-case stx ()
    [(sorted-points a b) #'(list (vector 'a b))]
    [(sorted-points a b c . rest)
     #'(sort (cons #(a b) (sorted-points c . rest)) pt-cmp)]))

(module+ main
  (plot-times
   (sorted-points
    main-cpp         18.1
    main-haxe-cpp    74.8
    main-dylan       393.5
    main-nim         48.4
    main-ocaml       56.7
    main-ocamlopt    18.5
    main-haxe-neko   333
    main-py          40.6
    main-pypy        164)))
