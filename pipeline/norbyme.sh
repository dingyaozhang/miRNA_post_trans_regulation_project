#!/bin/bash
#SBATCH --job-name=normal
#SBATCH --output=cache/gctcal/norbyme.txt
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=80000
#SBATCH --cpus-per-task=1
#SBATCH --time=5-24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=guagua19967@gmail.com


if [[ $1 == "normalmode" ]]
then   
    perl scripts/norbyme/norbyme.pl
elif [[ $1 == "factormode" ]]
then   
	perl scripts/norbyme/noradjustfactor.pl -i $2
elif [[ $1 == "new" ]]
then   
	perl scripts/gctcal/noragctbyme.pl -i $2 -o $3
else
	perl scripts/gctcal/noragctbyme.pl -i result/getgct/mircount.gct -o cache/gctcal/adjustmircount.gct
	perl scripts/gctcal/noragctbyme.pl -i result/getgct/countonlygene.gct -o result/gctcal/adjustcountonlygene.gct
	perl scripts/gctcal/miisochangename-opt.pl -i cache/gctcal/adjustmircount.gct -r cache/gctcal/isoaccestoname.txt -o result/gctcal/adjustedformalnameisoform.gct
	rm cache/gctcal/temptranscache.txt
	
fi