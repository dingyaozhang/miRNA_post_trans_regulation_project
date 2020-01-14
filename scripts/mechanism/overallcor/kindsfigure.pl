use strict;
use warnings;


#perl scripts/kindsfigure.pl -i ../mechanism/result/ratiooveralltarget/ -o result/kindsfiguretarget.txt
#perl scripts/kindsfigure.pl -i ../mechanism/result/ratiooverallreal/ -o result/kindsfigurereal.txt


use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');

my @getlist = `find $opt_i -maxdepth 1`;

$opt_i =~ s/\/$//;
open OUT, '>', "$opt_o" or die;
open OUTT, '>', "$opt_o.sat" or die;


my $i = 0;


for my $getlist (@getlist) {
	chomp($getlist);
	my $project;
	my $cancertype;
	my %ref;
	
	if ($getlist =~ m/overallcorrelation(.*).txt/) {
		$project = $1;
	}else{
		next;
	}
	unless ($project) {
		$cancertype = 'all';
		$project = 'all';
	}
	
	open IN, "$getlist" or die "$getlist";


	my $firstline = <IN>;
	$firstline =~ s/\r//g;
	$firstline = "project\t$firstline";

	$ref{'post'} = 0;
	$ref{'trans'} = 0;
	$ref{'same'} = 0;

	print OUT "$firstline" if $i == 0;
	
	
	while (my $inaa = <IN>) {
		$inaa =~ s/\r//g;

		chomp($inaa);
		my @array = split(/\t/, $inaa);
		if ($array[5] > $array[8]) {
			$ref{'post'} += 1;
		}elsif ($array[5] < $array[8]) {
			$ref{'trans'} += 1;
		}else{
			$ref{'same'} += 1;
		}
		print OUT "$project\t$inaa\n";
	}
	
	close IN;
	print OUTT "$project\t$ref{post}\t$ref{trans}\t$ref{same}\n";
	$i += 1;
}
	

close OUT;
close OUTT;


=pod
open OUT, '>', "$opt_o.sta" or die;
for my $onewholearray (@wholearray) {
		
	$onewholearray = $onewholearray / $iinaa;
	print OUT "\t$onewholearray";
}
close OUT;