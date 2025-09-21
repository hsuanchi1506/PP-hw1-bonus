git clone https://github.com/nwchemgit/nwchem.git

export NWCHEM_TOP=<PATH/TO/NWCHEM>
export NWCHEM_TARGET=LINUX64
export NWCHEM_MODULES=qm

# source Intel env
source /work/b11902043/PP25/intel/oneapi/setvars.sh

# OpenMPI
export OMPI_HOME=/work/b11902043/PP25/openmpi
export PATH="$OMPI_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$OMPI_HOME/lib:$LD_LIBRARY_PATH"

# Intel compiler
export FC=mpifort
export CC=mpicc
export CXX=mpicxx
export MPICC=mpicc
export FFLAGS="-i8" FCFLAGS="-i8" F77FLAGS="-i8" # for intel compiler, must

export USE_MPI=y
export USE_MPIF=y
export USE_MPIF4=y
export ARMCI_NETWORK=MPI-PR

# Intel MKL math library
export BLAS_SIZE=8
export LAPACK_SIZE=8
export BLASOPT="-L${MKLROOT}/lib/intel64 -lmkl_intel_ilp64 -lmkl_intel_thread -liomp5 -lmkl_core -lpthread -lm -ldl"
export LAPACK_LIB="${BLASOPT}"
export USE_SCALAPACK=y
export SCALAPACK_SIZE=8
export SCALAPACK_LIB=" -L${MKLROOT}/lib/intel64 -lmkl_scalapack_ilp64 -lmkl_intel_ilp64 -lmkl_intel_thread -lmkl_core -lmkl_blacs_openmpi_ilp64 -liomp5 -lpthread -lm -ldl"

export USE_OPENMP=y
export USE_NOFSCHECK=TRUE
export USE_NOIO=TRUE

# Do it for clean build
# cd $NWCHEM_TOP/src && make realclean
cd $NWCHEM_TOP/src/tools && ./get-tools-github &&  MPICC=mpicc ./install-armci-mpi
cd $NWCHEM_TOP/src && make nwchem_config
make -j"$(nproc)" FFLAGS+=" -diag-disable=10448" CFLAGS+=" -diag-disable=10441"