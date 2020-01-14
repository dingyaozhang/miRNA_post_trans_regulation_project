#!/bin/bash
#SBATCH --job-name=p1
#SBATCH --output=cache/mechanism/overallcorrelation3.txt
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --time=2-24:00:00


module load R



funuse(){
    local programuse=$1
    local ratio121gct=$2
    local projectlist=$3
    local output=$4
    Rscript $programuse $ratio121gct $projectlist $output 
    perl scripts/mechanism/overallcor/overallfiguredata.pl -i $output/
    perl scripts/mechanism/overallcor/kindsfigure.pl -i $output/ -o $output/kindsfigure.txt 
}

funuse53(){
    local programuse=$1
    local ratio121gct=$2
    local projectlist=$3
    local output=$4
    Rscript $programuse $ratio121gct $projectlist $output
    perl scripts/mechanism/overallcor/overallfiguredata.pl -i $output
}


thisprog='scripts/mechanism/overallcor/mirhostratiocoraddmin.R'
fpkmgct='result/gctcal/filtered88121ratiofpkm.gct'
exactgct='result/gctcal/filtered88121ratioadjust.gct'
normallist='data/predicgct/realtcganormalproject2kidneyto1.txt'
targetlist='data/predicgct/realtargetcancerproject.txt'
tcgalist='data/predicgct/realtcgacancerproject.txt'
funuse $thisprog $exactgct $tcgalist  result/mechanism/overallcor/addmin88/tcgacor &
funuse $thisprog $fpkmgct $tcgalist  result/mechanism/overallcor/addmin88/tcgafpkmcor &
funuse $thisprog $exactgct $targetlist  result/mechanism/overallcor/addmin88/targetcor &
funuse $thisprog $fpkmgct $targetlist  result/mechanism/overallcor/addmin88/targetfpkmcor &
funuse $thisprog $exactgct $normallist  result/mechanism/overallcor/addmin88/tcganor &
funuse $thisprog $fpkmgct $normallist  result/mechanism/overallcor/addmin88/tcganorfpkm &
 

thisprog='scripts/mechanism/overallcor/mirhostratiocorccle.R'
thegct='result/gctcal/ratio121ccle.gct'
thelist='cache/gctcal/cclerealproject.txt'
funuse $thisprog $thegct $thelist result/mechanism/overallcor/ccle/ &
wait
 

