use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o $opt_r $opt_t);
getopts('i:o:r:t:');


open REF, "$opt_r" or die;
open OUT, '>', "$opt_o" or die;
open IN, "$opt_i" or die;


my $valuethrehold = 8;

my @datamat;

my $line1 = <REF>;
chomp($line1);
my @line1 = split(/\t/, $line1);
shift(@line1);
shift(@line1);

my %trans;
if ($opt_t) {
	open TT, "$opt_t" or die;
	while (<TT>) {
		chomp;
		my ($countid, $fpkmid) = split(/\t/, $_);
		$trans{$countid} = $fpkmid;
	}
	close TT;
}

my %sample2num;
my $varii = 0;
for my $var (@line1) {
	if ($opt_t) {
		if ($var =~ m/^(.+)--(.+)$/) {
			my $thisname = $1.'--'.$trans{$2};
			$sample2num{$thisname} = $varii;
			$var = $thisname;
		}else{
			$sample2num{$var} = $varii;
		}
	}else{
		$sample2num{$var} = $varii;
	}
	
	$varii += 1;
}


my %mir2name;
while (<REF>) {
	chomp;
	my @array = split(/\t/, $_);
	my $name = shift(@array);
	my $description = shift(@array);

	unless (exists($mir2name{$name})) {
		$mir2name{$name} = $. - 2;
	}

	my $thisi = -1;
	for my $var (@array) {
		$thisi += 1;
		my $samplename = $line1[$thisi];
		unless (exists($sample2num{$samplename})) {
			die "$thisi\t$samplename\n";
		}
		if ($var >= $valuethrehold) {
			$datamat[$mir2name{$name}][$sample2num{$samplename}] = 1;
		}
		
	}

}






my $linefirst = <IN>;
chomp($linefirst);
my @linefirst = split(/\t/, $linefirst);
shift(@linefirst);
shift(@linefirst);


my @thesample2num;
for my $var (@linefirst) {
	if (exists($sample2num{$var})) {
		push @thesample2num, $sample2num{$var};
	}else{
		die "different\t$var\n";
	}
	
}

print OUT "$linefirst\n";
while (<IN>) {
	chomp;
	my @array = split(/\t/, $_);
	my $name = shift(@array);
	my $description = shift(@array);

	unless (exists($mir2name{$name})) {
		die "this row $name doesn't have. \n";
	}

	print OUT "$name\t$description";
	my $thisi = -1;
	for my $var (@array) {
		$thisi += 1;

		if (exists($datamat[$mir2name{$name}][$thesample2num[$thisi]])) {
			print OUT "\t$var";
		}else{
			print OUT "\tNA";
		}
		
	}
	print OUT "\n";

}



close IN;
close OUT;
close REF;

