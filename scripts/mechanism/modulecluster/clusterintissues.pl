#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');

use List::Util qw[min max];


my @cancerorder = qw/TCGA-BRCA TCGA-UCEC TCGA-LGG TCGA-LUAD TCGA-THCA TCGA-HNSC TCGA-PRAD TCGA-KIRC TCGA-LUSC TCGA-SKCM TCGA-COAD TCGA-BLCA TCGA-OV TCGA-LIHC TCGA-STAD TCGA-CESC TCGA-KIRP TCGA-SARC TCGA-PCPG TCGA-PAAD TCGA-READ TCGA-ESCA TCGA-TGCT TCGA-THYM TCGA-MESO TCGA-LAML TCGA-UVM TCGA-ACC TCGA-KICH TCGA-UCS TCGA-DLBC TCGA-CHOL/;


use Text::NSP::Measures::2D::Fisher::right;

sub calfisher {
	my @arrayin1 = @{$_[0]};
	my @arrayin2 = @{$_[1]};
	my $n11 = 0;
	for my $vara1 (@arrayin1) {
		for my $vara2 (@arrayin2) {
			$n11 += 1 if $vara1 eq $vara2;
		}
	}

	my $npp = $_[2];
	my $n1p = scalar(@arrayin1);
	my $np1 = scalar(@arrayin2);
 
	my $wholeminlength = min(scalar(@arrayin1), scalar(@arrayin2));
	my $threhold = 0.5*$wholeminlength;
	my $errorCode;

	if ($n11 < $threhold) {
		#print "$n11\t$threhold\n";
		return(1);
	
		
	}else{
		my $twotailed_value = calculateStatistic( n11=>$n11,
                                    n1p=>$n1p,
                                    np1=>$np1,
                                    npp=>$npp);
		if( ($errorCode = getErrorCode()))
		{
	
 		 print $errorCode." - ".getErrorMessage()."$n11\t$n1p\t$np1\t$npp\n";
		}else{
  			return("$twotailed_value\t$n11\t$wholeminlength");
		}

	}
}


open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;

my %hashuse;
my %genelist;

while (<IN>) {
	chomp;
	my @array = split(/\t/, $_);
	
	my $keykey = "$array[0]"."--"."$array[1]";
	if (exists($genelist{$array[0]})) {
		my %temphash = %{$genelist{$array[0]}};
		$temphash{$array[2]} = 1;
		$genelist{$array[0]} = \%temphash;
	}else{
		my %temphash;
		$temphash{$array[2]} = 1;
		$genelist{$array[0]} = \%temphash;
	}
	
	if (exists($hashuse{$keykey})) {
		$hashuse{$keykey} = $hashuse{$keykey}."\t$array[2]";
	}else{
		$hashuse{$keykey} = $array[2];
	}
	
	
}


my @hashusekeys = keys(%hashuse);


for my $var (@hashusekeys) {
	for my $var2 (@hashusekeys) {
		next if $var eq $var2;
		my @arr1 = split(/\t/, $hashuse{$var});
		my @arr2 = split(/\t/, $hashuse{$var2});
		my $type1 = $var;
		my $type2 = $var2;
		$type1 =~ s/--.*//;
		$type2 =~ s/--.*//;

		my %temphash;
		for my $mirin1 (keys(%{$genelist{$type1}})) {
			$temphash{$mirin1} = 1;
		}
		for my $mirin2 (keys(%{$genelist{$type2}})) {
			$temphash{$mirin2} = 1;
		}
		my $genelength = scalar(keys(%temphash));
		
		my $pvalue = &calfisher(\@arr1, \@arr2, $genelength);
		my $ppp = (split(/\t/, $pvalue))[0];
		if ($ppp <= 0.05) {
			print OUT "$var\t$var2\t$pvalue\n";
		}

	}
	shift(@hashusekeys);
}


close OUT;
close IN;