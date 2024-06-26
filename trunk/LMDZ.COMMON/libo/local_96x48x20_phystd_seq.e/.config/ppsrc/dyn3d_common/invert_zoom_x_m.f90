












module invert_zoom_x_m

  implicit none

  INTEGER, PARAMETER:: nmax = 30000

contains

  subroutine invert_zoom_x(xf, xtild, Xprimt, xlon, xprimm, xuv)

    use coefpoly_m, only: coefpoly
    use nrtype, only: pi, pi_d, twopi_d, k8
    use serre_mod, only: clon

    include "dimensions.h"
    ! for iim

    REAL(K8), intent(in):: Xf(0:), xtild(0:), Xprimt(0:) ! (0:2 * nmax)
    real, intent(out):: xlon(:), xprimm(:) ! (iim)

    REAL(K8), intent(in):: xuv
    ! 0. si calcul aux points scalaires 
    ! 0.5 si calcul aux points U 

    ! Local:
    REAL(K8) xo1, Xfi, a0, a1, a2, a3, Xf1, Xprimin
    integer i, it, iter
    REAL(K8), parameter:: my_eps = 1e-6_k8

    REAL(K8) xxprim(iim), xvrai(iim) 
    ! intermediary variables because xlon and xprimm are simple precision

    !------------------------------------------------------------------

    DO i = 1, iim
       Xfi = - pi_d + (i + xuv - 0.75_k8) * twopi_d / iim

       it = 2 * nmax
       do while (xfi < xf(it) .and. it >= 1)
          it = it - 1
       end do

       ! Calcul de Xf(xvrai(i)) 

       xvrai(i) = xtild(it)

       IF (it == 2 * nmax) THEN
          it = 2 * nmax -1
       END IF

       CALL coefpoly(Xf(it), Xf(it + 1), Xprimt(it), Xprimt(it + 1), &
            xtild(it), xtild(it + 1), a0, a1, a2, a3)
       Xf1 = Xf(it)
       Xprimin = a1 + xvrai(i) * (2._k8 * a2 + xvrai(i) * 3._k8 * a3)
       xo1 = xvrai(i)
       iter = 1

       do
          xvrai(i) = xvrai(i) - (Xf1 - Xfi) / Xprimin
          IF (ABS(xvrai(i) - xo1) <= my_eps .or. iter == 300) exit
          xo1 = xvrai(i)
          Xf1 = a0 + xvrai(i) * (a1 + xvrai(i) * (a2 + xvrai(i) * a3))
          Xprimin = a1 + xvrai(i) * (2._k8 * a2 + xvrai(i) * 3._k8 * a3)
       end DO

       if (ABS(xvrai(i) - xo1) > my_eps) then
          ! iter == 300
          print *, 'Pas de solution.'
          print *, i, xfi
          STOP 1
       end if

       xxprim(i) = twopi_d / (iim * Xprimin)
    end DO

    DO i = 1, iim -1
       IF (xvrai(i + 1) < xvrai(i)) THEN
          print *, 'xvrai(', i + 1, ') < xvrai(', i, ')'
          STOP 1
       END IF
    END DO

    xlon = xvrai + clon / 180. * pi
    xprimm = xxprim

  end subroutine invert_zoom_x

end module invert_zoom_x_m
