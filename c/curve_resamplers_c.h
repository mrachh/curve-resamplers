#include "utils.h"
#include "complex.h"


void simple_curve_resampler_mem_(int *n, double *xy, int *nb, double *eps,
        int *nmax, int *nlarge, int *nout, int *lsave, int *lused, int *ier);


void simple_curve_resampler_guru_(int *n, double *xy, int *nb, int *nlarge,
        int *lsave, int *lused, int *nout, double *srcinfoout, double *hout,
        double *curvelen, double *wsave, double *ts, int *ier);


void curve_resampler_guru_(int *ier, int *nx, int *nh, CPX *par1, 
         double *rl, int *n, double *eps, double *t, double *xinfo,
         double *h, double *rltot, double *w, int *lw, int *lsave);

void eval_curve_(int *ier, double *ts, double *wsave, double *x, double *y, double *dx, 
   double *dy, double *curv);
