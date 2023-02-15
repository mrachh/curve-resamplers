# Makefile for curveresampler
#
# This is the only makefile; there are no makefiles in subdirectories.
# Users should not need to edit this makefile (doing so would make it
# hard to stay up to date with repo version). Rather in order to
# change OS/environment-specific compilers and flags, create 
# the file make.inc, which overrides the defaults below (which are 
# for ubunutu linux/gcc system). 

# compiler, and linking from C, fortran

CC=gcc
FC=gfortran

FFLAGS= -fPIC -O3 -funroll-loops -std=legacy -w 
CFLAGS= -fPIC -O3 -funroll-loops -std=c99 -I/usr/include -I src

CLIBS = -lgfortran -lm -ldl -lfftw3

LIBS = -lm

# flags for MATLAB MEX compilation..
MFLAGS=-compatibleArrayDims -lgfortran -DMWF77_UNDERSCORE1 -lm -ldl   
MWFLAGS=-c99complex -i8 

# location of MATLAB's mex compiler
MEX=mex

# For experts, location of Mwrap executable
MWRAP=../../mwrap/mwrap


CR_INSTALL_DIR=$(PREFIX)
ifeq ($(PREFIX),)
	CR_INSTALL_DIR = ${HOME}/lib
endif

# For your OS, override the above by placing make variables in make.inc
-include make.inc


# objects to compile
#
# Common objects
 
# Helmholtz objects
OBJS = src/prini.o  \
	src/durdec.o src/corrand4.o src/dumb_conres.o \
	src/legeexps.o src/curve_filtering.o src/curve_resampler.o \
	src/dfft.o 

TOBJS = src/hkrand.o src/dlaran.o

# C headers and objects
COBJS = c/cprini.o c/utils.o
CHEADERS = c/cprini.h c/utils.h c/curve_resamplers_c.h

.PHONY: usage test matlab install c-examples

default: usage 

all: test matlab 

usage:
	@echo "Makefile for curve resampler. Specify what to make:"
	@echo "  make install - compile and install the main library"
	@echo "  make install PREFIX=(INSTALL_DIR)  "
	@echo "                      compile and install the main library at custom"
	@echo "                      location given by PREFIX"
	@echo "  make test - compile and run fortran test in test/"
	@echo "  make c-examples - compile and run the examples in c"
	@echo "  make matlab - compile matlab interfaces"
	@echo "  make mex - generate matlab interfaces (for expert users only, requires mwrap)"
	@echo "  make clean - also remove lib, MEX, py, and demo executables"


# implicit rules for objects (note -o ensures writes to correct dir)
%.o: %.cpp %.h
	$(CXX) -c $(CXXFLAGS) $< -o $@
%.o: %.c %.h
	$(CC) -c $(CFLAGS) $< -o $@
%.o: %.f %.h
	$(FC) -c $(FFLAGS) $< -o $@

LIBNAME = libcurveresampler
STATICLIB = $(LIBNAME).a
DYNAMICLIB = $(LIBNAME).so
LIMPLIB = $(DYNAMICLIB)


install: $(STATICLIB) $(DYNAMICLIB)
	echo $(CR_INSTALL_DIR)
	mkdir -p $(CR_INSTALL_DIR)
	cp -f lib/$(DYNAMICLIB) $(CR_INSTALL_DIR)/
	cp -f lib-static/$(STATICLIB) $(CR_INSTALL_DIR)/
	[ ! -f lib/$(LIMPLIB) ] || cp lib/$(LIMPLIB) $(CR_INSTALL_DIR)/
	@echo "Make sure to include " $(CR_INSTALL_DIR) " in the appropriate path variable"
	@echo "    LD_LIBRARY_PATH on Linux"
	@echo "    PATH on windows"
	@echo "    DYLD_LIBRARY_PATH on Mac OSX (not needed if default installation directory is used"
	@echo " "
	@echo "In order to link against the dynamic library, use -L"$(CR_INSTALL_DIR) " -lcurveresampler"


$(STATICLIB): $(OBJS)
	ar rcs $(STATICLIB) $(OBJS)
	mv $(STATICLIB) lib-static/
$(DYNAMICLIB): $(OBJS)
	$(FC) -shared -fPIC $(OBJS) -o $(DYNAMICLIB) $(DYLIBS)
	mv $(DYNAMICLIB) lib/
	[ ! -f $(LIMPLIB) ] || mv $(LIMPLIB) lib/


# matlab..
MWRAPFILE = curve_resampler
GATEWAY = $(MWRAPFILE)

matlab:	$(STATICLIB) matlab/$(GATEWAY).c
	$(MEX) -v matlab/$(GATEWAY).c lib-static/$(STATICLIB) $(MFLAGS) -output matlab/curve_resampler $(MEXLIBS);


mex:  $(STATICLIB)
	cd matlab; $(MWRAP) $(MWFLAGS) -list -mex $(GATEWAY) -mb $(MWRAPFILE).mw;\
	$(MWRAP) $(MWFLAGS) -mex $(GATEWAY) -c $(GATEWAY).c $(MWRAPFILE).mw;\
	$(MEX) -v $(GATEWAY).c ../lib-static/$(STATICLIB) $(MFLAGS) -output $(MWRAPFILE) $(MEX_LIBS); \

#
##  test
#

test: $(OBJS) $(TOBJS) test/curve
	time -p ./test/int2-curve

test/curve:
	$(FC) $(FFLAGS) test/curve_resampler_test.f $(OBJS) $(TOBJS) -o test/int2-curve 


# C examples
c-examples: $(COBJS) $(OBJS) $(CHEADERS) c/resample c/resample-pts
	c/int2-resample
	c/int2-resample-pts

c/resample:
	$(CC) $(CFLAGS) c/test_curve_resampler_guru.c $(COBJS) $(OBJS) -o c/int2-resample $(CLIBS)

c/resample-pts:
	$(CC) $(CFLAGS) c/test_curve_resampler_pts.c $(COBJS) $(OBJS) -o c/int2-resample-pts $(CLIBS)



clean: objclean
	rm -f test/int2-curve 

objclean: 
	rm -f $(OBJS) 
	rm -f test/*.o test/*.o c/*.o
