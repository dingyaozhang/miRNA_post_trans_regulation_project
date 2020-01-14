use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');


open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;

open OUTT, '>', "$opt_o.m" or die;
open OUTTT, '>', "$opt_o.g" or die;
my $genethrehold = 16;
my $mirthrehold = 16;


my %ref;
my %geneuse;


print OUT "mirname\tgenename";
print OUTT "mirname\tgenename";
print OUTTT "mirname\tgenename";
for (my $var1 = 1; $var1 <= 20; $var1++) {
	for (my $var2 = 1; $var2 <= 20; $var2++) {
		my $var1q = $var1*20;
		my $var2q = $var2*20;
		print OUT "\t$var1q-$var2q";
		print OUTT "\t$var1q-$var2q";
		print OUTTT "\t$var1q-$var2q";
	}
}
print OUT "\n";
print OUTT "\n";
print OUTTT "\n";

my $nouse = <IN>;

while (<IN>) {
	chomp;
	my @array = split(/\t/, $_);
	my $mirname = shift(@array);
	my $genename = shift(@array);
	my $totallength = scalar @array;
	print OUT "$mirname\t$genename";
	print OUTT "$mirname\t$genename";
	print OUTTT "$mirname\t$genename";
	my $mirtotal = 0;
	my $genetotal = 0;
	for my $var (@array) {
		my ($mirnum, $genenum) = (split(/\//, $var))[0,1];
		$mirtotal += 1 if $mirnum >= $mirthrehold;
		$genetotal += 1 if $genenum >= $genethrehold;
	}
	for (my $var1 = 1; $var1 <= 20; $var1++) {
		for (my $var2 = 1; $var2 <= 20; $var2++) {
			my $var1q = $var1*20;
			my $var2q = $var2*20;
			if ( ($mirtotal >= $var1q) && ($genetotal >= $var2q) ) {
				print OUT "\t1";
			}else{
				print OUT "\t0";
			}
			if ($mirtotal >= $var1q)   {
				print OUTT "\t1";
			}else{
				print OUTT "\t0";
			}
			if ($genetotal >= $var2q)  {
				print OUTTT "\t1";
			}else{
				print OUTTT "\t0";
			}
		}
	}
	print OUT "\n";
	print OUTT "\n";
	print OUTTT "\n";
}


close IN;
close OUT;
close OUTT;
close OUTTT;
