use strict;
use warnings;



my @array = @ARGV;
my $outputpath = $array[0];
my $genelist = "$outputpath"."genelist.txt";
my $outputmir = "$outputpath"."mir.gct";
my $outputgene = "$outputpath"."gene.gct";
my $outputratio = "$outputpath"."ratio.gct";

my %mir;
open IN, "$genelist" or die;
while (<IN>) {
	s/\r//g;
	chomp;
	$mir{$_} = 1;
}
close IN;


my %userows;

open RATIO, '>', "$outputratio" or die;
open IN, "$array[2]" or die;

while (<IN>) {
	s/\r//g;
	chomp;
	if ($. == 1) {
		print RATIO "$_\n";
	}else{
		my $name = (split(/\t/, $_))[0];
		next unless exists($mir{$name});
		print RATIO "$_\n";
		$userows{$name} = 1;
	}
	
}


close IN;
close RATIO;




open MIR, '>', "$outputmir" or die;
open GENE, '>', "$outputgene" or die;

open IN, "$array[1]" or die;

while (<IN>) {
	s/\r//g;
	chomp;
	if ($. == 1) {
		print MIR "$_\n";
		print GENE "$_\n";
	}else{
		my @line = split(/\t/, $_);
		my $one = shift(@line);
		my $two = shift(@line);
		next unless exists($userows{$one});
		print MIR "$one\t$two";
		print GENE "$one\t$two";
		for my $ratio (@line) {
			my ($ratio0, $ratio1) = split(/\//, $ratio);
			print MIR "\t$ratio0";
			print GENE "\t$ratio1";
		}
		print MIR "\n";
		print GENE "\n";
	}
	
}


close IN;
close MIR;
close GENE;

