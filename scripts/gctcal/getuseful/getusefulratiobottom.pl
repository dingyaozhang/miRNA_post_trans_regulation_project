use strict;
use warnings;

use Getopt::Std;
use vars qw($opt_i $opt_l $opt_o $opt_p);
getopts('i:l:o:p');

use List::Util qw/max min sum/;

my %ref;
open REF, "data/gctcal/exons_gene_lens.txt" or die;
while (<REF>) {
	my ($name, $len) = (split(/\t/, $_))[0,1];
	$name =~ s/\..*//g;
	
	$ref{$name} = $len;
}
	


open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;

my %hash;
my $firstline = <IN>;
$firstline =~ s/\r//g;
print OUT "$firstline";

while (<IN>) {

	$_ =~ s/\r//g;
	chomp;
	my @oneline = split(/\t/, $_);
	my $ii = 0;
	
	my $genename = $oneline[1];
	my $genelength;
	if (exists($ref{$oneline[1]})) {
		if ($opt_p) {
			$genelength = 1;
		}else{
			$genelength = $ref{$oneline[1]};
		}
	}else{
		die "$oneline[1]\n";
	}
	
	my @yi;
	my @er;
	my @nozer;
	my @nozyi;
	my $shouldfront;
	

	for my $one (@oneline) {
		$ii += 1;
		
		
		if ($ii == 1) {
			$shouldfront = "$one";
		}elsif($ii == 2){
			$shouldfront = "$shouldfront\t$one";
		}else{
			my ($yi, $er) =  (split(/\//, $one))[0,1];
			push @yi, "$yi";
			push @er, "$er";
			push @nozer, "$er" if $er != 0;
			push @nozyi, "$yi" if $yi != 0;
		}
			
	}

	my $nozerlength = scalar @nozer;
	my $nozyilength = scalar @nozyi;
	next if (($nozerlength <= 4)|| ($nozyilength <= 4));

	print OUT "$shouldfront";
	@nozer = sort {$a <=> $b} @nozer;
	@nozyi = sort {$a <=> $b} @nozyi;
	my $minfactornozer = (1/5)*(sum(@nozer[0..4]));
	my $minfactornozyi = (1/5)*(sum(@nozyi[0..4]));
	my $yii = 0;
	for my $yi (@yi) {
		
		my $er = $er[$yii];
		my $output = $genelength * ( ($yi+$minfactornozyi) / ($er + $minfactornozer));	
		print OUT "\t$output";
		$yii += 1;
	}
	print OUT "\n";
}
close IN;
close OUT;

if ($opt_l) {

	open CATE, "$opt_l" or die;


	my %inin;
	while (<CATE>) {

		s/\r//g;
		chomp;
		my $ininone = (split(/\t/, $_))[1];
		$inin{$ininone} = 1;
	}
	for my $inone (keys(%inin)) {
		my $cate = `cat $opt_l | grep $inone`;
		my @cate = split(/\n/, $cate);
		&listone(("$inone", @cate));

	}


}


sub listone {


	my $thissign = shift(@_);
	open IN, "$opt_o" or die;
	open OUT, '>', "cache/category/$thissign.gct" or die;


	my %list;


	for my $oneone (@_) {
		$oneone =~ s/\r//g;
		chomp($oneone);
		my ($name, $project) = (split(/\t/, $oneone))[0];
		$list{$name} = 1;
	}

	
	my $firstline = <IN>;
	$firstline =~ s/\r//g;
	chomp($firstline);
	my @firstline = split(/\t/, $firstline);
	my $i1 = 0;
	my %select;
	print OUT "$firstline[0]\t$firstline[1]";
	for my $one (@firstline) {
		$i1 += 1;
		if (exists($list{$one})) {
			$select{$i1} = 1;
			print OUT "\t$one";
		}
	}
	print OUT "\n";
	while (<IN>) {
	
		$_ =~ s/\r//g;
		chomp;
		my @oneline = split(/\t/, $_);
		my $ii = 0;
	
		
		
		for my $one (@oneline) {
			$ii += 1;
			
	
			if ($ii == 1) {
				print OUT "$one";
			}elsif($ii == 2){
				print OUT "\t$one";
			}else{
				next unless exists($select{$ii});	
				print OUT "\t$one";
				}
		}
			
		print OUT "\n";
	}
}