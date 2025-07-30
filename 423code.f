      program main

c*******************************************************************************
c
cc TOMS423_PRB tests the TOMS423 routines DECOMP and SOLVE.
c
c  Discussion:
c
c    Solve A*x = b where A is a given matrix, and B a right hand side.
c
      implicit none

      integer n
      integer ndim

      parameter ( n = 3 )
      parameter ( ndim = 4 )

      real a(ndim,ndim)
      real b(ndim)
      real determ
      integer i
      integer ip(ndim)
      integer j

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'TOMS423_PRB'
      write ( *, '(a)' ) '  DECOMP factors a general matrix;'
      write ( *, '(a)' ) '  SOLVE solves a factored linear system;'
      write ( *, '(a)' ) ' '
      write ( *, '(a,i6)' ) '  The matrix dimension NDIM = ', ndim
      write ( *, '(a,i6)' ) '  The number of equations is N = ', n
c
c  Set the values of the matrix A.
c
      a(1,1) = 1.0E+00
      a(1,2) = 2.0E+00
      a(1,3) = 3.0E+00

      a(2,1) = 4.0E+00
      a(2,2) = 5.0E+00
      a(2,3) = 6.0E+00

      a(3,1) = 7.0E+00
      a(3,2) = 8.0E+00
      a(3,3) = 0.0E+00

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  The matrix A:'
      write ( *, '(a)' ) ' '

      do i = 1, n
        write ( *, '(2x,3g14.6)' ) ( a(i,j), j = 1, n )
      end do
c
c  Set the values of the right hand side vector B.
c
      b(1) = 14.0E+00
      b(2) = 32.0E+00
      b(3) = 23.0E+00

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  The right hand side B is '
      write ( *, '(a)' ) ' '
      do i = 1, n
        write ( *, '(2x,g14.6)' ) b(i)
      end do
c
c  Factor the matrix.
c
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Factor the matrix'

      call decomp ( n, ndim, a, ip )
c
c  Get the determinant.
c
      determ = ip(n)
      do i = 1, n
        determ = determ * a(i,i)
      end do

      write ( *, '(a)' ) ' '
      write ( *, '(a,g14.6)' ) '  Matrix determinant = ', determ

      if ( ip(n) .eq. 0 ) then
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) '  DECOMP reports the matrix is singular.'
        stop
      end if
c
c  If no error occurred, now use DGESL to solve the system.
c
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Solve the linear system.'

      call solve ( n, ndim, a, b, ip )
c
c  Print the results.
c
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  SOLVE returns the solution:'
      write ( *, '(a)' ) '  (Should be (1,2,3))'
      write ( *, '(a)' ) ' '

      do i = 1, n
        write ( *, '(2x,g14.6)' ) b(i)
      end do

      stop
      end
      SUBROUTINE DECOMP(N, NDIM, A, IP)
      INTEGER N, NDIM, K, KP1, M, I, J
      REAL A(NDIM,NDIM),T
      INTEGER IP(NDIM)
C
C  MATRIX TRIANGULARIZATION BY GAUSSIAN ELIMINATION.
C  INPUT..
C    N = ORDER OF MATRIX.
C    NDIM = DECLARED DIMENSION OF ARRAY A.
C    A = MATRIX TO BE TRIANGULARIZED.
C  OUTPUT..
C    A(I,J), I.LE.J = UPPER TRIANGULAR FACTOR U.
C    A(I,J), I.GT.J = MULTIPLIERS = LOWER TRIANGULAR
C                     FACTOR, I-L.
C    IP(K), K.LT.N = INDEX OF K-TH PIVOT ROW.
C    IP(N) = (-1)**(NUMBER OF INTERCHANGES) OR 0.
C  USE 'SOLVE' TO OBTRAIN SOLUTION OF LINEAR SYSTEM.
C  DETERM(A) = IP(N)*A(1,1)*A(2,2)*...*A(N,N).
C  IF IP(N) = 0, A IS SINGULAR, SOLVE WILL DIVIDE BY ZERO.
C  INTERCHANGES FINISHED IN U, ONLY PARTLY IN L.
C
      IP(N) = 1
      DO 6 K = 1,N
        IF (K.EQ.N) GO TO 5
        KP1 = K+1
        M = K
        DO 1 I = KP1,N
          IF(ABS(A(I,K)).GT.ABS(A(M,K)))M=I
1       CONTINUE
        IP(K) = M
        IF(M.NE.K) IP(N) = -IP(N)
        T = A(M,K)
        A(M,K) = A(K,K)
        A(K,K) = T
        IF(T.EQ.0.) GO TO 5
        DO 2 I = KP1,N
          A(I,K) = -A(I,K)/T
2       CONTINUE
        DO 4 J = KP1,N
          T = A(M,J)
          A(M,J) = A(K,J)
          A(K,J) = T
          IF(T.EQ.0.) GO TO 4
          DO 3 I = KP1,N
            A(I,J) = A(I,J) + A(I,K)*T
3         CONTINUE
4       CONTINUE
5       IF(A(K,K).EQ.0.) IP(N) = 0
6     CONTINUE
      RETURN
      END

      SUBROUTINE SOLVE(N, NDIM, A, B, IP)
      INTEGER N, NDIM, NM1, K, KP1, M, I, KB, KM1
      REAL A(NDIM,NDIM),B(NDIM),T
      INTEGER IP(NDIM)
C
C  SOLUTION OF LINEAR SYSTEM, A*X = B.
C  INPUT..
C    N = ORDER 0F MATRIX.
C    NDIM = DECLARED DIMENSION OF ARRAY A.
C    A = TRIANGULARIZED MATRIX OBTAINED FROM 'DECOMP'.
C    B = RIGHT HAND SIDE VECTOR.
C    IP = PIVOT VECTOR OBTAINED FROM 'DECOMP'.
C  DO NOT USE IF DECOMP HAS SET IP(N) = 0.
C  OUTPUT..
C    B = SOLUTION VECTOR, X.
C
      IF(N.EQ.1) GO TO 9
      NM1 = N-1
      DO 75 K = 1,NM1
        KP1 = K+1
        M = IP(K)
        T = B(M)
        B(M) = B(K)
        B(K) = T
        DO 7 I = KP1, N
          B(I) = B(I) + A(I,K)*T
7       CONTINUE
75    CONTINUE
      DO 85 KB = 1,NM1
        KM1 = N-KB
        K = KM1+1
        B(K) = B(K)/A(K,K)
        T = -B(K)
        DO 8 I = 1,KM1
          B(I) = B(I) + A(I,K)*T
8       CONTINUE
85    CONTINUE
9     B(1) = B(1)/A(1,1)
      RETURN
      END
