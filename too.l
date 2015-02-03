[Tool box]
[23jun87abu]

<progn

[Pretty printer]
<de depth (x)
	(cond
		((not x) 1)
		((atom x) 0)
		((max (1+ (depth (car x))) (depth (cdr x>

<de pretty (x l)
	(reptn l
		(reptn 4 (sp)) )
	(if (lessp (depth x) 3)
		(prin1 x)
		(putc 40)
		(while
			(and
				(member
					(prin1 (pop x))
					'(setq put get if when unless while until reptn))
				(lessp (depth (car x)) 3) )
			(sp) )
		(while x
			(cr)
			(pretty (pop x) (1+ l)) )
		(sp)
		(putc 41>

<de pp $x
	(pretty (getd (car $x)) 0)
	(cr>

[Structure editor]
<de patch (x [loc:] c l)
	(while
		<progn
			(if endflg (return x))
			(print x) (cr)
			(until (setq c (key)))
			(if (equal c 101)		[e: exit]
				(setq endflg t) )
			(not (equal 8 c)>		[BS: back one level]
		<setq x
			(cond
				((equal c 13) (cons (patch (car x)) (cdr x)))	[CR: patch car]
				((equal c 32) (cons (car x) (patch (cdr x))))	[SP: patch cdr]
				((equal c 113) (throw t 'quit))					[q: quit]
				((equal c 105) (cons (read) x))					[i: insert car]
				((equal c 100) (cdr x))							[d: delete car]
				((equal c 114) (cons (read) (cdr x)))			[r: replace]
		 		[DIGIT: pack the first n items into a list]
				((and (lessp 48 c) (lessp c 58))
					(setq l)
					(reptn (- c 48) (push (pop x) l))
					(cons (reverse l) x) )
				[@: remove parens around car]
				((equal c 64) (append (car x) (cdr x)))
				(x > )
	x>

<de ed $x
	(catch t
		(((endflg) (putd (car $x) (patch (getd (car $x)>

[Breakpoints]
<de break $x
	(unless (eq 'stop (caadr (getd (car $x)))) [broken]
		(putd (car $x)
			(cons
				(car (getd (car $x)))
				(cons
					(list
						'stop
						(if (cdr $x)
							(cadr $x)
							(list 'quote (car $x)) ) )
					(cdr (getd (car $x)>

<de unbreak $x
	(mapcar $x
		'((x)
			(if (eq 'stop (caadr (getd x))) [broken?]
				(putd x (cons (car (getd x)) (cddr (getd x>

[Tracing]
<de $trace $trace
	(reptn (inc step)
		(sp) )
	(prin1 (car $trace)) [Function name]
	(sp)
	(if (cadr $trace)
		<print
			(if (atom (cadr $trace)) [fexpr?]
				(eval (cadr $trace))
				(mapcar (cadr $trace) 'eval>
		(cr) )
	(print
		(prog1
			(eprogn (cddr $trace))
			(reptn step (sp))
			(prin1 (car $trace))
			(putc 61) [=]
			(dec step)>

<de trace $x
	(mapcar $x
		'((x)
			(unless (eq '$trace (caadr (getd x))) [already traced]
				(putd x [redefine]
					(list
						(car (getd x))
						(nconc (list '$trace x) (getd x>

<de untrace $x
	(mapcar $x
		'((x)
			(if (eq '$trace (caadr (getd x))) [Traced?]
				(putd x [Yes]
					(cddr (cadr (getd x>

<de nest? (x l)
	(if (atom l)
		(equal x l)
		(or (nest? x (car l)) (nest? x (cdr l)) >

[Who calls $x?]
<de who $x
	(mapcan (oblist)
		'((y)
			(and
				(pairp (getd y))
				(nest? (car $x) (cdr (getd y)))
				(list y) >

[List quick sort]
<de qsort (l n [loc:] i j x w)
	(setq i 0)
	(setq j (1- n))
	(setq x (nth (2/ n) l))
	(until (lessp j i)
		(while (lessp (nth i l) x)
			(inc i) )
		(while (lessp x (nth j l))
			(dec j) )
		(unless (lessp j i)
			(setq w (nth i l))
			(rplaca (nthcdr i l) (nth j l))
			(rplaca (nthcdr j l) w)
			(inc i)
			(dec j) ) )
	(if (lessp 0 j)
		(qsort l (1+ j)) )
	(if (lessp i n)
		(qsort (nthcdr i l) (- n i)) >

<de sort (l)
	(qsort l (length l))
	l >
t>
