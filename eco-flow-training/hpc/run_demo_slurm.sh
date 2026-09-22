#!/bin/bash
#SBATCH --job-name=nf_driver
#SBATCH --partition=codespace
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=01:00:00
#SBATCH --output=nf_driver_%j.log

# Run the Nextflow "driver" as a Slurm job. Nextflow itself only needs a small
# job; it then submits every pipeline step as its *own* Slurm job.
#
# Submit from the eco-flow-training folder:   sbatch hpc/run_demo_slurm.sh
# Watch it:                                   squeue
# Read the driver's output:                   cat nf_driver_<jobid>.log
#
# On a real cluster you'd swap in your own partition, add any `module load`
# lines, and use -profile singularity (or your institution's profile).
#
# -ansi-log false: print plain lines instead of the live-updating display,
# which is much easier to read in a log file.

nextflow run nf-core/demo -r 1.2.0 \
  -profile test,docker \
  -c codespaces.config \
  -c hpc/slurm_codespaces.config \
  --outdir demo_results \
  -ansi-log false \
  -resume
