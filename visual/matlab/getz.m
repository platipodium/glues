
function z=getz(alpha)
cl_register_function();

% Determine percentiles of the normal distribution using an approximation
! of the complementary error function by a Chebyshev polynom.
!
! For a given values of alpha (a), the program returns z(a) such that
! P[Z <= z(a)] = a. Check values are in the front cover of Neter et al.
!----------------------------------------------------------------------
  use nr, only : erfcc
!
real, parameter :: sq2 = 1.414213562
  integer, parameter :: itmax = 100
  real :: alpha
  real :: atmp, acalc, zr, zl, zm, z
  integer :: iter
!
  if (alpha .lt. 0.50) then
     atmp = alpha * 2.0
     zr = -0.1
     zl = 10.0
     iter = 0
     do while(.true.)
          iter= iter + 1
          if (iter .gt. itmax) then
             write(errio,'(a)') "Error in GETZ: Iter > ItMax"
             return
          end if
          zm = (zl + zr) / 2.0
          z = zm
          acalc = erfcc(z/sq2)
          if (acalc .gt. atmp) zr = zm
          if (acalc .le. atmp) zl = zm
         if (abs(acalc-atmp) .le. tol) exit
     end do
     z = -1.0 * z
  else if (alpha .ge. 0.50) then
     atmp =(alpha - 0.5) * 2.0
     zl = -0.1
     zr = 10.0
     iter = 0
     do while(.true.)
          iter= iter + 1
          if (iter .gt. itmax) then
             write(*,*) "Error in GETZ: Iter > ItMax"
             return
          end if
          zm = (zl + zr) / 2.0
          z = zm
          acalc = 1.0 - erfcc(zm/sq2)
          if (acalc .gt. atmp) zr = zm
          if (acalc .le. atmp) zl = zm
          if (abs(acalc-atmp) .le. tol) exit
     end do
  end if
  getz = z
!
  end function getz
!
