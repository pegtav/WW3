#!/bin/bash
#SBATCH --job-name=comp-WW3-sT475
#SBATCH --nice=0
#SBATCH --time=00:20:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

### #SBATCH --output=%x.o%j
### #SBATCH --error=%x.e%j

ww3_folder=/scale/user/pgradefe/WW3/ww3-v6.07.1
comp=HPC_debug
switch=T475

# Change to the directory where the job was submitted
cd "$SLURM_SUBMIT_DIR"

# Set user file creation mask
umask 002

# Load the required libraries
module purge
module load netcdf-fortran/4.6.2-parallel

# -- WW3 environment settings --
# These compilation instructions assume that wwatch3.env has been set up correctly !
export WWATCH3_NETCDF=NC4
export NETCDF_CONFIG=$(command -v nf-config)  # Fortran config: gives netcdf.mod dir and -lnetcdff

# Submit the job
date
printf "Working on $SLURM_SUBMIT_DIR\n"

printf "Running w3_setup ...\n"
time $ww3_folder/model/bin/w3_setup $ww3_folder/model -q -c $comp -s $switch > ${SLURM_JOB_NAME}_w3_setup.log 2>&1
printf "\nSetup complete !\n"

printf "Running w3_automake ...\n"
time $ww3_folder/model/bin/w3_automake > ${SLURM_JOB_NAME}_w3_automake.log 2>&1
printf "\nCompilation complete !\n"

printf "Moving exe folder ... "
mv -v $ww3_folder/model/exe/* $SLURM_SUBMIT_DIR/../ >> ${SLURM_JOB_NAME}_w3_automake.log 2>&1
printf "Done !\n"
date
