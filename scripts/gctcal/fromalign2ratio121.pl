use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_g $opt_m $opt_o $opt_l);
getopts('g:m:o:l:');


open OUT, '>', "$opt_o" or die;

my %ref;
my %geneuse;
open REF, "$opt_l" or die;
while (<REF>) {
	chomp;
	my ($mirname, $genename) = (split(/\t/, $_))[0,1];
	if (exists($ref{$mirname})) {
		$ref{$mirname} .= "\t$genename";
	}else{
		$ref{$mirname} = "$genename";
	}
	$geneuse{$genename} = 1;
}
close REF;


my %gene;
open GENE, "$opt_g" or die;

while (<GENE>) {

	chomp;
	my $genename = (split(/\t/, $_))[0];
	next unless exists($geneuse{$genename});
	$gene{$genename} = $_;


}
close GENE;


my %mir;
open MIR, "$opt_m" or die;
while (<MIR>) {


	chomp;
	my $mirname = (split(/\t/, $_))[0];
	next unless exists($ref{$mirname});
	my @genenames = split(/\t/, $ref{$mirname});
	for my $var (@genenames) {
		print "nothisgene $var\n" unless exists($gene{$var});
		my @arraymir = split(/\t/, $_);
		my @arraygene = split(/\t/, $gene{$var});
		shift(@arraymir);
		shift(@arraymir);
		shift(@arraygene);
		shift(@arraygene);
		print OUT "$mirname\t$var";
		for my $var2 (@arraymir) {
			my $thisgene = shift(@arraygene);
			print OUT "\t$var2/$thisgene";
		}
		print OUT "\n";
	}

}

close MIR;
close OUT;


