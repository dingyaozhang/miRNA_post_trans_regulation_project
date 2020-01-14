use strict;
use warnings;

#perl overallfiguredata.pl -i result/5p3poverall/
use Getopt::Std;
use vars qw($opt_i $opt_r);
getopts('i:r:');

my @getlist = `find $opt_i -maxdepth 1`;
unless ($opt_r) {
	$opt_r = "data/mechanism/tcgaabbr/tcgashort2fullname.txt";
}
open REF, "$opt_r" or die;
$opt_i =~ s/\/$//;
open OUT, '>', "$opt_i/figuredata.txt" or die;

my %ref;

while (<REF>) {
	$_ =~ s/\r//g;
	chomp($_);
	my ($code, $cancertype) = (split(/\t/, $_))[0,1];
	$cancertype =~ s/\s+$//g;
	$cancertype =~ s/\s+/_/g;
	my $code0 = "TCGA-$code";
	$code = "TARGET-$code";
	$ref{$code} = "$cancertype"."_TARGET";
	$ref{$code0} = $cancertype;
}

my $i = 0;
for my $getlist (@getlist) {
	chomp($getlist);
	my $project;
	my $cancertype;
	
	if ($getlist =~ m/overallcorrelation(.*).txt/) {
		$project = $1;
	}else{
		next;
	}
	unless ($project) {
		$cancertype = 'all';
		$project = 'all';
	}else{
		if (exists($ref{$project})) {
			$cancertype = $ref{$project};
		}else{
			$cancertype = $project;
		}
	}
	
	open IN, "$getlist" or die "$getlist";


	my $firstline = <IN>;
	$firstline =~ s/\r//g;
	chomp($firstline);
	my @firstline = split(/\t/, $firstline);
	shift(@firstline);
	$firstline = join("\t", @firstline);


	print OUT "Shortname\tCancertype\t$firstline\n" if $i == 0;
	my $lennum = scalar(@firstline);
	#die "$lennum lennum\n";
	my $wholearray = 0 x $lennum;
	my @wholearray = split(//, $wholearray);
	#print @wholearray;
	my $iinaa = 0;
	while (my $inaa = <IN>) {
		$inaa =~ s/\r//g;
		chomp($inaa);
		my @array = split(/\t/, $inaa);
		shift(@array);
		@wholearray = &sumarray(\@wholearray, \@array);
		$iinaa += 1;
	}
	#print @wholearray;
	#print "\n";
	close IN;
	print OUT "$project\t$cancertype";
	for my $onewholearray (@wholearray) {
		#chomp($onewholearray);
		if ($iinaa > 0) {
			$onewholearray = $onewholearray / $iinaa;
			print OUT "\t$onewholearray";
		}else{
			print OUT "\tNA";
		}
		
	}
	print OUT "\n";
	
	$i += 1;
}
	

close OUT;
close REF;

sub sumarray {
	
	my @one = @{$_[0]};
	my @two = @{$_[1]};
	#print @one;
	#print @two;
	#print "\n";
	
	my $len = scalar(@one);
	#die "length is $len \n";
	my @arrayarray;
	for (my $var = 0; $var < $len; $var++) {
		$arrayarray[$var] = $one[$var] + $two[$var];
		
	}
	#print "\nasds$len\n";
	return(@arrayarray)

}