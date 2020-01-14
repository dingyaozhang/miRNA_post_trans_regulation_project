use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');

my $filelist = `find $opt_i -maxdepth 1`;
my @filelist = split(/\n/, $filelist);


open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;


my %hash;
my $line1 = <IN>;
my $thisname;
my $thisvar;

while (<IN>) {

	chomp;
	if ($_ =~ m/^ENSG*/) {
		my @array = split(/\t/, $_);
		$thisname = $array[0];
		$thisvar = $array[3];
	}elsif ($_ =~ m/^hsa-*/) {
		my @array = split(/\t/, $_);
		my $exceed;
		if ($array[3] <= $thisvar) {
			$exceed = 0;
		}else{
			$exceed = 1;
		}
		if (exists($hash{$thisname})) {
			$hash{$thisname} = $hash{$thisname}."\t$exceed";
		}else{
			$hash{$thisname} = $exceed;
		}
		print OUT "$thisname\t$array[0]\t$exceed\n"
	}
	
	

}


for my $var (keys(%hash)) {
	my @array = split(/\t/, $hash{$var});
	my $yi = 0;
	for my $one (@array) {
		$yi += 1 if $one == 1;
	}
	my $ratio = $yi / (scalar @array) ;
	print OUTT "$var\t$ratio\n"
}