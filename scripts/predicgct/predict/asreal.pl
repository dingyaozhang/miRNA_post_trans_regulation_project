use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_r $opt_o);
getopts('i:o:r:');


open REF, "$opt_r" or die;
open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;


my %ref;

while (<REF>) {
	chomp;
	my ($this, $type) = (split(/\t/, $_))[0,1];
	$ref{$this} = $type;
}

while (<IN>) {
	chomp;
	my $this = (split(/\t/, $_))[0];
	if ($this =~ m/([^-]+-[^-]+-[^-]+)-[^-]+/) {
		if (exists($ref{$1})) {
			print OUT "$this\t$ref{$1}\n";
		}
	}else{
		die "wrong format $this\n";
	}

}

close OUT;
close IN;
close REF;