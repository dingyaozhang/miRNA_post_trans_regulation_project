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
		die "double name $genename\n";
	}else{
		$ref{$mirname} = "$genename";
	}
	$geneuse{$genename} = 1;
}
close REF;


my %gene;
open GENE, "$opt_g" or die;
my $line1 = <GENE>;
while (<GENE>) {

	chomp;
	my $genename = (split(/\t/, $_))[0];
	next unless exists($geneuse{$genename});
	$gene{$genename} = $_;


}
close GENE;


my %mir;
open MIR, "$opt_m" or die;
my $line2 = <MIR>;
if ($line1 ne $line2) {
	die "wrong 1st line\n";
}else{
	print OUT "$line1";
}

while (<MIR>) {

	chomp;
	my $mirname = (split(/\t/, $_))[0];
	next unless exists($ref{$mirname});
	my $genename = $ref{$mirname};
	print "nothisgene $mirname $genename\n" unless exists($gene{$genename});
	next unless exists($gene{$genename});
	my @arraymir = split(/\t/, $_);
	my @arraygene = split(/\t/, $gene{$genename});
	shift(@arraymir);
	shift(@arraymir);
	shift(@arraygene);
	shift(@arraygene);
	print OUT "$mirname\t$genename";
	for my $var2 (@arraymir) {
		my $thisgene = shift(@arraygene);
		print OUT "\t$var2/$thisgene";
	}
	print OUT "\n";
	

}

close MIR;
close OUT;


