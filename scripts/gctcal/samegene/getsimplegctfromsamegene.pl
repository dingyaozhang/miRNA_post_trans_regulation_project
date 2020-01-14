use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');


open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;

my %gct;
my %gene2mirs;

my $line1 = <IN>;
chomp($line1);
my $length1row = scalar (split(/\t/, $line1));


while (<IN>) {

	chomp;
	
	my @array = split(/\t/, $_);
	my $mirname = shift(@array);
	my $genename = shift(@array);
	my @array1;
	my @array2;
	for my $var (@array) {
		my ($one, $two) = split(/\//, $var);
		push @array1, "$one";
		push @array2, "$two";
	}
	$gct{$mirname} = join("\t", @array1);
	
	
	if (exists($gene2mirs{$genename})) {
			$gene2mirs{$genename} = $gene2mirs{$genename}."\t$mirname";
	}else{
			$gene2mirs{$genename} = "$mirname";
	}
	unless (exists($gct{$genename})) {
		$gct{$genename} = join("\t", @array2);
	}
	
	
}
close IN;


foreach my $onekey (keys(%gene2mirs)) {
	my @array = split(/\t/, $gene2mirs{$onekey});
	print OUT "$onekey\t$onekey\t$gct{$onekey}\n";
	foreach my $arrayone (@array) {
		print OUT "$arrayone\t$onekey\t$gct{$arrayone}\n";
	}
	

	
}