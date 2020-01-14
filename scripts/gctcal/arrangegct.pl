use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o $opt_n $opt_r);
getopts('i:o:n:r:');

#how to use:
#perl scripts/gctcal/arrangegct.pl -i result/gctcal/ratioisoexact.great.gct -o result/gctcal/ratioisoexact.great.order.gct -n result/gctcal/ratioisoexact.great.orderlist.txt -r cache/gctcal/gdcsamplefour.txt


open IN, "$opt_i" or die;
open CLI, "$opt_r" or die;
open OUT, '>', "$opt_o" or die;
open OUTT, '>', "$opt_n" or die;


my @alldata;


my %cli;
while (<CLI>) {
	chomp($_);
	s/\r//g;
	my ($two, $one) = (split(/\t/, $_))[4,6];
	if (exists($cli{$one})) {
		die "unequal $one\n" if $cli{$one} ne $two;
	}else{
		$cli{$one} = $two;
	}
	
}
close CLI;

my $firstline = <IN>;
chomp($firstline);
my @firstline = split(/\t/, $firstline);
my @originalfirstline = @firstline;

my %firstline;
my @tempfirstline = qw/Name Description/;
my $nouse = shift(@firstline);
$nouse = shift(@firstline);

my @rowlist;
my %rowlist;
for my $oneone (@firstline) {
	my $yuanoneone = $oneone;
	$oneone =~ s/--(.*)$//g;
	my $project = $cli{$oneone};
	if (exists($firstline{$project})) {
		$firstline{$project} = "$firstline{$project}"."\t$yuanoneone";
		$rowlist{$project} = "$rowlist{$project}"."\t$project";
	}else{
		$firstline{$project} = "$yuanoneone";
		$rowlist{$project} = "$project";
	}
	
}

my @sortedkeys =  sort {$a cmp $b} keys(%firstline);
for my $project (@sortedkeys) {
	my @data = split(/\t/, $firstline{$project});
	my @data2 = split(/\t/, $rowlist{$project});
	push @tempfirstline, @data;
	push @rowlist, @data2;
}


my @samplelist = @tempfirstline;
my $samplelist = join("\t", @samplelist);

my $rowlist = join("\n", @rowlist);

print OUT "$samplelist\n";
print OUTT "$rowlist\n";





my %samplenum;
my %genenum;
my %num2num;

my $zi = 0;
for my $lineone (@samplelist) {
	$genenum{$lineone} = $zi;
	$zi += 1;
}

$zi = 0;
for my $lineone (@originalfirstline) {
	$samplenum{$lineone} = $zi;
	$zi += 1;
}

my @samplenumkeys = sort {$a cmp $b} keys(%samplenum);

for my $lineone (@samplenumkeys) {

	die "$lineone\n" unless exists($genenum{$lineone}); 
	$num2num{$genenum{$lineone}} = $samplenum{$lineone};
}


my $ini = 0;
while (<IN>) {

	chomp($_);
	my $linei = 0;
	my @array = split(/\t/, $_);
	for my $one (@array) {

		$alldata[$ini][$linei]= $one;		
		$linei += 1;
	
	}
	$ini += 1;
}

for (my $var = 0; $var < $ini; $var++) {

	my $linei = 0;
	for my $sample (@samplelist) {
		
		my $reali = $num2num{$linei};
		die "$sample\t$reali\n" unless exists($alldata[$var][$reali]);
		my $output = $alldata[$var][$reali];
		$linei += 1;
		if ($linei == 1) {
			print OUT "$output";
		}else{
			print OUT "\t$output";
		}
		
	}
	print OUT "\n";
}




close OUT;
close IN;
