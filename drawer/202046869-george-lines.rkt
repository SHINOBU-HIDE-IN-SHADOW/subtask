#lang racket
(require racket/gui/base)
( require racket/draw )

;vector
(define (make-vect x y) (cons x y))
(define (xcor vect) (car vect))
(define (ycor vect) (cdr vect))
;rect
(define make-rectangle list)
( define origin ( make-vect 0 0) )
( define x-axis ( make-vect 730 0) )
( define y-axis ( make-vect 0 730) )
( define frame1 ( make-rectangle origin x-axis y-axis ) )
(define (first frame) (car frame))
(define (second frame) (car (cdr frame)))
(define (third frame) (car (cdr (cdr frame))))
;segment
(define (make-segment p1 p2) (cons p1 p2))
(define (start-segment seg) (car seg))
(define (end-segment seg) (cdr seg))

;operation
(define (+vect v1 v2)
(make-vect (+ (xcor v1) (xcor v2))
(+ (ycor v1) (ycor v2))))
(define (scale-vect vect factor)
(make-vect (* factor (xcor vect))
(* factor (ycor vect))))
(define (coord-map rect)(lambda(p)(+vect (first rect)(+vect (scale-vect (second rect)(xcor p)) (scale-vect (third rect)(ycor p))))))
(define (repeat func n x)(
if(= n 0)
  x
  (func (repeat func (- n 1) x))))
(define (rotate90 pict)(lambda(rect)(pict (make-rectangle (+vect (first rect) (second rect)) (third rect)(scale-vect (second rect) -1)))))
(define (draw-line f)(lambda(lst)
                       (let* ((x (start-segment lst)) (y (end-segment  lst)) (c (make-rectangle (f x) (f y))) )
                         (send dc draw-line (xcor (xcor c)) (ycor (xcor c)) (xcor (xcor (cdr c))) (ycor(xcor (cdr c)))))))
;george-vects
(define p1 (make-vect .25 0))
(define p2 (make-vect .35 .5))
(define p3 (make-vect .3 .6))
(define p4 (make-vect .15 .4))
(define p5 (make-vect 0 .65))
(define p6 (make-vect .4 0))
(define p7 (make-vect .5 .3))
(define p8 (make-vect .6 0))
(define p9 (make-vect .75 0))
(define p10 (make-vect .6 .45))
(define p11 (make-vect 1 .15))
(define p12 (make-vect 1 .35))
(define p13 (make-vect .75 .65))
(define p14 (make-vect .6 .65))
(define p15 (make-vect .65 .85))
(define p16 (make-vect .6 1))
(define p17 (make-vect .4 1))
(define p18 (make-vect .35 .85))
(define p19 (make-vect .4 .65))
(define p20 (make-vect .3 .65))
(define p21 (make-vect .15 .6))
(define p22 (make-vect 0 .85))

;george-lines
(define george-lines
  (list (make-segment p1 p2)
        (make-segment p2 p3)
        (make-segment p3 p4)
        (make-segment p4 p5)
        ;(make-segment p1 p6)
        ;(make-segment p5 p22)
        (make-segment p6 p7)
        (make-segment p7 p8)
        ;(make-segment p8 p9)
        (make-segment p9 p10)
        (make-segment p10 p11)
        ;(make-segment p11 p12)
        (make-segment p12 p13)
        (make-segment p13 p14)
        (make-segment p14 p15)
        (make-segment p15 p16)
        ;(make-segment p16 p17)
        (make-segment p17 p18)
        (make-segment p18 p19)
        (make-segment p19 p20)
        (make-segment p20 p21)
        (make-segment p21 p22)
        ))


;(define (flip pict)(lambda(rect)(pict (make-rectangle (+vect (first rect) (second rect)) (scale-vect (second rect) -1) (third rect) ))))
;<1-1>
(define (make-picture seglist)
(lambda (rect)(let*((z(coord-map rect)) (f(draw-line z)) )
           (for-each f seglist))))
;<1-2>
(define (rotate180 pict)(repeat rotate90 2  pict))

(define (flip pic)(lambda(rect)(pic (make-rectangle (+vect (first rect) (second rect)) (scale-vect (second rect) -1) (third rect)))))

( define ( screen-transform pict )
( lambda (rect )
(( rotate180 ( flip pict ))rect)))

;for <1-3>---------------------------------------------
(define (beside pic1 pic2 x )(lambda(rect)(pic1 (make-rectangle (first rect)(scale-vect (second rect) x) (third rect)))
                               (pic2 (make-rectangle (+vect (first rect) (scale-vect (second rect) x)) (scale-vect (second rect) (- 1 x)) (third rect)))))
(define (above pic1 pic2 x )(lambda(rect)((repeat rotate90 3 (beside (rotate90 pic1)  (rotate90 pic2) x))rect)))

(define (push-left pic x)(if( = x 0)
                            pic
                            (beside pic (push-left pic (- x 1))  0.75)))
(define (push-above pic x)(if( = x 0)
                             pic
                             (above  (push-above pic (- x 1)) pic 0.25)))
(define (push-corner pic x)(if( = x 0)
                             pic
                             (above (beside (push-above pic x) (push-corner pic (- x 1)) 0.75) (beside pic (push-left pic (- x 1)) 0.75) 0.25)))


( define george( make-picture george-lines ) )
(define fb-george (beside george (rotate180 (flip george))  0.5))
(define 4bat (above fb-george (flip fb-george) 0.5))


(define (4screen p1 r1 p2 r2 p3 r3 p4 r4)(lambda(rect)((beside (above (repeat rotate90 r1 p1) (repeat rotate90 r2 p2) 0.5) (above (repeat rotate90 r3 p3) (repeat rotate90 r4 p4) 0.5) 0.5)rect)))
(define (4same pic r1 r2 r3 r4)(4screen pic r1 pic r2 pic r3 pic r4)) 
;-------------------------------------------------------------------------------------------------------------------
(define st-george (screen-transform george))
;<1-3>
( define ( square-limit pict n ) (4same ( push-corner pict n ) 1 2 4 3) )
( define george-squarelimit( square-limit 4bat 2))
;========================= Picture ==============================
; MAKING FRAME WINDOW, CANVAS, and DC
(define frame (new frame% [label "Paint George"]
                   [width 747]
                   [height 769]))
(define canvas (new canvas% [parent frame]
                    [paint-callback
                     (lambda(cnavas dc)
                       (send dc set-pen red-pen)
                       (send dc set-brush no-brush)
                       (on-paint))]))
(define red-pen (make-object pen% "RED" 2 'solid))
(define no-brush (make-object brush% "BLACK" 'transparent))
(define dc (send canvas get-dc))
; DEFINE CALLBACK PAINT PROCEDURE
(define (on-paint) (george-squarelimit frame1))
;(define (on-paint) (st-george frame1))
;MAKING THE FRAME VISIBLE
(send frame show #t)
