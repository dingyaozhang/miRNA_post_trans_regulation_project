#!/bin/bash
#SBATCH --job-name=predict
#SBATCH --output=cache/predicgct/pred5p3p.txt
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10000
#SBATCH --time=5-24:00:00

module load R



Rscript scripts/predicgct/predict/svm20.macro.R result/predicgct/pred5p3p/5p3pout2.gct data/predicgct/realtcgacancerproject.txt result/predicgct/pred5p3p/5p3pres &
Rscript scripts/predicgct/predict/svm20.macro.R result/predicgct/pred5p3p/mirout.gct data/predicgct/realtcgacancerproject.txt result/predicgct/pred5p3p/mirres &
Rscript scripts/predicgct/predict/svm20.macro.R result/predicgct/pred5p3p/geneout.gct data/predicgct/realtcgacancerproject.txt result/predicgct/pred5p3p/generes &
Rscript scripts/predicgct/predict/svm20.macro.R result/predicgct/pred5p3p/ratioout.gct data/predicgct/realtcgacancerproject.txt result/predicgct/pred5p3p/ratiores &
Rscript scripts/predicgct/predict/svm20.macro.R result/predicgct/pred5p3p/5p3pout2.gct result/predicgct/pred5p3p/randomlist.txt result/predicgct/pred5p3p/randomres &

wait
