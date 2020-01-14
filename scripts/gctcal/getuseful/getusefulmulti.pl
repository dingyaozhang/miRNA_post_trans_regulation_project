use strict;
use warnings;

use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');

use List::Util qw/max min/;

my %ref;
open REF, "data/gctcal/exons_gene_lens.txt" or die;
while (<REF>) {
	my ($name, $len) = (split(/\t/, $_))[0,1];
	$name =~ s/\..*//g;
	
	$ref{$name} = $len;
}
	


open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;

my %hash;
my $firstline = <IN>;
$firstline =~ s/\r//g;
print OUT "$firstline";

while (<IN>) {

	$_ =~ s/\r//g;
	chomp;
	my @oneline = split(/\t/, $_);
	my $ii = 0;
	
	my $genename = $oneline[1];
	my $genelength;
	if (exists($ref{$oneline[1]})) {
		$genelength = $ref{$oneline[1]};
	}else{
		die "$oneline[1]\n";
	}
	
	my @yi;
	my @er;
	my @nozer;
	my $shouldfront;
	my $techunfair = 0;
	my $techunfair2 = 0;
	

	for my $one (@oneline) {
		next unless $one =~ m/\//;
		my ($yi, $er) =  (split(/\//, $one))[0,1];
		if ($yi == 0) {
			$techunfair += 1;
		}
		if ($er == 0) {
			$techunfair2 += 1;
		}
	}
	next if $techunfair >= 0.5*(scalar(@oneline)-2);
	next if $techunfair2 >= 0.5*(scalar(@oneline)-2);


	for my $one (@oneline) {
		$ii += 1;
		
		
		if ($ii == 1) {
			$shouldfront = "$one";
		}elsif($ii == 2){
			$shouldfront = "$shouldfront\t$one";
		}else{
			my ($yi, $er) =  (split(/\//, $one))[0,1];
			push @yi, "$yi";
			push @er, "$er";
			push @nozer, "$er" if $er != 0;
		}

			
	}

	my $nozlength = scalar @nozer;
	next if $nozlength == 0;
	print OUT "$shouldfront";
	my $minfactor = (1/3)*(min(@nozer));
	my $yii = 0;
	for my $yi (@yi) {
		my $er = $er[$yii];
		if (($yi == 0) && ($er == 0)) {
			print OUT "\t1";
		}else{
			
			my $output = $genelength * ($yi * $er);
			$output = 1.00111111111 if $output == 1;
			print OUT "\t$output";
				
		}
		$yii += 1;
	}
	print OUT "\n";
}
close IN;
close OUT;

