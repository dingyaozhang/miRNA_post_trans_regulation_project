use strict;
use warnings;


my $timestring = `date`;
chomp($timestring);
$timestring =~ s/\s/_/g;

my $outputpath = $ARGV[0];
my @array0 = split(/::/, $ARGV[2]);
my @array = split(/::/, $ARGV[1]);
$outputpath = $outputpath."predict-$timestring";

system "mkdir $outputpath";


my $alloutput = '';
my $annotationtxt;
$annotationtxt = "$outputpath/annotation.txt";

for my $infile (@array0) {
	my $content = "$infile\n#########\n";
	$alloutput = "$alloutput"."$content";
}
for my $infile (@array) {
	my $content = `cat $infile`;
	$content = "$infile\n#########\n$content\n";
	$alloutput = "$alloutput"."$content";
}


open OUT, '>', "$annotationtxt" or die;
print OUT "$alloutput\n";
close OUT;

print "$outputpath/";