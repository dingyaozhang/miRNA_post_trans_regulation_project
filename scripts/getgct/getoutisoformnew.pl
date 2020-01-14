use strict;
use warnings;
use threads;
use threads::shared;


use Getopt::Std;
use vars qw($opt_r $opt_p $opt_o);
getopts('r:p:o:');

$opt_p =~ s/\/$//;
$opt_p = $opt_p.'/';
$opt_o =~ s/\/$//;
$opt_o = $opt_o.'/';

unless (-e $opt_o) {
	system "mkdir $opt_o";
}
unless (-e "$opt_o"."count") {
	system "mkdir $opt_o"."count";
}
unless (-e "$opt_o"."fpkm") {
	system "mkdir $opt_o"."fpkm";
}


open REF, "$opt_r" or die;
my $ref1 = <REF>;
print "delete in ref. $ref1";

our @reffile;
my %md5;

while (<REF>) {
	chomp;
	my @array = split(/\t/, $_);
	my $path = $opt_p."$array[0]"."/$array[1]";
	push @reffile, "$path";
	$md5{$path} = $array[2];
}
close REF;




my $arraynum = scalar(@reffile);
my $onesection = int($arraynum / 4) + 1;


our @one = splice(@reffile,0,$onesection);
our @two = splice(@reffile,0,$onesection);
our @three = splice(@reffile,0,$onesection);
our @four = @reffile;


our $thread_1_01 = threads->create('onedeal', @one);
our $thread_1_02 = threads->create('onedeal', @two);
our $thread_1_03 = threads->create('onedeal', @three);
our $thread_1_04 = threads->create('onedeal', @four);


$thread_1_01->join();
$thread_1_02->join();
$thread_1_03->join();
$thread_1_04->join();


sub onedeal {

	for my $singlelocation (@_) {
		
		my $md5v = `md5sum $singlelocation`;
		$md5v =~ s/\s+(.*)$//g;
		die "md5wrong $md5v\t$md5{$singlelocation}\n" if $md5v ne $md5{$singlelocation};
		open IN, "$singlelocation" or die "$singlelocation";
		my %count;
		my %fpkm;
		while (<IN>) {
			
		
			chomp;
			my ($count, $fpkm, $cross, $sym) = (split(/\t/, $_))[2,3,4,5];
			
			next unless $sym =~ m/mature,/;
			next unless $cross eq 'N';
			my $number = (split(/,/, $sym))[1];
			
			if (exists($fpkm{$number})) {
				$fpkm{$number} = $fpkm{$number} + $fpkm;
			}else{
				$fpkm{$number} = $fpkm;
			}
			
		
			if (exists($count{$number})) {
				$count{$number} = $count{$number} + $count;
			}else{
				$count{$number} = $count;
			}
			
		
		}
		close IN;

		my $outlocation1;
		my $outlocation2;

		if ($singlelocation =~ m/^$opt_p([^\/]+)\/([^\/]+)$/ ) {
			unless (-e "$opt_o"."fpkm/$1") {
				system "mkdir $opt_o"."fpkm/$1";
				system "mkdir $opt_o"."count/$1";
			}
			$outlocation1 = "$opt_o"."fpkm/$1/$2";
			$outlocation2 = "$opt_o"."count/$1/$2";
		}else{
			die "don't know why $opt_p \n $singlelocation\n";
		}
		open OUT, '>', "$outlocation1" or die "can output to out $outlocation1\n";
		open OUTT, '>', "$outlocation2" or die "can output to out $outlocation2\n";
		for my $onekey (keys(%fpkm)) {
		
	
			my $fpkm = $fpkm{$onekey};
			my $count = $count{$onekey};
			print OUT "$onekey\t$fpkm\n";
			print OUTT "$onekey\t$count\n";
	
		}
		close OUT;
		close OUTT;
	}
	
}



