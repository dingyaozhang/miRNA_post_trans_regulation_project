#!/usr/bin/perl
use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o $opt_r);
getopts('i:o:r:');

$opt_i =~ s/\/$//;
$opt_i = $opt_i.'/';


open OUT, '>', "$opt_o" or die;
open IN, "$opt_r" or die;

my $line1 = <IN>;
print OUT "$line1";
while (<IN>) {
	chomp;
	my ($file, $filename ,$realmd5) = (split(/\t/, $_))[0,1,2];
	my $filepath = $opt_i.$file.'/'.$filename;

	if (-e $filepath) {
		
		my $md5v = `md5sum $filepath`;
		my $md5v2 = (split(/\s+/, $md5v))[0];
		print "$md5v2\n";   #should delete but forget
		print "$realmd5\n"; #should delete but forget
		print OUT "$_\n" if $md5v2 ne $realmd5;
	}else{
		print OUT "$_\n";
	}

}
close IN;
close OUT;



