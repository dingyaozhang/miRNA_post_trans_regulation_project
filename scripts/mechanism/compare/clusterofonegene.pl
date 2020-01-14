use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_g $opt_o);
getopts('i:g:o:');


open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;


my @datause;
while (<IN>) {

	chomp;
	next if $_ !~ m/^ALL/;
	my ($tissue, $mir, $gene, $value) = (split(/\t/, $_))[0,1,2,3];
	
	next if $opt_g ne $gene;
	push @datause, "$tissue\t$mir\t$value";
	
}
close IN;


#@datause = sort {$b->[1] <=> $a->[1]} @datause;

for my $var (@datause) {
	print OUT "$var\n";
}

close OUT;