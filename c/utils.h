#ifndef UTILS_H
#define UTILS_H
  
#include <stdint.h>
#include <complex.h>

typedef double complex CPX;
#define rand01() ((double)rand()/RAND_MAX)

void dzero(int n, double *a);
void czero(int n, CPX *a);

#endif
