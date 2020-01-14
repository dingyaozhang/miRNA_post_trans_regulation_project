#!/bin/bash
#SBATCH --job-name=getlistformodule
#SBATCH --output=cache/mechanism/getlistformodule.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10000
#SBATCH --time=1-24:00:00

#I used these commands to get gct files for module analysis (I put these files in result/mechanism/modulecluster/gct)


funct () {
	local inputone=$1
	local inputtwo=$2
	local geneprojectlist=$3
	local outname1=$4
	local outname2=$5
	Rscript scripts/mechanism/modulecluster/getlistformodule.R $inputone $geneprojectlist $outname1 $inputone $geneprojectlist $outname2
	perl scripts/predicgct/predict/modgct.pl $outname1 $inputone $inputtwo
	perl scripts/predicgct/predict/modgct.pl $outname2 $inputone $inputtwo
}


funct result/gctcal/ratio121isoexact.gct result/gctcal/ratioisoexact.great.gct data/predicgct/realtcgacancerproject.txt result/mechanism/modulecluster/gct/strictexactcancer result/mechanism/modulecluster/gct/moreexactcancer &
funct result/gctcal/ratio121isofpkm.gct result/gctcal/ratioisofpkm.great.gct data/predicgct/realtcgacancerproject.txt result/mechanism/modulecluster/gct/strictfpkmcancer result/mechanism/modulecluster/gct/morefpkmcancer &
funct result/gctcal/ratio121isoexact.gct result/gctcal/ratioisoexact.great.gct data/predicgct/realtcganormalproject.txt result/mechanism/modulecluster/gct/strictexactnormal result/mechanism/modulecluster/gct/moreexactnormal &
funct result/gctcal/ratio121isofpkm.gct result/gctcal/ratioisofpkm.great.gct data/predicgct/realtcganormalproject.txt result/mechanism/modulecluster/gct/strictfpkmnormal result/mechanism/modulecluster/gct/morefpkmnormal &

wait