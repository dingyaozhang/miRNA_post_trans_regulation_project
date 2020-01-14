use strict;
use warnings;

use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');

open OUT, '>', "$opt_o" or die;

my $inputfile = "/gpfs/ysm/project/jun_lu/dz287/ratio2/data/getgct/downloadsupportinfor/allfourseq/original/gdc_manifest.2019-09-03.txt";
open REF, "$inputfile" or die;

my %ref;
while (<REF>) {
	chomp;
	my ($id, $file) = (split(/\t/, $_))[0,1];
	$ref{$file} = $id;
}
close REF;


open REF, "$inputfile" or die;


while (<REF>) {
	chomp;
	my ($id, $file) = (split(/\t/, $_))[0,1];
	if ($file =~ s/\.htseq\.counts\.gz$//) {
		$file = $file.'.FPKM.txt.gz';
		print OUT "$id\t$ref{$file}\n";
	}
	

	
}
close REF;
close OUT;