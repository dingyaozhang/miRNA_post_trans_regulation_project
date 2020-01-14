use strict;
use warnings;


open IN, 'data/gctcal/hsa.gff3' or die;
open OUT, '>', "cache/gctcal/isoaccestoname.txt";


our %hash;
while (<IN>) {
	
	next if $. <= 13;
	chomp;
	my $type2 = (split(/\t/, $_))[8];
	
	if ($type2 =~ m/ID=([^;]+);.*Name=([^;]+);Derives_from=([^;]+)$/) {
		if (exists($hash{$1})) {
			die "$1\n" if $hash{$1} ne $2;
		}else{
			$hash{$1} = $2;
		}
		#print "$1\n";
	}

}

my @keys = sort {$a cmp $b} keys(%hash);

for my $var (@keys) {
	print OUT "$var\t$hash{$var}\n";
}

close IN;
close OUT;