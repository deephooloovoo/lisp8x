[Save values, functions and properties in file]
[Use: (create '(myfile l) 0) (snapshot)]
<de snapshot ()
	((boundp 'x)
		(print (list 'setq 'x (list 'quote x)) 0) )
	<mapc (oblist)
		'((x)
			((and (boundp x) (not (eq x 'x)))
				(print (list 'setq x (list 'quote (eval x))) 0) )
			((and (getd x) (not (eq t (getd x))))
				(print (append (list 'de x) (getd x)) 0) )
			((getpl x)
				(print
					(list 'putpl (list 'quote x) (list 'quote (getpl x)))
					0 ) >
	(putc 26 0)
	(close 0) >

