      implicit real *8 (a-h,o-z)
      real *8, allocatable :: x0(:),y0(:),wsave(:),xy(:,:)
      real *8, allocatable :: srcinfo(:,:)
      real *8, allocatable :: ts(:),xver(:),yver(:)
      real *8, allocatable :: ts0(:),wts0(:)
      real *8, allocatable :: work(:)

      call prini(6,13)

      n = 12
      r1 = 0.25d0
      r2 = 0.5d0
      allocate(x0(n+1),y0(n+1),ts(n+1),xver(n+1),yver(n+1))
      allocate(xy(2,n))

c      open(unit=87,file='bunny10out')
cc
cc   input vertices
cc
c      do i=1,n
c        read(87,*) xtmp,ytmp
c        x0(i) = xtmp
c        y0(i) = ytmp
c      enddo
c      close(87)

      call letter_h(r1,r2,x0,y0,n)
      do i=1,n
        xy(1,i) = x0(i)
        xy(2,i) = y0(i)
      enddo


cc      open(unit=87,file='bunny10out')
cc      do i=1,n
cc        write(87,*) x0(i),y0(i)
cc      enddo

      

c
c  nb = band limit
c
      nb = 50
c
c  interpolation tolerance
c
      eps = 1.0d-5

      ierm = 0
      nmax = 4
      call simple_curve_resampler_mem(n,xy,nb,eps,nmax,nlarge,
     1   nout,lsave,lused,ierm)
      print *, nlarge,nout
      if(ierm.eq.4) then
        call 
     1     prinf('nb too small, resulting curve self intersecting*',i,0)
        call prinf('increase nb*',i,0)
      else if(ierm.eq.2) then
        call prinf('desired inteprolation accuracy not reached*',i,0)
        call prinf('try increasing nmax*',i,0)
      endif
     

      call prinf('nb=*',nb,1)
      call prinf('nlarge=*',nlarge,1)
      call prinf('nout=*',nout,1)
      print *, "lsave=",lsave
      print *, "lused=",lused

      allocate(wsave(lsave))
      ier = 0
      allocate(srcinfo(6,nout))
      call simple_curve_resampler_guru(n,xy,nb,nlarge,lsave,lused,nout,
     1   srcinfo,h,curvelen,wsave,ts,ier)
      call prinf('ier=*',ier,1)
      call prinf('nout=*',nout,1)
      call prinf('nlarge=*',nlarge,1)
      call prinf('nb=*',nb,1)
      call prin2('curvelen=*',curvelen,1)
      print *, "curvelen=",curvelen


      
      erra = 0
      ra = 0
      do i=1,n
        xver(i) = 0
        yver(i) = 0
        call eval_curve(ier,ts(i),wsave,xver(i),yver(i),dxt,dyt,curv)
        erra = erra + (xver(i)-xy(1,i))**2
        ra = ra + xy(1,i)**2
        erra = erra + (yver(i)-xy(2,i))**2
        ra = ra + xy(2,i)**2
      enddo
      erra = sqrt(erra/ra)
      print *, "erra=",erra
      print *, "ra=",ra

      call prin2('error in curve interpolation=*',erra,1)


      stop
      end
c
c
c
c
c
c
c


      subroutine letter_h(r1,r2,x,y,n)
      implicit real *8 (a-h,o-z)
      real *8 x(12),y(12)

      n = 12
      x(12) = 0
      x(11) = r1
      x(10) = r1
      x(9) = r1+r2
      x(8) = r1+r2
      x(7) = 2*r1+r2
      x(6) = 2*r1+r2
      x(5) = r1+r2
      x(4) = r1+r2
      x(3) = r1
      x(2) = r1
      x(1) = 0

      y(12) = 1
      y(11) = 1
      y(10) = r1/2
      y(9) = r1/2
      y(8) = 1
      y(7) = 1
      y(6) = -1
      y(5) = -1
      y(4) = -r1/2
      y(3) = -r1/2
      y(2) = -1
      y(1) = -1
      

      return
      end

c 
c 
