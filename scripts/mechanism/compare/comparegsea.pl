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
	push @datain, $_;
	
}
close IN;


my @dataref;
while (<REF>) {

	chomp;
	push @dataref, $_;

}
close REF;


my %refhash;
my %inhash;

my $var = 1;
for my $datain (@datain) {
	$inhash{$datain} = $var / scalar @datain;
	$var += 1;
}


$var = 1;
for my $dataref (@dataref) {
	$refhash{$dataref} = $var / scalar @dataref;
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
	my $aver = ($inhash{$varr} + $refhash{$varr})/2;

	print OUT "$varr\t$diff\t$aver\t$inhash{$varr}\t$refhash{$varr}\n";
	
}


close OUT;