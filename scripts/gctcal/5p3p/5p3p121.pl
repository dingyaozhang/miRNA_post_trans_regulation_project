use strict;
use warnings;

use Getopt::Std;
use vars qw($opt_i $opt_o $opt_c $opt_y);
getopts('i:o:yc');


open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;


my $firline = <IN>;
print OUT "$firline";

my %data;
my %name;


while (<IN>) {

	chomp($_);
	my @array = split(/\t/, $_);
	my $mirnaname = shift(@array);

	my $mirnaccession = shift(@array);
	my $mirnaname0 = $mirnaname;
	if ($mirnaname =~ s/-5p$//) {
		#print "$mirnaname\n";
		$name{$mirnaname} = 1;
		$data{$mirnaname0} = \@array;
	}elsif($mirnaname =~ s/-3p$//) {
		$name{$mirnaname} = 1;
		$data{$mirnaname0} = \@array;
	}else{
		next;
	}
	

}


my @keysnames = sort {$a cmp $b} keys(%name);
if ($opt_c) {
	for my $oneclu (@keysnames) {
		my $five = "$oneclu-5p";
		my $three = "$oneclu-3p";

		if (exists($data{$five}) && exists($data{$three})) {
			my @five = @{$data{$five}};
			my @three = @{$data{$three}};
			my $fiveout = join("\t", @five);
			my $threeout = join("\t", @three);
			print OUT "$oneclu\t$five\t$fiveout\n";
			print OUT "$oneclu\t$three\t$threeout\n";
		}
	}
}elsif($opt_y) {
	for my $oneclu (@keysnames) {
		my $five = "$oneclu-5p";
		my $three = "$oneclu-3p";
		if (exists($data{$five}) && exists($data{$three})) {
			
			print OUT "$oneclu\t$oneclu";
			my @five = @{$data{$five}};
			my @three = @{$data{$three}};
			for (my $var = 0; $var < scalar (@five); $var++) {
				my $fivemir = (split(/\//, $five[$var]))[0];
				my $threemir = (split(/\//, $three[$var]))[0];
				print OUT "\t$fivemir".'/'."$threemir";
			}
			print OUT "\n";
		}
	}


}else{
	for my $oneclu (@keysnames) {
		my $five = "$oneclu-5p";
		my $three = "$oneclu-3p";
		#print "$five\n";
		if (exists($data{$five}) && exists($data{$three})) {
			#print "$five\n";
			print OUT "$oneclu\t$oneclu";
			my @five = @{$data{$five}};
			my @three = @{$data{$three}};
			for (my $var = 0; $var < scalar (@five); $var++) {
				print OUT "\t$five[$var]".'/'."$three[$var]";
			}
			print OUT "\n";
		}
	}

}




close OUT;
close IN;

