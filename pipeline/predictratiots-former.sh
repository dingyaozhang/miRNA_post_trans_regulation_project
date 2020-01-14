#!/bin/bash
#SBATCH --job-name=predict
#SBATCH --output=cache/predicgct/predictratiotsformer.txt
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10000
#SBATCH --time=10-24:00:00


if [ $1 ]
then
	inputgct=$1
fi
if [ $2 ]
then
	inputlist=$2
fi
if [ $3 ]
then
	inputgct0=$3
fi

if [ $4 ]
then
	scriptuse=$4
fi

module load R
outpath=`perl scripts/predicgct/annoprocess.pl result/predicgct/ pipeline/predictratiots-former.sh::$scriptuse::$inputlist::scripts/predicgct/predict/getgenelist-former.R::scripts/predicgct/randomsample.R::scripts/predicgct/predict/modgct.pl $inputgct::$inputlist::$inputgct0::$scriptuse::scripts/predicgct/annoprocess.pl`
randomlist=${outpath}"randomlist.txt"
outpath2=${outpath}"random"

Rscript scripts/predicgct/randomsample.R $inputlist $randomlist &
Rscript scripts/predicgct/predict/getgenelist-former.R $inputgct0 $inputlist $outpath &

wait

perl scripts/predicgct/predict/modgct.pl $outpath $inputgct0 $inputgct &

inputgct2=${outpath}'ratio.gct'
inputgct3=${outpath}'mir.gct'
inputgct4=${outpath}'gene.gct'
outpath3=${outpath}'mirna'
outpath4=${outpath}'gene'

wait

Rscript $scriptuse $inputgct2 $inputlist $outpath &
Rscript $scriptuse $inputgct4 $inputlist $outpath4 &
Rscript $scriptuse $inputgct3 $inputlist $outpath3 &
Rscript $scriptuse $inputgct2 $randomlist $outpath2 &

wait

