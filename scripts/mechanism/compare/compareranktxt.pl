use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_r $opt_o);
getopts('i:r:o:');


open IN, "$opt_i" or die;
open REF, "$opt_r" or die;
open OUT, '>', "$opt_o" or die;


my @datain;
while (<IN>) {

	chomp;
	my @array = split(/\t/, $_);
	next if $array[0] ne 'ALL';
	push @datain, [@array];
	
}
close IN;


my @dataref;
while (<REF>) {

	chomp;
	my @array = split(/\t/, $_);
	next if $array[0] ne 'ALL';
	push @dataref, [@array];

}
close REF;

@dataref = sort {$b->[2] <=> $a->[2]} @dataref;
@datain = sort {$b->[2] <=> $a->[2]} @datain;

my %refhash;
my %inhash;
my %refhash2;
my %inhash2;

my $var = 1;
for my $datain (@datain) {
	$inhash{$datain->[1]} = $var / scalar @datain;
	$inhash2{$datain->[1]} = $datain->[2];
	$var += 1;
}


$var = 1;
for my $dataref (@dataref) {
	$refhash{$dataref->[1]} = $var / scalar @dataref;
	$refhash2{$dataref->[1]} = $dataref->[2];
	$var += 1;
}

my @genestudy;
my %genestudy;

for my $varr (keys(%inhash)) {
	$genestudy{$varr} += 1;
}

for my $varr (keys(%refhash)) {
	$genestudy{$varr} += 1;
}

for my $varr (keys(%genestudy)) {
	push @genestudy, $varr if $genestudy{$varr} == 2;
}

@genestudy = sort {$a cmp $b} @genestudy;


for my $varr (@genestudy) {
	my $diff = abs($inhash{$varr} - $refhash{$varr});
	my $aver = ($inhash2{$varr} + $refhash2{$varr})/2;

	print OUT "$varr\t$diff\t$aver\t$inhash{$varr}\t$inhash2{$varr}\t$refhash{$varr}\t$refhash2{$varr}\n";

}


close OUT;