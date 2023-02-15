#include "complex.h"
#include "fftw3.h"
#include "stdlib.h"
#include "math.h"
#include "curve_resamplers_c.h"
#include "cprini.h"
#include "stdio.h"

int main(int argc, char **argv)
{
  cprin_init("stdout","fort.13");
  cprin_skipline(2);

  FILE *stream;

  int ns = 316;
  double *xys = (double *)malloc(2*ns*(sizeof(double)));
// Fix file name is running from a different folder  
  stream = fopen("./data/bunny10flat_c","r");
  for(int i=0;i<2*ns;i++)
  {
    fscanf(stream, "%lf\n", &xys[i]);
  }
  fclose(stream);
  
  int nb = 150;
  double eps = 1e-13;
  int nmax = 4;
  int nlarge = 0;
  int nout = 0;
  int lsave = 0;
  int lused = 0;
  int ier = 0;
  
  simple_curve_resampler_mem_(&ns, xys, &nb, &eps, &nmax, 
    &nlarge, &nout, &lsave, &lused, &ier);


  double *ww = (double *)malloc(lsave*(sizeof(double)));
  double *tts = (double *)malloc((ns+1)*(sizeof(double)));
  
  double *sinfo = (double *)malloc(6*nout*(sizeof(double)));

  double hout = 0.0;
  double rltot = 0.0;

  simple_curve_resampler_guru_(&ns, xys, &nb, &nlarge, &lsave, 
    &lused, &nout, sinfo, &hout, &rltot, ww, tts, &ier);
  cprind("rltot=",&rltot,1);

  double x = 0;
  double y = 0;
  double dx = 0;
  double dy = 0;
  double curv = 0;
  double erra = 0;
  double ra = 0;

  for(int i=0; i<ns; i++)
  {
     eval_curve_(&ier, &tts[i], ww, &x, &y, &dx, &dy, &curv);

     erra = erra + pow(x-xys[2*i],2);
     erra = erra + pow(y-xys[2*i+1],2);
     ra = ra + pow(xys[2*i],2);
     ra = ra + pow(xys[2*i+1],2);
  }
  erra = sqrt(erra/ra);
  cprind("Error in interpolation=",&erra,1);
  cprind("tts=",tts,6);


  return 0;

}
