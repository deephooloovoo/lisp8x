[FACTOR.L]
[24may87abu]

[Chop factors d from n]
[Return d if this was n's biggest factor, else nil]
(de chopFact (d)
	(while (zerop (% n d))
		((equal 1 (setq n (/ n d)))
			(return d) ) ) )

[Return the largest factor of n if it is smaller than 'lim', else return nil
 to indicate that there is at least one factor greater than 'lim']
<de bigFact (n lim [loc:] d)
	(or
		(chopFact 2)
		(chopFact 3)
		(setq d 5)
		(while (lessp d lim)
			(when (chopFact d) (return d))
			(setq d (+ 2 d))
			(when (chopFact d) (return d))
			(setq d (+ 4 d)) >

[Factorize n]
<de factor (n [loc:] d addLst lim res)
	(setq d 2)
	(setq addLst '(1 2 2))
	(setq lim (1+ (sqrt n)))
	(while (lessp d lim)
		((zerop (% n d))
			(progn	[Found a factor]
				(push d res)
				(setq n (/ n d))
				(setq lim (1+ (sqrt n))) )
			(unless addLst
				(setq addLst '(4 2 4 2 4 6 2 6)) )
			(setq d (+ d (pop addLst))) ) )
	((equal n 1) res (cons n res)) >
