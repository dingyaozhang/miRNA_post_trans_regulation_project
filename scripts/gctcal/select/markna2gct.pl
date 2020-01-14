use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o $opt_r);
getopts('i:o:r:');


my %ref;
my @meaning;
my $namei = 0;
open REF, "$opt_r" or die;
while (<REF>) {
	chomp;
	my ($mir, $sample) = (split(/\t/, $_))[0,1];
	unless (exists($ref{$mir})) {
		$ref{$mir} = $namei;
		$namei += 1;
	}
	unless (exists($ref{$sample})) {
		$ref{$sample} = $namei;
		$namei += 1;
	}
	$meaning[$ref{$mir}][$ref{$sample}] = 1;
}
close REF;


open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;



my $line1 = <IN>;
print OUT "$line1";
chomp($line1);
my @line1 = split(/\t/, $line1);

while (<IN>) {
	chomp;
	my @array = split(/\t/, $_);
	my $mirname = shift(@array);
	my $genename = shift(@array);
	unless (exists($ref{$mirname})) {
		next
	}
	print OUT "$mirname\t$genename";
	my $thisi = 1;
	for my $var (@array) {
		$thisi += 1;
		my $samplename = $line1[$thisi];
		if (exists($ref{$samplename})) {
			if (exists($meaning[$ref{$mirname}][$ref{$samplename}])) {
				print OUT "\t$var";
			}else{
				print OUT "\tNA/NA";
			}
		}else{
			die "different sample $samplename\n";
			print OUT "\tNA/NA";
		}
		
		
	}
	print OUT "\n";

}


close IN;
close OUT;

