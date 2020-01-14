use strict;
use warnings;

use Getopt::Std;
use vars qw($opt_i $opt_l $opt_o);
getopts('i:l:o:');


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
#my @firstline = split(/\t/, $firstline);
#my $firstone = shift(@firstline);
#my $nouse = shift(@firstline);
#print OUT "$firstone";
#for my $one (@firstline) {
#	print OUT "\t$one";
#}
while (<IN>) {

	$_ =~ s/\r//g;
	chomp;
	my @oneline = split(/\t/, $_);
	my $ii = 0;
	
	my $genename = $oneline[1];
	my $genelength;
	if (exists($ref{$oneline[1]})) {
		$genelength = $ref{$oneline[1]};
	}else{
		die "$oneline[1]\n";
	}
	
	
	for my $one (@oneline) {
		$ii += 1;
		

		if ($ii == 1) {
			print OUT "$one";
		}elsif($ii == 2){
			print OUT "\t$one";
		}else{
			my ($yi, $er) =  (split(/\//, $one))[0,1];
			my $eryuan = $er;
			#$er = ($er / $genelength);
			if ($yi <= 3){
				print OUT "\t1";
			}else{

				my $output = ($yi + 0.009999) / (($er + 0.01)/$genelength);
				print OUT "\t$output";
			}
			#my $output = $yi  / ($er + 0.000001);
			#print OUT "\t$output";
		}
		
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
=pod
	open IN, "$opt_i" or die;
	open LIST, "$opt_l" or die;
	open OUT, '>', "$opt_o" or die;
	my %list;
	while (<LIST>) {
	
		$_ =~ s/\r//g;
		chomp;
		my ($name, $project) = (split(/\t/, $_))[0];
		$list{$name} = 1;
	}
	our %hash;
	my $firstline = <IN>;
	$firstline =~ s/\r//g;
	chomp($firstline);
	my @firstline = split(/\t/, $firstline);
	my $firstone = shift(@firstline);
	my $nouse = shift(@firstline);
	print OUT "$firstone";
	my $i1 = 2;
	my %select;
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
				#print OUT "\t$one";
			}else{
				next unless exists($select{$ii});
				my ($yi, $er) =  (split(/\//, $one))[0,1];
				if (($yi <= 0.08) && ($er <= 0.08)) {
					print OUT "\tNA";
				}else{
					my $output = ($yi + 0.01) / ($er + 0.01);
					print OUT "\t$output";
				}
			}
			
		}
		print OUT "\n";
	}