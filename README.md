# NWChem HPC Task

## Task Workload and Input

Participants are required to optimize the following workload for improved performance.

The task flow contains 2 steps:

1. Compile nwchem application locally with different compilation flags or optimized codebase

2. Use the compiled codebase and read inputs 



## Task Rules

- The results will be executed on **4 CPU nodes on twnia3 cluster**
- Results with execution time beyond `300 seconds` are considered INVALID
- Grading will be based on the `optimization method`, `performance improvement`, and `accuracy`
- **It is encouraged to modify source code** for further improvement but participants must demonstrate accuracy is preserved

## Optimization Guidelines

### Optimization Techniques

- **Compiler optimizations:** Use of different compilers (Intel, GCC, AOCC) and optimization flags
- **Mathematical libraries:** Integration of optimized BLAS/LAPACK libraries (Intel MKL, OpenBLAS, AOCL)
- Code modification: Find the bottleneck of the current nwchem codebase and try to modify it to achieve better performance without modifying its algorithm.
    - But nwchem is written in fortran :p
- Parallel strategies: MPI configuration, hybrid parallelization, process placement and affinity, and thread management
- Communication optimization: Reducing communication overhead and latency
- Refer to: [Getting Started with NWChem for ISC22 SCC](https://hpcadvisorycouncil.atlassian.net/wiki/spaces/HPCWORKS/pages/2799534081/Getting+Started+with+NWChem+for+ISC22+SCC)


### Prohibited Modifications

- Algorithm alteration: Changing fundamental computational algorithms
- Precision reduction: Lowering calculation accuracy or data precision
- Input modification: Altering molecular geometries, basis sets, or convergence criteria

### Provided Tools

The TAs provide a baseline precompiled toolchain: Intel oneAPI compilers + OpenMPI. To use the precompiled toolchain:

```bash
# Intel oneAPI environment
source /work/b11902043/PP25/intel/oneapi/setvars.sh --force

# Precompiled OpenMPI
export OMPI_HOME=/work/b11902043/PP25/openmpi
export PATH="$OMPI_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$OMPI_HOME/lib:$LD_LIBRARY_PATH"
```

You are also encouraged to use your own compiler/MPI stack (e.g., GCC/Clang/Intel + OpenMPI/MPICH) if it yields better performance. Please document the versions, build flags, and any libraries (BLAS/LAPACK/ScaLAPACK) you link.

## Example Execution

1. Compile nwchem with intel compiler and OpenMPI (Remember to change `NWCHEM_TOP` path)

```bash
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
```

2. Prepare sbatch script: `hw1-bonus.sh`. Remember to change `NWCHEM_TOP` path, and do not modify lines that start with `#SBATCH`

```bash
#!/bin/bash
#SBATCH --job-name=nwchem
#SBATCH --partition=ctest
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=64G            
#SBATCH --time=0:5:00
#SBATCH --cpus-per-task=1
#SBATCH --account=ACD114118
#SBATCH --output=nwchem.log
#SBATCH --error=nwchem.err

# Make sure to use your actual path
export NWCHEM_TOP=<PATH/TO/NWCHEM>


# You can use TAs prebuilt MPI
source /work/b11902043/PP25/intel/oneapi/setvars.sh --force
export OMPI_HOME=/work/b11902043/PP25/openmpi
export PATH="$OMPI_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$OMPI_HOME/lib:$LD_LIBRARY_PATH"

# nwchem
export NWCHEM_TARGET=LINUX64
export NWCHEM_MODULES=qm
export FC=mpifort
export OMP_NUM_THREADS=1

echo "Starting NWChem calculation..."
mpirun -np $SLURM_NTASKS $NWCHEM_TOP/bin/LINUX64/nwchem ./inputs/w12_b3lyp_cc-pvtz_energy.nw

```

The output will be located at `nwchem.log`. The end of the output should look like this

```bash
Total times  cpu:       46.9s     wall:       46.9s
```

The stderr will be located at `nwchem.err`.

## Automatic judge

To use the automatic judge, install the judge system (You only need to to this once ):

```bash
bash /work/b11902043/PP25/setup.sh
source ~/.bashrc # or restart terminal
```

We use `inputs/w12_b3lyp_cc-pvtz_energy.nw` as our final testcase. To submit your implementation, modify the last line of your `hw1-bonus.sh` to use absolute path of TA provided input (`/work/b11902043/PP25/hw1-bonus/inputs/w12_b3lyp_cc-pvtz_energy.nw`), any other input will lead to different result and will be considered invalid

```bash
mpirun -np $SLURM_NTASKS $NWCHEM_TOP/bin/LINUX64/nwchem /work/b11902043/PP25/hw1-bonus/inputs/w12_b3lyp_cc-pvtz_energy.nw
```

After that, you can run 
```bash
hw1-bonus-judge
```
to test your nwchem

The scoreboard is at: http://140.112.187.55:7771/scoreboard/hw1-bonus/

## Report

Your report must include complete, step-by-step NWChem compilation and build instructions and be fully reproducible; non-reproducible submissions will be penalized.

## Submission

Please zip the following files to a single archived file named `<studentID>.tar` with the first letter in lowercase and upload it to NTU COOL:

- `hw1-bonus.sh` – the run script of nwchem program.
- `README.md` – the step-by-step NWChem compilation and build instructions.
- report.pdf – your report.

Please follow the naming listed above carefully. Failing to adhere to the names
above will result to points deduction.

For instance, the correct way to archive your file is as follows:

```
mkdir b11000000
cp <your files> b11000000/
tar cvf b11000000.tar b11000000
Submut the file b11000000.tar to NTU COOL
```
