use strict;
use warnings;

use List::Util qw(max min sum);

use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');


open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;

my %pair2cor;
my %gene2pairs;
my %gene2mirs;
my %mir2cor;

my $line1 = <IN>;
while (<IN>) {

	chomp;
	my @array = split(/\t/, $_);
	my $genename = $array[0];
	my $mir1 = $array[1];
	my $mir2 = $array[2];
	my @mirs = ($mir1, $mir2);
	@mirs = sort @mirs;
	my $mirs = join("-", @mirs);
	
	unless (exists($pair2cor{$mirs})) {
		$pair2cor{$mirs} = $array[5];
		if (exists($gene2pairs{$genename})) {
			$gene2pairs{$genename} = $gene2pairs{$genename}."\t$mirs";
		}else{
			$gene2pairs{$genename} = "$mirs";
		}
	}

	unless (exists($mir2cor{$mir1})) {
		$mir2cor{$mir1} = $array[3];
		if (exists($gene2mirs{$genename})) {
			$gene2mirs{$genename} = $gene2mirs{$genename}."\t$mir1";
		}else{
			$gene2mirs{$genename} = "$mir1";
		}
	}
	unless (exists($mir2cor{$mir2})) {
		$mir2cor{$mir2} = $array[4];
		if (exists($gene2mirs{$genename})) {
			$gene2mirs{$genename} = $gene2mirs{$genename}."\t$mir2";
		}else{
			$gene2mirs{$genename} = "$mir2";
		}
	}
	
}
close IN;


foreach my $onekey (keys(%gene2pairs)) {


	my @array = split(/\t/, $gene2pairs{$onekey});

	my @allcors;
	foreach my $arrayone (@array) {
		push @allcors, $pair2cor{$arrayone};
	}
	my $avercors = &sum(@allcors);
	$avercors = $avercors / scalar @allcors;
	my $maxcors = &max(@allcors);
	my $mincors = &min(@allcors);



	my @mirnas = split(/\t/, $gene2mirs{$onekey});
	my @allcors2;
	foreach my $mirnaone (@mirnas) {
		push @allcors2, $mir2cor{$mirnaone};
		#print "";
	}
	my $avercors2 = &sum(@allcors2);
	$avercors2 = $avercors2 / scalar @allcors2;
	my $maxcors2 = &max(@allcors2);
	my $mincors2 = &min(@allcors2);

	print OUT "$onekey\t$mincors\t$avercors\t$maxcors\t$mincors2\t$avercors2\t$maxcors2\n"
}