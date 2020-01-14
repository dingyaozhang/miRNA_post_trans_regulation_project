#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');

my %wholeclusters;
my %wholeclustersreverse;

open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;


my %temphash = ();
my $one2cluster;
my $clusterimax = 1;


my $line1 = <IN>;
chomp($line1);
my ($line11, $line12) = (split(/\t/, $line1))[0,1];
$temphash{$line11} = 1;
$temphash{$line12} = 1;



$wholeclusters{$line11} = $clusterimax;
$wholeclusters{$line12} = $clusterimax;
$wholeclustersreverse{$clusterimax} = \%temphash;

undef(%temphash);
while (<IN>) {
	chomp;
	my @array = split(/\t/, $_);
	if ( (exists($wholeclusters{$array[1]})) && (exists($wholeclusters{$array[0]})) ) {
		my %temphash = %{$wholeclustersreverse{$wholeclusters{$array[0]}}};
		my %temphash2 = %{$wholeclustersreverse{$wholeclusters{$array[1]}}};
		for my $varkey (keys(%temphash2)) {
			$temphash{$varkey} = 1;
		}
		delete($wholeclustersreverse{$wholeclusters{$array[1]}});

		for my $allvar (keys(%temphash2)) {
			$wholeclusters{$allvar} = $wholeclusters{$array[0]};

		}
		$wholeclustersreverse{$wholeclusters{$array[0]}} = \%temphash;
		#print "$array[1]\n$array[0]\n";
	}elsif (exists($wholeclusters{$array[0]})) {


		$wholeclusters{$array[1]} = $wholeclusters{$array[0]};
		my %temphash = %{$wholeclustersreverse{$wholeclusters{$array[0]}}};
		$temphash{$array[1]} = 1;
		$wholeclustersreverse{$wholeclusters{$array[0]}} = \%temphash;
	
	}elsif(exists($wholeclusters{$array[1]})) {


		$wholeclusters{$array[0]} = $wholeclusters{$array[1]};
		my %temphash = %{$wholeclustersreverse{$wholeclusters{$array[1]}}};
		$temphash{$array[0]} = 1;
		$wholeclustersreverse{$wholeclusters{$array[1]}} = \%temphash;
	
	}else{

		$clusterimax += 1;
		my %temphash = ();
		$temphash{$array[0]} = 1;
		$temphash{$array[1]} = 1;
		$wholeclusters{$array[0]} = $clusterimax;
		$wholeclusters{$array[1]} = $clusterimax;
		$wholeclustersreverse{$clusterimax} = \%temphash;
		
	}
}

for my $oneclusterkey (keys(%wholeclustersreverse)) {
	
	my %temphash = %{$wholeclustersreverse{$oneclusterkey}};
    my $out = join("\t", keys(%temphash));
    print OUT "$oneclusterkey\t$out\n";

}
