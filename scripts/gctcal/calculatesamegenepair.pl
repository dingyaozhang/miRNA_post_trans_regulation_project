use strict;
use warnings;

use List::Util qw(max min sum);

use Getopt::Std;
use vars qw($opt_i $opt_o $opt_s);
getopts('i:o:s:');

my $filelist = `find $opt_i -maxdepth 1`;
my @filelist = split(/\n/, $filelist);


open IN, "$opt_i" or die;
#open OUT, '>', "$opt_o" or die;
#open OUTT, '>', "$opt_s" or die;

my %hash;
my $line1 = <IN>;
my $good = 0;
my $bad = 0;

while (<IN>) {

	chomp;
	my @array = split(/\t/, $_);
	my $mincor = max($array[3], $array[4]);
	if ($mincor > $array[5]) {
		$good += 1;
	}else{
		$bad += 1;
	}
	

}

print "$good\t$bad\n";
