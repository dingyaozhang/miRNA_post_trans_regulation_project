use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');


open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;


my $genethrehold = 8;
my $mirthrehold = 8;


my %ref;
my %geneuse;

my $line1 = <IN>;
chomp($line1);
my @line1 = split(/\t/, $line1);

while (<IN>) {
	chomp;
	my @array = split(/\t/, $_);
	my $mirname = shift(@array);
	my $genename = shift(@array);

	my $thisi = 1;
	for my $var (@array) {
		$thisi += 1;
		next if $thisi == 1;
		my ($mirnum, $genenum) = (split(/\//, $var))[0,1];

		if (($mirnum >= $mirthrehold) && ($genenum >= $genethrehold)) {
			print OUT "$mirname\t$line1[$thisi]\n";
		}
		
	}
	

}


close IN;
close OUT;

