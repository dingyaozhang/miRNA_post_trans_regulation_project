use strict;
use warnings;
use Math::BigInt;

open IN, "result/gctcal/ratio121isoexact.gct" or die;
open OUT, '>', "result/mechanism/evolution/genewhichiswide.gct" or die;

my $firstline = <IN>;


LINE: while (<IN>) {

	chomp;
	my $zeronum = 0;
	my $sum = 0;
	my $sumvar = 0;
	my @array = split(/\t/, $_);
	my $mirone = shift(@array);
	my $geneone = shift(@array);
	#print "$mirone\t$geneone\n";
	
	
	for my $var (@array) {
		my $genevalue = (split(/\//, $var))[1];
		if ($genevalue == 0) {
			$zeronum += 1;
		}
		$sum = $sum + $genevalue;
	}
	next if $sum == 0;
	my $aver = $sum / scalar(@array);
	
	for my $var (@array) {
		my $genevalue = (split(/\//, $var))[1];
		$sumvar = $sumvar + (($genevalue-$aver)/$aver)**2;
	}
	
	my $variation = ($sumvar)**(1/2);
	#print "$sumvar\t$variation\n";
	my $cv = $variation/$aver;
	print OUT "$mirone\t$geneone\t$cv\t$zeronum\n";

}

