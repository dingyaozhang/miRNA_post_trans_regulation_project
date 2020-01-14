#!/bin/bash
#SBATCH --job-name=hairpinana
#SBATCH --output=cache/mechanism/hairpinana.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --mem=40000


module load R



funuse53(){
    local programuse=$1
    local ratio121gct=$2
    local projectlist=$3
    local output=$4
    Rscript $programuse $ratio121gct $projectlist $output
    perl scripts/mechanism/overallcor/overallfiguredata.pl -i $output
}


funuse53 scripts/mechanism/hairpin/p5p3inpostaddmin.R result/gctcal/5p3p/filtered885p3p1212exact.gct data/predicgct/realtcgacancerproject.txt result/mechanism/hairpin/coraddmin88/corexacttcgacancer &
funuse53 scripts/mechanism/hairpin/p5p3inpostaddmin.R result/gctcal/5p3p/filtered885p3p1212fpkm.gct data/predicgct/realtcgacancerproject.txt result/mechanism/hairpin/coraddmin88/corfpkmtcgacancer &
funuse53 scripts/mechanism/hairpin/p5p3inpostaddmin.R result/gctcal/5p3p/filtered885p3p1212exact.gct data/predicgct/realtcganormalproject2kidneyto1.txt result/mechanism/hairpin/coraddmin88/corexacttcganor &
funuse53 scripts/mechanism/hairpin/p5p3inpostaddmin.R result/gctcal/5p3p/filtered885p3p1212fpkm.gct data/predicgct/realtcganormalproject2kidneyto1.txt result/mechanism/hairpin/coraddmin88/corfpkmtcganor &
funuse53 scripts/mechanism/hairpin/p5p3inpostaddmin.R result/gctcal/5p3p/filtered885p3p1212exact.gct data/predicgct/realtargetcancerproject.txt result/mechanism/hairpin/coraddmin88/corexacttarget &
funuse53 scripts/mechanism/hairpin/p5p3inpostaddmin.R result/gctcal/5p3p/filtered885p3p1212fpkm.gct data/predicgct/realtargetcancerproject.txt result/mechanism/hairpin/coraddmin88/corfpkmtarget &
