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

# mpirun -np $SLURM_NTASKS $NWCHEM_TOP/bin/LINUX64/nwchem /home/b11902043/PP-nwchem/inputs/w11_b3lyp_cc-pvtz_energy.nw

echo "Using INPUT=<INPUT>" 1>&2
mpirun -np $SLURM_NTASKS $NWCHEM_TOP/bin/LINUX64/nwchem <INPUT>