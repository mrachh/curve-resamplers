curve-resamplers
===================

This repository contains basic codes along with MATLAB wrappers for 
reparametrizing curves in arc length, and fitting bandlimited curves through a 
collection of points. 

Installation
===================
* To install the fortran library, run `make install` after copying
  over the appropriate version of make.inc depending on the operating
  system (none is needed for linux). To verify successful installation
  of the library, run `make examples`. This should run both the tests
  and successful installation would end in a small error in the last
  line of the run.

* To generate the mex interfaces, run `make matlab`.



Reparametrization
===================
-------------------

Fortran interfaces
---------------------------------------------------
Curve reparametrization routines are in `src/curve_resampler.f`

The subroutines are:
* `curve_resampler_guru`: Given a fourier representation of the curve, an
  update in the normal direction, and a number of sample points, this
  subroutine computes an arclength parametrization of the updated curve

* `anafast`: given a function handle parametrizing a curve, this
  subroutine returns the curve sampled in arclength.


MATLAB interface
---------------------------------------------------

* `resample_curve.m`

Fitting bandlimited curves through a set of points
=====================================================

Fortran interface
---------------------------------------------------

Beylkin Rokhlin interpolatory bandlimited curve fitting routines are in
`src/curve_filtering.f`

* `simple_curve_resampler_guru`: Given a collection of points, and a
  bandlimit, resample the curve in arclength with nearly bandlimited
  curvature that passes through the input points. This routine 
  must be called after a call to `simple_curve_resampler_mem` which
  determines the number of points needed to sample the bandlimited
  curve. The memory management routine expects one additional 
  argument which is the number of doublings over the initial number
  of points to try and resolve the bandlimited curve.

MATLAB interface
---------------------------------------------------

* `resample_curve_pts.m` 


References
===================

* Beylkin, Daniel, and Vladimir Rokhlin. `Fitting a bandlimited curve to points in a plane.` 
  SIAM Journal on Scientific Computing 36.3 (2014): A1048-A1070.

Upcoming
===================
* Fortran and MATLAB wrappers for rsresa
* Currently the computed curvature is incorrect. Support for curvature
  evaluation will be available at a later date.

The original codes were written by Vladimir Rokhlin and Daniel Beylkin.
