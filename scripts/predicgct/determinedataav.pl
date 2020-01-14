use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_r);
getopts('i:r:');


open REF, "$opt_r" or die;
my $line1 = <REF>;
my @line1 = split(/\t/, $line1);
shift(@line1);
shift(@line1);
my %line1;
for my $var (@line1) {
	$line1{$var} = 1;
}
close REF;

my %hash;

open IN, "$opt_i" or die;
while (<IN>) {
	chomp;
	my @array = split(/\t/, $_);
	next unless exists($line1{$array[0]});
	$hash{$array[1]} += 1;
}
close REF;

my @keyssorted = sort {$a cmp $b} keys(%hash);
for my $var (@keyssorted) {
	print "$var\t$hash{$var}\n";
}
