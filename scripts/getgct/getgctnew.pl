use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_p $opt_r $opt_o $opt_v);
getopts('p:r:o:v');


$opt_p =~ s/\/$//;
$opt_p = "$opt_p".'/';


open REF, "$opt_r" or die;
open OUT, '>', "$opt_o" or die;



my %ref;
my %md5;
my $nouse = <REF>;
print "delete in ref. $nouse";

while (<REF>) {
	chomp;
 	my @array = split(/\t/, $_);
 	
 	my $afile = "$opt_p"."$array[0]"."/$array[1]";
 	$md5{$afile} = $array[2];
 	$ref{$afile} = $array[0];
} 
close REF;

my %genelist;
my @keysref = keys(%ref);
@keysref = sort{$a cmp $b} @keysref;

for my $var (@keysref) {
	my $md5v = `md5sum $var`;
	$md5v =~ s/\s+(.*)$//g;
	if ($opt_v) {
		die "md5wrong $md5v\t$md5{$var}\n" if $md5v ne $md5{$var};
	}
	if ($var =~ m/\.gz$/) {
		open IN, "gzip -dc $var |" or die "$var";
	}else{
		open IN, "$var" or die "$var";
	}
	
	while (my $fileinone = <IN>) {
		my $genename = (split(/\t/, $fileinone))[0];
		
		$genelist{$genename} = 1;
		
	}
	
}

my @genelist = keys(%genelist);
@genelist = sort{$a cmp $b} @genelist;

print OUT "Name";
for my $onegene (@genelist) {
	print OUT "\t$onegene";
}
print OUT "\n";


print OUT "Description";
for my $onegene (@genelist) {
	print OUT "\t$onegene";
}
print OUT "\n";


for my $var (@keysref) {
	if ($var =~ m/\.gz$/) {
		open IN, "gzip -dc $var |";
	}else{
		open IN, "$var";
	}
	
	my %outgenehash;

	while (my $fileinone = <IN>) {
		chomp($fileinone);
		my ($genename, $value) = (split(/\t/, $fileinone))[0,1];
		if (exists($outgenehash{$genename})) {
			die "duplicate $genename\n";
		}
		$outgenehash{$genename} = $value;			
		
	}
	print OUT "$ref{$var}";
	for my $onegene (@genelist) {
		if (exists($outgenehash{$onegene})) {
			print OUT "\t$outgenehash{$onegene}";
		}else{
			print OUT "\t0";
		}
		
	}
	print OUT "\n";

	
}



close REF;
close OUT;