#!/bin/bash
#SBATCH --job-name=getratio
#SBATCH --output=cache/gctcal/getratio.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

perl scripts/gctcal/getuseful/getusefulratio3.pl -i result/gctcal/ratio121isoexact.gct -o result/gctcal/ratioisoexact.great.gct
perl scripts/gctcal/getuseful/getusefulratio3.pl -i result/gctcal/ratio121isofpkm.gct -o result/gctcal/ratioisofpkm.great.gct -p

wait

