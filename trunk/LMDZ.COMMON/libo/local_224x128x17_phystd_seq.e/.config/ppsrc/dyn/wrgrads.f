!
! $Header$
!
      subroutine wrgrads(if,nl,field,name,titlevar)
      implicit none

c   Declarations
c    if indice du fichier
c    nl nombre de couches
c    field   champ
c    name    petit nom
c    titlevar   Titre


!
! $Header$
!
      integer nfmx,imx,jmx,lmx,nvarmx
      parameter(nfmx=10,imx=200,jmx=150,lmx=200,nvarmx=1000)

      real xd(imx,nfmx),yd(jmx,nfmx),zd(lmx,nfmx),dtime(nfmx)

      integer imd(imx),jmd(jmx),lmd(lmx)
      integer iid(imx),jid(jmx)
      integer ifd(imx),jfd(jmx)
      integer unit(nfmx),irec(nfmx),itime(nfmx),nld(nvarmx,nfmx)

      integer nvar(nfmx),ivar(nfmx)
      logical firsttime(nfmx)

      character*10 var(nvarmx,nfmx),fichier(nfmx)
      character*40 title(nfmx),tvar(nvarmx,nfmx)

      common/gradsdef/xd,yd,zd,dtime,
     s   imd,jmd,lmd,iid,jid,ifd,jfd,
     s   unit,irec,nvar,ivar,itime,nld,firsttime,
     s   var,fichier,title,tvar


c   arguments
      integer if,nl
      real field(imx*jmx*lmx)

      integer, parameter:: wp = selected_real_kind(p=6, r=36)
      real(wp) field4(imx*jmx*lmx)

      character*10 name,file
      character*10 titlevar

c   local

      integer im,jm,lm,i,j,l,iv,iii,iji,iif,ijf

      logical writectl


      writectl=.false.

c     print*,if,iid(if),jid(if),ifd(if),jfd(if)
      iii=iid(if)
      iji=jid(if)
      iif=ifd(if)
      ijf=jfd(if)
      im=iif-iii+1
      jm=ijf-iji+1
      lm=lmd(if)

c     print*,'im,jm,lm,name,firsttime(if)'
c     print*,im,jm,lm,name,firsttime(if)

      if(firsttime(if)) then
         if(name.eq.var(1,if)) then
            firsttime(if)=.false.
            ivar(if)=1
         print*,'fin de l initialiation de l ecriture du fichier'
         print*,file
           print*,'fichier no: ',if
           print*,'unit ',unit(if)
           print*,'nvar  ',nvar(if)
           print*,'vars ',(var(iv,if),iv=1,nvar(if))
         else
            ivar(if)=ivar(if)+1
            nvar(if)=ivar(if)
            var(ivar(if),if)=name
            tvar(ivar(if),if)=trim(titlevar)
            nld(ivar(if),if)=nl
c           print*,'initialisation ecriture de ',var(ivar(if),if)
c           print*,'if ivar(if) nld ',if,ivar(if),nld(ivar(if),if)
         endif
         writectl=.true.
         itime(if)=1
      else
         ivar(if)=mod(ivar(if),nvar(if))+1
         if (ivar(if).eq.nvar(if)) then
            writectl=.true.
            itime(if)=itime(if)+1
         endif

         if(var(ivar(if),if).ne.name) then
           print*,'Il faut stoker la meme succession de champs a chaque'
           print*,'pas de temps'
           print*,'fichier no: ',if
           print*,'unit ',unit(if)
           print*,'nvar  ',nvar(if)
           print*,'vars ',(var(iv,if),iv=1,nvar(if))

           stop
         endif
      endif

c     print*,'ivar(if),nvar(if),var(ivar(if),if),writectl'
c     print*,ivar(if),nvar(if),var(ivar(if),if),writectl
      field4(1:imd(if)*jmd(if)*nl)=field(1:imd(if)*jmd(if)*nl)
      do l=1,nl
         irec(if)=irec(if)+1
c        print*,'Ecrit rec=',irec(if),iii,iif,iji,ijf,
c    s (l-1)*imd(if)*jmd(if)+(iji-1)*imd(if)+iii
c    s ,(l-1)*imd(if)*jmd(if)+(ijf-1)*imd(if)+iif
         write(unit(if)+1,rec=irec(if))
     s   ((field4((l-1)*imd(if)*jmd(if)+(j-1)*imd(if)+i)
     s   ,i=iii,iif),j=iji,ijf)
      enddo
      if (writectl) then

      file=fichier(if)
c   WARNING! on reecrase le fichier .ctl a chaque ecriture
      open(unit(if),file=trim(file)//'.ctl'
     &         ,form='formatted',status='unknown')
      write(unit(if),'(a5,1x,a40)')
     &       'DSET ','^'//trim(file)//'.dat'

      write(unit(if),'(a12)') 'UNDEF 1.0E30'
      write(unit(if),'(a5,1x,a40)') 'TITLE ',title(if)
      call formcoord(unit(if),im,xd(iii,if),1.,.false.,'XDEF')
      call formcoord(unit(if),jm,yd(iji,if),1.,.true.,'YDEF')
      call formcoord(unit(if),lm,zd(1,if),1.,.false.,'ZDEF')
      write(unit(if),'(a4,i10,a30)')
     &       'TDEF ',itime(if),' LINEAR 02JAN1987 1MO '
      write(unit(if),'(a4,2x,i5)') 'VARS',nvar(if)
      do iv=1,nvar(if)
c        print*,'if,var(iv,if),nld(iv,if),nld(iv,if)-1/nld(iv,if)'
c        print*,if,var(iv,if),nld(iv,if),nld(iv,if)-1/nld(iv,if)
         write(unit(if),1000) var(iv,if),nld(iv,if)-1/nld(iv,if)
     &     ,99,tvar(iv,if)
      enddo
      write(unit(if),'(a7)') 'ENDVARS'
c
1000  format(a5,3x,i4,i3,1x,a39)

      close(unit(if))

      endif ! writectl

      return

      END


