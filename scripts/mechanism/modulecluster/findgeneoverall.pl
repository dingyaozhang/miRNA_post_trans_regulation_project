use strict;
use warnings;

use List::Util qw(max min sum);


use Getopt::Std;
use vars qw($opt_i $opt_o $opt_l);
getopts('i:o:l:');

$opt_l =~ s/\/$//;
$opt_l = $opt_l.'/';
$opt_o =~ s/\/$//;
$opt_o = $opt_o.'/';

my $listlist = `find $opt_l -maxdepth 1 -type f`;
my @listlist = split(/\n/, $listlist);

my $fullfileprefixlist = '';

for my $fileone (@listlist) {
	my %list;

	my $filename = $fileone;
	if ($filename =~ m/^.*\/(clu[0-9]+)\.txt$/) {
		$filename = $1;
		#print "$filename\n";
	}else{
		next;
		#die "wrong file path $filename\n";
	}
	

	open LIST, "$fileone" or die;
	while (<LIST>) {
		chomp;
		$list{$_} = 1;
	}
	close LIST;

	open IN, "$opt_i" or die;
	my %hash;
	my %hashhost;
	my %hashlength;

	my $preline = <IN>;
	while (<IN>) {
		next unless $_ =~ m/^ALL/;
		chomp($_);
		my @array = split(/\t/, $_);
		if (exists($list{$array[1]})) {
			$hashlength{$array[1]} = 1;
			my $keyhash = "$array[0]"."\t"."$array[2]";
			next if $array[3] eq 'NA';
			next if $array[7] eq 'NA';


			if (exists($hash{$keyhash})) {
				$hash{$keyhash} .= "\t$array[3]";
			}else{
				$hash{$keyhash} = $array[3];
			}
			if (exists($hashhost{$keyhash})) {
				$hashhost{$keyhash} .= "\t$array[7]";
			}else{
				$hashhost{$keyhash} = $array[7];
			}
		}
		
	}
	close IN;
	my $hashlength = scalar keys(%hashlength);
	my @sortedkeys = sort {$a cmp $b} keys(%hash);
	
	open OUT, '>', "$opt_o"."$filename".'ratio.txt' or die;
	for my $var (@sortedkeys) {
		my @array = split(/\t/, $hash{$var});
		my $arraylength = scalar @array;
		next if $hashlength > $arraylength;
		#my $medsta = sum(@array) / $arraylength;
		my $medsta = &median(@array);
		print OUT "$var\t$medsta\n";
	}
	close OUT;
	
	@sortedkeys = sort {$a cmp $b} keys(%hashhost);
	open OUT, '>', "$opt_o"."$filename".'host.txt' or die;
	for my $var (@sortedkeys) {
		my @array = split(/\t/, $hashhost{$var});
		my $arraylength = scalar @array;
		next if $hashlength > $arraylength;
		#my $medsta = sum(@array) / $arraylength;
		my $medsta = &median(@array);
		print OUT "$var\t$medsta\n";
	}
	close OUT;

	if ($fullfileprefixlist eq '') {
		$fullfileprefixlist = $filename;
	}else{
		$fullfileprefixlist = $fullfileprefixlist."\t$filename";
	}
}

print "$fullfileprefixlist";

sub median{
   my @vec = @_;
   my @vec_sort = sort{$a<=>$b} @vec;
   my $length = scalar @vec_sort;
   my $result;
   if($length % 2){
       $result=$vec_sort[($length-1)/2];
   }else{
       $result=($vec_sort[$length/2]+$vec_sort[$length/2-1])/2;
       }
   return $result;
}

