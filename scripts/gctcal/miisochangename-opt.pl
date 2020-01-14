use strict;
use warnings;

use Getopt::Std;
use vars qw($opt_i $opt_o $opt_r);
getopts('i:o:r:');

open MIR, "$opt_r" or die;
open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;

our %mir;

while (<MIR>) {
	chomp;
	my ($mirnaacces, $mirnaname) = (split(/\t/, $_))[0,1];
	$mir{$mirnaacces} = $mirnaname;
}

close MIR;

print "line1 is jumped and print out directly\n";
my $firline = <IN>;
print OUT "$firline";



while (<IN>) {

	chomp;
	if ($_ =~ m/^([^\t]+)(\t.*)$/) {
		if (exists($mir{$1})) {
			print OUT "$mir{$1}$2\n";
		}else{
			print "different miRNA $1\n";
		}
		
	}
	

}
close OUT;
close IN;
