use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o $opt_d $opt_c);
getopts('i:o:d:c:');

#perl scripts/samegene/findsamesource.pl -i result/ratio121isoexact.gct -o result/samegenelist.txt -c result/samegene.gct



open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;
my %genesource;

my $line1 = <IN>;
while (<IN>) {
	
	chomp;
	my @array = split(/\t/, $_);
	if (exists($genesource{$array[1]})) {
		$genesource{$array[1]} = "$array[0]"."\t$genesource{$array[1]}";
	}else{
		$genesource{$array[1]} = $array[0];
	}
	
}


close IN;


for my $geneone (keys(%genesource)) {
	my $stringone = $genesource{$geneone};
	my @array = split(/\t/, $stringone);
	my $num = scalar @array;
	next if $num <= 1;
	if ($num == 2) {
		my $nameone = $array[0];
		$nameone =~ s/-[0-9]p$//g;
		if (($array[1] =~ m/$nameone-[0-9]p/) && ($array[1] ne $array[0]) ) {
			for my $arrayone (@array) {
				print OUT "$arrayone\t$geneone\n";
			}
		}		
	}
	
	
}

close OUT;


open OUT, "$opt_o" or die;
open DAT, "$opt_i" or die;
open COM, '>', "$opt_c" or die;


my $first = <DAT>;
print COM "$first";

my %data;
while (<DAT>) {
	
	chomp;
	my @array = split(/\t/, $_);
	my $name = $array[0];
	$data{$name} = $_;
	
}
close DAT;

while (<OUT>) {
	
	chomp;
	my @array = split(/\t/, $_);
	my $name = $array[0];
	if (exists($data{$name})) {
		print COM "$data{$name}\n";
	}
	
	
}
close OUT;