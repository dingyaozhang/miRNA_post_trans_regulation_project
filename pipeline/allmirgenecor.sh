#!/bin/bash
#SBATCH --job-name=bestcor
#SBATCH --output=cache/bestcortt.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=9
#SBATCH --time=10-24:00:00
#SBATCH --mem=120000
#SBATCH --mail-type=ALL
#SBATCH --mail-user=guagua19967@gmail.com


module load R

Rscript scripts/mechanism/allmirgenecorsimple.R result/mechanism/mirisoexactoncount.gct data/predicgct/realtcgacancerproject.txt result/mechanism/allmirgeneexactcorsimple.txt data/mechanism/focusedtype.txt
Rscript scripts/mechanism/allmirgenecorsimple.R result/mechanism/cclemirongene.gct cache/gctcal/cclerealproject.txt result/mechanism/cclemirgenecorsimple.txt
