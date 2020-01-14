#!/bin/bash
#SBATCH --job-name=getgct
#SBATCH --output=cache/getgct/getgct.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=6:00:00
#SBATCH --mem=80000


### finish job to get count data
perl scripts/getgct/getgctnew.pl -p result/getgct/allfourdownload/ -r data/getgct/downloadsupportinfor/countall/gdc_all_counts.txt -o cache/getgct/gene-t.gct
perl scripts/getgct/transgct-gene.pl -i cache/getgct/gene-t.gct -r data/getgct/downloadsupportinfor/countall/gdc_sample_sheet_count_all.tsv -o result/getgct/countonlygene.gct
rm cache/getgct/gene-t.gct

### finish job to get fpkm data
perl scripts/getgct/getgctnew.pl -p result/getgct/allfourdownload/ -r data/getgct/downloadsupportinfor/fpkm/gdc_manifest_fpkmall.txt -o cache/getgct/fpkm-t.gct
perl scripts/getgct/transgct-gene.pl -i cache/getgct/fpkm-t.gct -r data/getgct/downloadsupportinfor/fpkm/gdc_sample_sheet_fpkmall.tsv -o result/getgct/fpkmonlygene.gct
rm cache/getgct/fpkm-t.gct


### build cache folds and files for miRNA data
perl scripts/getgct/getoutisoformnew.pl -p result/getgct/allfourdownload/ -r data/getgct/downloadsupportinfor/mirall/gdc_all_mirs.txt -o cache/getgct/getoutisoformnew


### finish job to get MIRNA FPKM data
perl scripts/getgct/getgctnew.pl -p cache/getgct/getoutisoformnew/fpkm/ -r data/getgct/downloadsupportinfor/mirall/gdc_all_mirs.txt -o cache/getgct/mirfpkm-t.gct
perl scripts/getgct/transgct-mir.pl -i cache/getgct/mirfpkm-t.gct -r data/getgct/downloadsupportinfor/mirall/gdc_sample_mir_all.txt -o result/getgct/mirfpkm.gct
rm cache/getgct/mirfpkm-t.gct


### finish job to get MIRNA count data
perl scripts/getgct/getgctnew.pl -p cache/getgct/getoutisoformnew/count/ -r data/getgct/downloadsupportinfor/mirall/gdc_all_mirs.txt -o cache/getgct/mircount-t.gct
perl scripts/getgct/transgct-mir.pl -i cache/getgct/mircount-t.gct -r data/getgct/downloadsupportinfor/mirall/gdc_sample_mir_all.txt -o result/getgct/mircount.gct
rm cache/getgct/mircount-t.gct
