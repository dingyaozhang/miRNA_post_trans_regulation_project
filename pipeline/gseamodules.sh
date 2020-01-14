#!/bin/bash
#SBATCH --job-name=gsea
#SBATCH --output=cache/gsea.txt
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=40G

module load R


corpath=$1
corprogram=$2
workpath=$3
geneset=$4
moduleresfile=$5

workpath=`echo $workpath | sed "s/\/$//"`"/"
moduleresfile=`echo $moduleresfile | sed "s/\/$//"`"/"

rnklist=`perl $corprogram -i $corpath -l $workpath -o $workpath`
echo $corpath::$corprogram::$workpath::$geneset::$moduleresfile > $workpath"anno.txt"

rnklist=($rnklist)
for varr in ${rnklist[@]}
do
	rnkfile=$workpath$varr
	if [ ! -d $rnkfile'host/' ]; then 
		mkdir $rnkfile'host/'
	fi
	if [ ! -d $rnkfile'ratio/' ]; then 
		mkdir $rnkfile'ratio/'
	fi
	Rscript scripts/mechanism/modulecluster/getrnk.R $rnkfile'host.txt' $rnkfile'host.rnk'
	Rscript scripts/mechanism/modulecluster/getrnk.R $rnkfile'ratio.txt' $rnkfile'ratio.rnk'
	java -cp data/mechanism/gsea/gsea-3.0.jar -Xmx24500m xtools.gsea.GseaPreranked -rnk $rnkfile'host.rnk'  -norm meandiv -nperm 1000 -scoring_scheme weighted -rpt_label my_analysis -create_svgs false -make_sets true -plot_top_x 20 -rnd_seed timestamp -set_max 500 -set_min 15 -zip_report false -out $rnkfile'host/' -gmx $geneset
	java -cp data/mechanism/gsea/gsea-3.0.jar -Xmx24500m xtools.gsea.GseaPreranked -rnk $rnkfile'ratio.rnk'  -norm meandiv -nperm 1000 -scoring_scheme weighted -rpt_label my_analysis -create_svgs false -make_sets true -plot_top_x 20 -rnd_seed timestamp -set_max 500 -set_min 15 -zip_report false -out $rnkfile'ratio/' -gmx $geneset
	#rm $rnkfile'host.txt'
	#rm $rnkfile'host.rnk'
	#rm $rnkfile'ratio.txt'
	#rm $rnkfile'ratio.rnk'
done

clutxts=`find $workpath -maxdepth 1 -type f -regex '.+/clu[0-9]+\.txt'`
clutxts=($clutxts)

if [ ! -d $moduleresfile'ecdf/' ]; then 
	mkdir $moduleresfile'ecdf/'
fi
Rscript scripts/mechanism/modulecluster/modulesignchange.R allmir $moduleresfile'figure/' $moduleresfile'ecdf/allclu'  $moduleresfile'ecdfallclu.txt'

for varr in ${clutxts[@]}
do
	cluname=`basename $varr`
	Rscript scripts/mechanism/modulecluster/modulesignchange.R $varr $moduleresfile'figure/' $moduleresfile'ecdf/'$cluname $moduleresfile'ecdf'$cluname
done
