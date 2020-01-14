use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');



open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;

my $line1 = <IN>;
print OUT "$line1";
while (<IN>) {
	chomp;
	my @array = split(/\t/, $_);
	my $one = shift(@array);
	my $two = shift(@array);
	print OUT "$one\t$two";
	for my $var (@array) {
		if ($var eq 'NA/NA') {
			print OUT "\t$var";
		}else{
			my ($qian, $hou) = (split(/\//, $var))[0,1];
			my $thisratio = $qian / $hou;
			print OUT "\t$thisratio";
		}
	}
	print OUT "\n";
}

close OUT;
