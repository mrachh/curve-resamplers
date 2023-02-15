#include "utils.h"
#include "math.h"

void dzero(int n, double *a)
{
  for(int i=0; i<n;i=i+1)
  {
    a[i] = 0;
  }
  return;
}


void czero(int n, CPX *a)
{
  for(int i=0; i<n;i=i+1)
  {
    a[i] = 0;
  }
  return;
}

