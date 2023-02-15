# makefile overrides
# OS:       macOS
# Compiler: gfortran 9.X
# OpenMP:   enabled
#

CC=gcc
CXX=g++-9
FC=gfortran

ifeq ($(PREFIX),)
    CR_INSTALL_DIR=/usr/local/lib
endif


CFLAGS += -I src -I/usr/local/include 

# OpenMP with gcc on OSX needs the following
OMPFLAGS = -fopenmp
OMPLIBS = -lgomp


# FFTW additions
LIBS += -L/usr/local/lib -lfftw3


# MATLAB interface:
FDIR=$$(dirname `gfortran --print-file-name libgfortran.dylib`)
MFLAGS +=-L${FDIR}
MEX = $(shell ls -d /Applications/MATLAB_R20**.app)/bin/mex
#LIBS = -lm -lstdc++.6
#MEXLIBS= -lm -lstdc++.6 -lgfortran -ldl


