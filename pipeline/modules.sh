#!/bin/bash
#SBATCH --job-name=modules
#SBATCH --output=cache/mechanism/modules.txt
#SBATCH --ntasks=2 --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10000
#SBATCH --time=1-24:00:00

module load R



Rscript scripts/mechanism/modulecluster/modules121.R result/gctcal/filtered88121ratioadjust.gct data/predicgct/realtcgacancerproject.txt result/mechanism/modulecluster/select88/adjustfilter/ &
Rscript scripts/mechanism/modulecluster/modules121.R result/gctcal/filtered88121ratiofpkm.gct data/predicgct/realtcgacancerproject.txt result/mechanism/modulecluster/select88/fpkmfilter/ &

Rscript scripts/mechanism/modulecluster/modules121.R result/gctcal/filtered88121ratioadjust.gct data/predicgct/realtcganormalproject.txt result/mechanism/modulecluster/select88/adjustfilternor/ &
Rscript scripts/mechanism/modulecluster/modules121.R result/gctcal/filtered88121ratiofpkm.gct data/predicgct/realtcganormalproject.txt result/mechanism/modulecluster/select88/fpkmfilternor/ &
wait

