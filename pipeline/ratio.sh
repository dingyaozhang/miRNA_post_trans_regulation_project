#!/bin/bash
#SBATCH --job-name=ratio_job
#SBATCH --output=cache/gctcal/ratio_job.txt
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=10000
#SBATCH --cpus-per-task=2
#SBATCH --time=1-24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=guagua19967@gmail.com


perl scripts/gctcal/ratio121.pl -m result/gctcal/adjustedformalnameisoform.gct -g result/gctcal/adjustcountonlygene.gct -l cache/gctcal/overlap.txt -o result/gctcal/ratio121isoexact.gct -c cache/gctcal/gdcsamplefour.txt
  
perl scripts/gctcal/ratio121.pl -m result/gctcal/mirisofpkmformalname.gct -g result/getgct/fpkmonlygene.gct -l cache/gctcal/overlap.txt -o result/gctcal/ratio121isofpkm.gct -c cache/gctcal/gdcsamplefour.txt


perl scripts/gctcal/align2gct.pl -m cache/gctcal/ccle.mir.false.gct -g cache/gctcal/ccle_valueadjusted_counts.gct -o result/gctcal/ccle_adjusted_mir.gct -t result/gctcal/ccle_adjusted_counts.gct
perl scripts/gctcal/ccletransform.pl -i result/gctcal/ccle_adjusted_mir.gct -o cache/gctcal/ccleoverlap.txt -t result/gctcal/ccle_adjustedname_mir.gct
perl scripts/gctcal/twogct21ratio121.pl -m result/gctcal/ccle_adjustedname_mir.gct -g result/gctcal/ccle_adjusted_counts.gct -l cache/gctcal/overlap.txt -o result/gctcal/ratio121ccle.gct
sed -i '1 s/Description\tName/Name\tDescription/' result/gctcal/ratio121ccle.gct
