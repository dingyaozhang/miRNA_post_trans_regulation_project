use strict;
use warnings;


#our %sample;
#our %genelist;

use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');

open IN, "$opt_i" or die;
open CACHEONE, '>', "cache/gctcal/temptranscache.txt" or die;

my @matrix;

my $line1 = <IN>;
chomp($line1);
my @line1 = split(/\t/, $line1);
push @matrix, [@line1];

while (<IN>) {
	chomp;
	my @array = split(/\t/, $_);
	my @adjustlog = ("$array[0]", "$array[1]");
	my @adjustlog2 = &adjustall(@array);
	push @adjustlog, @adjustlog2;
	push @matrix, [@adjustlog];
}



my $genelength = scalar @{$matrix[0]};
my $samplelength = scalar @matrix;

for (my $var = 0; $var < $genelength; $var++) {
	my @array;
	push @array, $matrix[$_][$var] for 0..($samplelength-1);
	my $array = join("\t", @array);
	print CACHEONE "$array\n";
}


close IN;
close CACHEONE;

undef(@matrix);

open CACHE, "cache/gctcal/temptranscache.txt" or die;
my @adjustfactor = ('NA', 'NA');
my $nouse = <CACHE>;
$nouse = <CACHE>;

while (<CACHE>) {
	chomp;
	my @array = split(/\t/, $_);
	shift(@array);
	my $median = &median(@array);
	push @adjustfactor, "$median";
}
close CACHE;



open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;

my $firstoutput = <IN>;
print OUT "$firstoutput";
while (<IN>) {

	chomp;
	my @array = split(/\t/, $_);
	my $output = "$array[0]\t$array[1]";
	my $i = -1;
	for my $tempkey (@array) {
		$i += 1;
		next if $i <= 1;
		my $thisfactor = $adjustfactor[$i];
		my $thisvalue = $tempkey / $thisfactor;
		#print "$thisvalue\n";
		$output = "$output\t$thisvalue";
	}
	print OUT "$output\n";
}
close IN;

sub median{
	my @usethis;
	for my $thisnum (@_) {
		push @usethis, "$thisnum" if $thisnum ne 'NA';
	}
    my @vec1 = sort { $a <=> $b } @usethis;
    my $length= scalar @usethis;
    my $result;
    if($length % 2){
        $result=$vec1[($length-1)/2];
    }else{
        $result=($vec1[$length/2]+$vec1[$length/2-1])/2;
    }
    return $result;
}

sub aver {


	my @calnum = @_;
	my $thelength = scalar @calnum;
	my $sumall;
	for my $temptemp (@calnum) {
		if ($temptemp == 0) {
			$sumall = 'NA';
			last;
		}else{
			$sumall += $temptemp;
		}
	}
	my $avernum;
	if ($sumall ne 'NA') {
		$avernum = ($sumall / $thelength);
	}else{
		$avernum = 'NA' if $sumall eq 'NA';
	}
	return $avernum;

}

sub adjustall {


	my @calnum = @_;
	my @outputarray0;
	my @outputarray;
	my $adji = 0;
	for my $temptemp (@calnum) {
		$adji += 1;
		if ($adji <= 2) {
			next;
		}else{
			if ($temptemp == 0) {
				$outputarray0[0] = 0;
				last;
			}else{
				my $atemp = log($temptemp);
				push @outputarray0, "$atemp";
			}
		}
		
	}
	my $average = &aver(@outputarray0);
	my $lengthin = scalar @calnum;
	$lengthin = $lengthin - 2;
	for my $temptemp (@outputarray0) {
		if ($average eq 'NA') {
			for (my $var = 0; $var < $lengthin; $var++) {
				push @outputarray, "NA";
			}
			last;
		}else{
			my $atemp = $temptemp - $average;
			$atemp = exp($atemp);
			push @outputarray, "$atemp";
		}
	}
	return @outputarray;
}

