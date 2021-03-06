******************************************************************************
*               broyden banded function
* more, garbow, and hillstrom, acm toms vol. 7 no. 1 (march 1981) 17-41
******************************************************************************

      subroutine getfun( x, n, f, m, ftf, fj, lfj, g, mode)

      implicit double precision (a-h,o-z)

      integer            n, m, lfj, mode

      double precision   x(n), f(m), ftf, fj(lfj,n), g(n)

      integer            nprob, nprobs, nstart, nstrts
      common /PROBLM/    nprob, nprobs, nstart, nstrts

      integer            nout
      common /IOUNIT/    nout

      logical            lf, lj

      integer            na, nb, nc, nd, nt, nh

      integer            i, j, j1, j2

      double precision   xi, xj, t

      double precision   ddot

      intrinsic          max, min

      integer            ilbw, iubw
      common /PARAM1/    ilbw, iubw
      save   /PARAM1/

      double precision   zero, one, two, three, five, ffteen
      parameter         (zero = 0.d0, one = 1.d0, two = 2.d0)
      parameter         (three = 3.d0, five = 5.d0, ffteen = 15.d0)

*=======================================================================

      if (mode .eq.  0)  goto    20
      if (mode .eq. -1)  goto    10
      if (mode .eq. -2)  goto    30

      na = mode / 1000
      nt = mode - na*1000
      nb = nt / 100
      nh = nt - nb*100
      nc = nh / 10
      nd = nh - nc*10

      lf = (na .ne. 0) .or. (nb .ne. 0) .or. (nd .ne. 0)
      lj = (nc .ne. 0) .or. (nd .ne. 0)

      if (lf .and. lj)  goto 300
      if (lf)           goto 100
      if (lj)           goto 200

*-----------------------------------------------------------------------

  10  continue

      nprobs = 1
      nstrts = 1

      n      = 10
      m      = n

      ilbw   = 5
      iubw   = 1

      if (nout .gt. 0)  write( nout, 9999)  n, m

      return

*-----------------------------------------------------------------------

  20  continue

      call dcopy( n, (-one), 0, x, 1)

      return

*-----------------------------------------------------------------------

  30  continue

      ftf = zero

      return

*-----------------------------------------------------------------------

 100  continue

      do 110 i = 1, n
        xi   = x(i)
        f(i) = xi*(two + five*xi*xi) + one
        j1   = max( 1, i-ilbw)
        j2   = min( n, i+iubw)
        do 110 j = j1, j2
          xj = x(j)
          if (j .ne. i)  f(i) = f(i) - xj*(one + xj)
 110  continue

      if (nb .ne. 0)  ftf = ddot( m, f, 1, f, 1)

      return

 200  continue

      do 210 j = 1, n
        call dcopy( m, zero, 0, fj( 1, j), 1)
 210  continue

      do 220 i = 1, n
        xi      = x(i)
        fj(i,i) = two + ffteen*xi*xi
        j1      = max( 1, i-ilbw)
        j2      = min( n, i+iubw)
        do 220 j = j1, j2
          if (j .ne. i)  fj(i,j) = -(one + two*x(j))
 220  continue

      return

 300  continue

      do 310 j = 1, n
        call dcopy( m, zero, 0, fj( 1, j), 1)
 310  continue

      do 320 i = 1, n
        xi      = x(i)
        t       = five*xi*xi
        f(i)    = xi*(two + t) + one
        fj(i,i) = two + three*t
        j1      = max( 1, i-ilbw)
        j2      = min( n, i+iubw)
        do 320 j = j1, j2
          xj = x(j)
          if (j .ne. i)  fj(i,j) = -(one + two*xj)
          if (j .ne. i)  f(i) = f(i) - xj*(one + xj)
 320  continue

      if (nb .ne. 0)  ftf = ddot( m, f, 1, f, 1)

      if (nd .eq. 0)  return

      do 330 j = 1, n
        g(j) = ddot( m, fj( 1, j), 1, f, 1)
 330  continue

      return

9999  format(/'1',70('=')//,
     *' broyden banded function (more et al.)'//,
     *'        number of variables =', i4,'  (variable)'/,
     *'        number of functions =', i4,'  (   = n  )'//,
     *        ' ',70('=')/)
      end

************************************************************************
************************************************************************

      subroutine dfjdxk ( k, x, n, dfj, ldfj, m, nonzro)

      implicit double precision (a-h,o-z)

      integer            k, n, ldfj, m, nonzro(n)

      double precision   x(n), dfj(ldfj,n)

      integer            i, j, j1, j2

      intrinsic          max, min

      integer            ilbw, iubw
      common /PARAM1/    ilbw, iubw
      save   /PARAM1/

      double precision   zero, two, thirty
      parameter         (zero = 0.d0, two = 2.d0, thirty = 30.d0)

*=======================================================================

      do 100 j = 1, n
        nonzro(j) = 0
        call dcopy( m, zero, 0, dfj( 1, j), 1)
  100 continue

      nonzro(k) = 1

      dfj(k,k) = thirty*x(k)
      j1 = max( 1, k-iubw)
      j2 = min( n, k+ilbw)

      do 200 i = j1, j2
        if (k .ne. i)  dfj(i,k) = -two
 200  continue

      return
      end

************************************************************************
************************************************************************

      subroutine dfkdij( k, x, n, hess, lhess, linear)

      implicit double precision (a-h,o-z)

      logical            linear

      integer            k, n, lhess

      double precision   x(n), hess(lhess,n)
       
      integer            j, j1, j2

      intrinsic          max, min

      integer            ilbw, iubw
      common /PARAM1/    ilbw, iubw
      save   /PARAM1/

      double precision   zero, two, thirty
      parameter         (zero = 0.d0, two = 2.d0, thirty = 30.d0)

*=======================================================================

      do 100 j = 1, n
        call dcopy( n, zero, 0, hess( 1, j), 1)
  100 continue

      linear = .false.

      hess(k,k) = thirty*x(k)

      j1 = max( 1, k-ilbw)
      j2 = min( n, k+iubw)
      do 200 j = j1, j2
        if (j .ne. k)  hess(j,j) = -two
 200  continue

      return
      end
