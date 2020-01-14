use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o $opt_r);
getopts('i:o:r:');


my $countfile = "$opt_r";
my $mirnafile = "$opt_i";


open IN, "$mirnafile" or die;
open COUNT, "$countfile" or die;
open OUT, '>', "$opt_o" or die;


my $genename = <COUNT>;
my $mirnaname = <IN>;
chomp($genename);
chomp($mirnaname);
my @genename = split(/\t/, $genename);
my @mirnaname = split(/\t/, $mirnaname);
shift(@genename);
shift(@genename);
my $line11 = shift(@mirnaname);
my $line12 = shift(@mirnaname);


my ($beforea, $aftera) = &getfrombasetochangearray(\@genename, \@mirnaname);
my @beforea = @{$beforea};
my @aftera = @{$aftera};


my @line1temp = @mirnaname[@beforea];
my $line1temp = join("\t", @line1temp);
print OUT "$line11\t$line12\t$line1temp\n";


while (<IN>) {

	chomp;
	my @array = split(/\t/, $_);
	my $firstone = shift(@array);
	my $secondone = shift(@array);
	my @orderarray = @array[@beforea];
	my $orderarray = join("\t", @orderarray);
	print OUT "$firstone\t$secondone\t$orderarray\n";	
}

close IN;


while (<COUNT>) {
	chomp;
	my @array = split(/\t/, $_);
	my $firstone = shift(@array);
	my $secondone = shift(@array);
	$firstone =~ s/\.(.*)//;

	

	my @geneordered = @array;
	@geneordered = @geneordered[@aftera];
	my $geneone = join("\t", @geneordered);
	print OUT "$firstone\t$firstone\t$geneone\n";
}


close COUNT;
close OUT;


sub getfrombasetochangearray{ 


	my @change = @{$_[0]};
	my @base = @{$_[1]};

	my %refbase;
	my %refchange;
	
	
	my $ichange = 0;
	for my $onechange (@change) {
		$refchange{$onechange} = $ichange;
		$ichange += 1;
	}
	
	
	#my %hasharrtobase;
	my $ibase = 0;
	
	my @before;
	my @after;
	
	for my $onebase (@base) {
		
		if (exists($refchange{$onebase})) {
			push @before, "$ibase";
			push @after, "$refchange{$onebase}";
		}
		$ibase += 1;
	
	}
	my @out = (\@before, \@after);
	return(@out);

}


sub adjustcol {


	my @change = @{$_[0]};
	my @change2base = @{$_[1]};

	my @out;
	for my $onenum (@change2base) {
		push @out, "$change[$onenum]";
	}

	
	return(@out);

}
