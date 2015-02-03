[N-QUEEN for 8KLisp]

(de nqueen (m)
	(queen m nil m)>

(de qp (k m)
	((not m)
		nil
		((equal (abs (- n (car m))) k)
			t
			((qp (1+ k) (cdr m>

(de queen (n b l)
	((equal n 0)
		nil
		((or (member n b) (qp 1 b))
			(queen (1- n) b l)
			(nconc
				((equal (length b) (1- l))
					(progn (prin1 '*) (list (cons n b)) )
					(queen l (cons n b) l) )
				(queen (1- n) b l>
