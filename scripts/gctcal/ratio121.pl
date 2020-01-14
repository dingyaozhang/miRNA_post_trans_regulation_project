use strict;
use warnings;
use threads;
use threads::shared;

#NEED TO ADJUST GENE NAMES
use Getopt::Std;
use vars qw($opt_m $opt_g $opt_l $opt_o $opt_c);
getopts('m:g:l:o:c:');


our $mirfilename = $opt_m;
our $genefilename = $opt_g;
our @catlist     :  shared;


unless (-e 'cache/gctcal/ratio121') {
	system "mkdir cache/gctcal/ratio121";
}


open LAP, "$opt_l" or die;
open MIRLIST, "$mirfilename" or die;
open GENELIST, "$genefilename" or die;
open MAN, "$opt_c" or die;


our %project;


while (<MAN>) {


	my ($project, $sampleid) = (split(/\t/, $_))[4,6];
	$project{$sampleid} = $project;


}
close MAN;

our %samplehash0;
our %samplehash;
our %mirproject2sample;
our %geneproject2sample;

my $onelinemirna = <MIRLIST>;
chomp($onelinemirna);
my @mirlist = split(/\t/, $onelinemirna);


my $mironei = 0;
for my $mirone (@mirlist) {

	$mironei += 1;
	my $onesamplename;
	my $mironesim = $mirone;
	$mironesim =~ s/--(.*)//g;
	if (exists($project{$mironesim})) {
		$onesamplename = $project{$mironesim};
	}else{
		next;
	}
	$samplehash0{$onesamplename} = 1;


	if (exists($mirproject2sample{$onesamplename})) {
		$mirproject2sample{$onesamplename} .= ":$mirone";
	}else{
		$mirproject2sample{$onesamplename} = "$mirone";
	}

}


my $onelinegene = <GENELIST>;
chomp($onelinegene);
my @samgenelist = split(/\t/, $onelinegene);


my $geneonei = 0;
for my $geneone (@samgenelist) {


	my $geneonei += 1;
	my $onesamplename;


	if (exists($project{$geneone})) {
		$onesamplename = $project{$geneone};
	}else{
		next;
	}


	if (exists($samplehash0{$onesamplename})) {
		
		$samplehash{$onesamplename} = 1;
	
	}


	if (exists($geneproject2sample{$onesamplename})) {
		$geneproject2sample{$onesamplename} .= ":$geneone";
	}else{
		$geneproject2sample{$onesamplename} = "$geneone";
	}
}

undef(%samplehash0);




our @colselectuseitmir;
our @colselectuseitgene;
our @rowselectuseitmir;
our @rowselectuseitgene;

my @samplehashkeys =  sort {$a cmp $b} keys(%samplehash);

for my $samplehashone (@samplehashkeys) {

	my @samplesorder;
	my %colselectuseitmir0;
	
	my @mirarray = split(/:/, $mirproject2sample{$samplehashone});
	my @genearray = split(/:/, $geneproject2sample{$samplehashone});
	
	for my $mirarray0 (@mirarray) {
		$colselectuseitmir0{$mirarray0} = 1;
	}
	for my $genearray0 (@genearray) {
		if (exists($colselectuseitmir0{$genearray0})) {
			push @colselectuseitmir, "$genearray0";
		}
	}
	
	
	
}


@colselectuseitgene = @colselectuseitmir;


my %kindsgene;
my %kindsmirna;

while (<GENELIST>) {


	chomp;
	my $name = (split(/\t/, $_))[0];
	$name =~ s/\..*//;
	$kindsgene{$name} = $.;
	#print "what\t$name\n";


}


while (<MIRLIST>) {


	chomp;
	my $name = (split(/\t/, $_))[0];
	$kindsmirna{$name} = $.;


}


close GENELIST;
close MIRLIST;

my %overlap;
my %genelistgene;
while (<LAP>) {


	chomp;
	my ($mirname, $genename) = (split(/\t/, $_))[0,1];
	$overlap{$mirname} = $genename;
	$genelistgene{$genename} = 1;


}

close LAP;


my @kindsmirnakeys =  sort {$a cmp $b} keys(%kindsmirna);


for my $onepairmir (@kindsmirnakeys) {


	if (exists($overlap{$onepairmir})) {


		my $onekeykeytemp = $overlap{$onepairmir};
		#print "exits1 $onepairmir $onekeykeytemp\n";

		if ($kindsgene{$onekeykeytemp}) {

			#print "exits2 $onepairmir $onekeykeytemp\n";
			push @rowselectuseitmir, "$onepairmir";
			push @rowselectuseitgene, "$onekeykeytemp";

		}
	}


}



our $citemircol = \@colselectuseitmir;
our $citefpkmcol = \@colselectuseitgene;
our $citemirrow = \@rowselectuseitmir;
our $citefpkmrow = \@rowselectuseitgene;

our $alliii = scalar @colselectuseitmir;
$alliii += 1;
our $thread_0_01 = threads->create('rowselect', ("$mirfilename", $citemirrow));
our $thread_0_02 = threads->create('rowselect', ("$genefilename", $citefpkmrow));


$thread_0_01->join();
$thread_0_02->join();

our $thread_0_03 = threads->create('columnselect', ("$mirfilename.rowsorted", $citemircol));
our $thread_0_04 = threads->create('columnselect', ("$genefilename.rowsorted", $citefpkmcol));



$thread_0_03->join();
$thread_0_04->join();
#my @sorted_numbers = sort { $a <=> $b } @numbers;
my $arraynum = scalar @rowselectuseitmir;
#my $arraynum2 = scalar @rowselectuseitgene;
#print "$arraynum\t$arraynum2\n";

my $onesection = int($arraynum / 4) + 1;
my $man = scalar @rowselectuseitmir;
$man += 1;
my @man = 2..$man;

our @one = splice(@man,0,$onesection);
our @two = splice(@man,0,$onesection);
our @three = splice(@man,0,$onesection);
our @four = @man;

my $onenumber = scalar @one;
my $twonumber = scalar @two;
my $threenumber = scalar @three;
my $fournumber = scalar @four;

print "$onenumber ::$twonumber ::$threenumber ::$fournumber \n";
print "$arraynum onesidenum：$onesection\n";
print "$four[0]\n";

our $thread_1_01 = threads->create('getratio', @one);
our $thread_1_02 = threads->create('getratio', @two);
our $thread_1_03 = threads->create('getratio', @three);
our $thread_1_04 = threads->create('getratio', @four);


$thread_1_01->join();
$thread_1_02->join();
$thread_1_03->join();
$thread_1_04->join();

@catlist = sort { $a <=> $b } @catlist;
our $catcommand = 'cat ';
for my $anum (@catlist) {
	$catcommand = "$catcommand"."cache/gctcal/ratio121/ratiotempavoidtemp$anum.gct "
}
$catcommand = "$catcommand"."> cache/gctcal/ratio121/allratiotempavoidtemp.gct";
system "$catcommand";

system 'rm cache/gctcal/ratio121/ratiotempavoidtemp*.gct';
system "rm $mirfilename.rowsorted";
system "rm $mirfilename.rowsorted.columnsorted";
system "rm $genefilename.rowsorted";
system "rm $genefilename.rowsorted.columnsorted";


open FILE, "cache/gctcal/ratio121/allratiotempavoidtemp.gct" or die;
open OUT, '>', "$opt_o" or die;


print OUT "Name\tDescription";


for my $onecolname (@colselectuseitmir) {
	
	print OUT "\t$onecolname";
}


print OUT "\n";


for my $onerowname (@rowselectuseitmir) {


	my $onerow = <FILE>;
	chomp($onerow);
	my $onerowgenename = $overlap{$onerowname};
	
	print OUT "$onerowname\t$onerowgenename\t$onerow\n";
}


close FILE;
close OUT;
system 'rm cache/gctcal/ratio121/allratiotempavoidtemp.gct';

sub rowselect {


	my $file = $_[0];
	my @selectsample = @{$_[1]};
	open FILE, "$file" or die;
	open OUT, '>', "$file.rowsorted" or die;
	my %rownamelist;

	my $firstline = <FILE>;
	print OUT "$firstline";
	while (<FILE>) {
		

		my $name = (split(/\t/, $_))[0];
		$name =~ s/\..*//;
		if ($file eq "$genefilename") {
			if (exists($genelistgene{$name})){

				$rownamelist{$name} = $.;
			}
		}elsif ($file eq "$mirfilename") {

			if (exists($overlap{$name})) {
				$rownamelist{$name} = $.;
			}
		}
		
		
	}
	close FILE;

	
	for my $line (@selectsample) {
		
		my $selectfilei = 0;
		open FILE, "$file" or die;
		next unless exists $rownamelist{$line};
		my $thisorder = $rownamelist{$line};
		while (<FILE>) {
			$selectfilei += 1;
			if ($thisorder == $selectfilei) {
				print OUT "$_";
			}
		}
		close FILE;

	}

	close OUT;

}

sub columnselect {


	my $file = $_[0];
	my @selectsample = @{$_[1]};
	open FILE, "$file" or die;
	open OUT, '>', "$file.columnsorted" or die;
	my $asampleii = 0;
	my %columnselecttempfile;

	for my $aterm (@selectsample) {
		$asampleii += 1;
		$columnselecttempfile{$aterm} = 1;
	}

	my $firstline = <FILE>;
	chomp($firstline);
	my @firstline = split(/\t/, $firstline);
	my $atermi = 0;
	my %orderorder;


	print OUT "$firstline[0]\t$firstline[1]\t";


	for my $aterm (@firstline) {


		$atermi += 1;
		if (exists($columnselecttempfile{$aterm})){

			$orderorder{$aterm} = $atermi;
			
		}
	}
	
	for my $var (@selectsample) {
		print OUT "$var\t";
	}
	
	print OUT "\n";
	
	

	while (my $onefileline = <FILE>) {

		chomp($onefileline);
		my @onefileline = split(/\t/, $onefileline);
		
		my $littleoutput1 = "$onefileline[0]";
		my $littleoutput2 = "$onefileline[1]";
		$littleoutput1 =~ s/\..*//;
		$littleoutput2 =~ s/\..*//;
		my $littleoutput = "$littleoutput1\t$littleoutput2\t";
		print OUT "$littleoutput";

		for my $var (@selectsample) {

			next unless exists($orderorder{$var});
			my $thistimegenenum = $orderorder{$var};
			$thistimegenenum = $thistimegenenum - 1;
			my $output = $onefileline[$thistimegenenum];
			print OUT "$output\t";
		
			
		}
		
		print OUT "\n";

	}

	close FILE;
	close OUT;

}	


sub getratio {


	my @calnum = @_;
	open FILEX, "$mirfilename.rowsorted.columnsorted" or die;
	open FILEY, "$genefilename.rowsorted.columnsorted" or die;
	open OUT, '>', 'cache/gctcal/ratio121/ratiotempavoidtemp'."$calnum[0]".'.gct' or die;
	push @catlist, "$calnum[0]";


	my %linehash;
	for my $lineone (@calnum) {
		
		$linehash{$lineone} = 1;
	}

	my $filexyi = 0;
	while (my $filex = <FILEX>) {


		$filexyi += 1;
		my $filey = <FILEY>;
		next if $filexyi == 1;
		next unless exists($linehash{$.});
		chomp($filex);
		chomp($filey);
		my @filex = split(/\t/, $filex);
		my @filey = split(/\t/, $filey);

		for (my $var = 2; $var <= $alliii; $var++) {

			my $output;
			my $filexnum = $filex[$var];
			my $fileynum = $filey[$var];
			$output = "$filexnum".'/'."$fileynum";
			if ($var == 2) {
				print OUT "$output";
			}else{
				print OUT "\t$output";
				
			}
			
		}
		print OUT "\n";
		
	}
	
	close FILEX;
	close FILEY;
	close OUT;

}


