use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_f $opt_o);
getopts('i:o:f:');

use List::Util qw(max min sum);

$opt_f =~ s/\/$//;
$opt_o =~ s/\/$//;

my %mir;
my %selectrows;
open REF, "$opt_f/genelist.txt" or die;
while (<REF>) {	
	chomp;
	my $premir = $_;
	$premir =~ s/-[35]p$//;
	$mir{$premir} = $_;
}
close REF;


open OUT, '>', "$opt_o/5p3pout.gct" or die;
open IN, "$opt_i" or die;

while (<IN>) {
	chomp;
	if ($. == 1) {
		print OUT "$_\n";
	}else{
		my @array = split(/\t/, $_);
		my $name1 = shift(@array);
		my $name2 = shift(@array);
		next unless exists($mir{$name1});
		$selectrows{$mir{$name1}} = 1;
		my @wupu0;
		my @sanpu0;
		print OUT "$name1\t$name2";
		for my $var (@array) {
			my ($wup, $sanp) = (split(/\//, $var))[0,1];
			push @wupu0, $wup if $wup != 0;
			push @sanpu0, $sanp if $sanp != 0;
		}
		my $minwu = min(@wupu0);
		my $minsan = min(@sanpu0);

		for my $var (@array) {
			my ($wup, $sanp) = (split(/\//, $var))[0,1];
			my $out = ($wup + 1/3*$minwu) / ($sanp + 1/3*$minsan);
			print OUT "\t$out";
		}
		print OUT "\n";
	}
	
}


close IN;
close OUT;


open MIR, "$opt_f/mir.gct" or die;
open GENE, "$opt_f/gene.gct" or die;
open OUT, '>', "$opt_o/mirout.gct" or die;
open OUTT, '>', "$opt_o/geneout.gct" or die;


while (<MIR>) {
	chomp;
	my $geneout = <GENE>;
	if ($. == 1) {
		print OUT "$_\n";
		print OUTT "$geneout";
	}else{
		my $name = (split(/\t/, $_))[0];
		if (exists($selectrows{$name})) {
			print OUT "$_\n";
			print OUTT "$geneout";
		}
	}
}

close MIR;
close GENE;
close OUT;
close OUTT;

open RATIO, "$opt_f/ratio.gct" or die;
open OUTTT, '>', "$opt_o/ratioout.gct" or die;
while (<RATIO>) {
	chomp;
	if ($. == 1) {
		print OUTTT "$_\n";
	}else{
		my $name = (split(/\t/, $_))[0];
		if (exists($selectrows{$name})) {
			print OUTTT "$_\n";
		}
	}
}

close RATIO;
close OUTT;
