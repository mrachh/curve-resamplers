#include "complex.h"
#include "fftw3.h"
#include "stdlib.h"
#include "math.h"
#include "curve_resamplers_c.h"
#include "cprini.h"

int main(int argc, char **argv)
{
  cprin_init("stdout","fort.13");
  cprin_skipline(2);

  int ns = 36;
  double a = 3;
  double b = 2;
  double *xs = (double *)malloc(ns*(sizeof(double)));
  double *ys = (double *)malloc(ns*(sizeof(double)));
  double *dxs = (double *)malloc(ns*(sizeof(double)));
  double *dys = (double *)malloc(ns*(sizeof(double)));
  double t = 0;
  double st = 0;
  double ct = 0;

  CPX *par1 = (CPX *)malloc((2*ns+1)*sizeof(CPX));

  for (int i=0;i<ns;i++)
  {
     t = M_PI*2*i/ns;
     st = sin(t);
     ct = cos(t);
     xs[i] = a*ct;
     ys[i] = b*st;
     dxs[i] = -a*st;
     dys[i] = b*ct;
  }


  fftw_complex *in, *out;
  fftw_plan p;
  in = (fftw_complex*) fftw_malloc(sizeof(fftw_complex)*ns);
  out = (fftw_complex*) fftw_malloc(sizeof(fftw_complex)*ns);
  
  for (int i=0;i<ns;i++)
  {
    in[i] = xs[i] + I*ys[i];
  }
  p = fftw_plan_dft_1d(ns, in, out, FFTW_FORWARD, FFTW_ESTIMATE);
  fftw_execute(p);

  for (int i=0;i<ns;i++)
  {
    par1[i] = out[i]/ns;
    out[i] = 0;
    in[i] = dxs[i] + I*dys[i];
  }

  fftw_execute(p);

  for (int i=0;i<ns;i++)
  {
    par1[i+ns] = out[i]/ns;
  }

  par1[2*ns] = 0;

  int ier = 0;
  int nh = 0;

  double rl = 2*M_PI;
  int n=4*ns;

  double eps = 1e-9;
  double *tts = (double *)malloc((n+1)*(sizeof(double)));
  double *xinfo = (double *)malloc(6*n*(sizeof(double)));
  double h = 0;
  double rltot = 0;
  int lw = 2000;
  double *ww = (double *)malloc(lw*(sizeof(double)));
  int lsave = 0;



  curve_resampler_guru_(&ier, &ns, &nh, par1, &rl, &n, &eps, tts, xinfo, 
      &h, &rltot, ww, &lw, &lsave);
  
  double erra = 0;
  double ra = 0;
  double xex = 0;
  double yex = 0;
  double rnxex = 0;
  double rnyex = 0;
  double dxex = 0;
  double dyex = 0;
  double ds = 0;

  for (int i=0; i<n; i++)
  {
    t = tts[i];

    ct = cos(t);
    st = sin(t);
    xex = a*ct;
    yex = b*st;

    dxex = -a*st;
    dyex = b*ct;

    ds = sqrt(pow(dxex,2) + pow(dyex,2));
    
    rnxex = dyex/ds;
    rnyex = -dxex/ds;
    erra = erra + pow(xex-xinfo[6*i],2);
    erra = erra + pow(yex-xinfo[6*i+1],2);
    erra = erra + pow(rnxex-xinfo[6*i+2],2);
    erra = erra + pow(rnyex-xinfo[6*i+3],2);
    ra = ra + pow(xex,2);
    ra = ra + pow(yex,2);
    ra = ra + pow(rnxex,2);
    ra = ra + pow(rnyex,2);

  }
  erra = sqrt(erra/ra);
  cprind("Error in arclength parameterized curve=",&erra,1);

  

  
  



  free(ww);
  free(tts);
  free(xinfo);
  free(par1);
  free(xs);
  free(ys);
  free(dxs);
  free(dys);

  fftw_destroy_plan(p);
  fftw_free(in); fftw_free(out);

  return 0;

}
