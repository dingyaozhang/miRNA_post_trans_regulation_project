use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o $opt_t);
getopts('i:o:t:');


open REF, 'cache/gctcal/transformchipmir.txt' or die;
open LIST, 'cache/gctcal/overlap.txt' or die;
open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;
open OUTT, '>', "$opt_t" or die;

my %ref;
my %ref2;


while (<REF>) {
	
	
	chomp;
	my $exactname = (split(/\t/, $_))[0];
	my $hairpinname = $exactname;
	$hairpinname =~ s/-[53]p$//;
	if (exists($ref{$hairpinname})) {
		$ref2{$exactname} = 1;
		$ref2{$ref{$hairpinname}} = 1;
		delete($ref2{hairpinname});
	}else{
		$ref2{$hairpinname} = 1;
	}
	$ref{$hairpinname} = $exactname;
	
}
close REF;

my %list;


while (<LIST>) {
	
	chomp;
	my ($mir, $gene) = (split(/\t/, $_))[0,1];
	$list{$mir} = $gene;

}
close LIST;

my $line1 = <IN>;
print OUTT "$line1";

while (<IN>) {
	my @array = split(/\t/, $_);
	my $mir = shift(@array);
	unless (exists($ref2{$mir})) {
		print "stanger mir $mir \n";
	}
	if (exists($list{$mir})) {
		print OUT "$mir\t$list{$mir}\n";
		print OUTT "$_";
	}elsif (exists($ref{$mir})) {
		my $realname = $ref{$mir};
		if (exists($list{$realname})) {
			print OUT "$realname\t$list{$realname}\n";
			my $join = join("\t", @array);
			print OUTT "$realname\t$join";
		}
	}
}


close IN;
close OUT;
close OUTT;