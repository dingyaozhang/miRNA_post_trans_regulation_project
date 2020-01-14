use strict;
use warnings;
use threads;
use threads::shared;

open MAN, 'data/manifest_out.txt' or die;
open CLI, 'data/clinical_out.txt' or die;


system "mkdir cache/getgct/getgctfourtemp";


our %fpkm     :  shared;
our %fpkmuq   :  shared;
our %count   :  shared;
our %mirna   :  shared;
our %genelist   :  shared;
our %existingsam   :  shared;



our %cli;
our $clii = 0;
while (<CLI>) {
	$clii += 1;
	next if $clii == 1;
	chomp;
	my $key = (split(/\t/, $_))[0];
	my $samthis = (split(/\t/, $_))[1];
	
	$cli{$key} = $samthis;
	
}
close CLI;


our @man;
our $mani = 0;
print "Cli reads\n";
while (<MAN>) {
	$mani += 1;
	next if $mani == 1;
	chomp;
	push @man, "$_";
}
close MAN;
print "Man reads\n";
our $arraynum = scalar @man;
our $onesection = int($arraynum / 4);

our @one = splice(@man,0,$onesection);
our @two = splice(@man,0,$onesection);
our @three = splice(@man,0,$onesection);
our @four = @man;


print "genelist begin\n";
our $thread_0_01 = threads->create('genelist', @one);
our $thread_0_02 = threads->create('genelist', @two);
our $thread_0_03 = threads->create('genelist', @three);
our $thread_0_04 = threads->create('genelist', @four);


$thread_0_01->join();
$thread_0_02->join();
$thread_0_03->join();
$thread_0_04->join();

print "genelist end\n";


our %genenum;
our %numgene;

my $genelisti = 0;
my @genelistallkey = keys(%genelist);
@genelistallkey = sort(@genelistallkey);

for my $oneunit (@genelistallkey) {


	$genelisti += 1;
	$genenum{$oneunit} = $genelisti;
	$numgene{$genelisti} = $oneunit;

}

our $totalgenenum = scalar @genelistallkey;
undef(%genelist);

print "mandeal begin\n";

our $thread_1_01 = threads->create('mandeal', @one);
our $thread_1_02 = threads->create('mandeal', @two);
our $thread_1_03 = threads->create('mandeal', @three);
our $thread_1_04 = threads->create('mandeal', @four);


$thread_1_01->join();
$thread_1_02->join();
$thread_1_03->join();
$thread_1_04->join();

print "mandeal end\n";

our $citefpkm = \%fpkm;
our $citefpkmuq = \%fpkmuq;
our $citecount = \%count;
our $citemirna = \%mirna;


print "output begin\n";
our $thread_2_01 = threads->create('gctoutput', ("fpkm", $citefpkm) );
our $thread_2_02 = threads->create('gctoutput', ("fpkmuq", $citefpkmuq) );
our $thread_2_03 = threads->create('gctoutput', ("count", $citecount) );
our $thread_2_04 = threads->create('gctoutput', ("mirna", $citemirna) );

$thread_2_01->join();
$thread_2_02->join();
$thread_2_03->join();
$thread_2_04->join();


print "output end\n";

###system "rm -rf cache/getgct/getgctfourtemp"; #done by hands.



sub genelist {

	my $mandeali = 1;
	
	#print "genelist\n";
	for my $singleman (@_) {

		
		my @manarray = split(/\t/, $singleman);

		my $filepath;
		my $filetype;
		
		my $filepath0 = "data/alldata/$manarray[0]/$manarray[1]";
		$filepath0 =~ s/\.gz//g;
		$filepath = $filepath0;
			
		unless (open IN, "$filepath") {
			print "no file: $filepath\n";
			next;	
		}

		my $inini = 0;
		while (my $dataone = <IN>) {
			$inini += 1;
			
			next if $inini <= 1;
			my $gene;

			$gene = (split(/\t/, $dataone))[0];
			
			unless (exists($genelist{$gene})) {
				$genelist{$gene} = 1;
			}
		}
		close IN;

	}

}	


sub mandeal {

	my $mandeali = 1;
	

	for my $singleman (@_) {

		my @manarray = split(/\t/, $singleman);

		my $filepath;
		my $filetype;
		my $sample;
		if (exists($cli{$manarray[0]})) {
			$sample = $cli{$manarray[0]};
		}
		my $localkeyone;
		my $systemcommand = 'nouse';
		if ($manarray[1] =~ m/FPKM\.txt\.gz/) {
	
			my $filepath0 = "data/alldata/$manarray[0]/$manarray[1]";
			$filepath0 =~ s/\.gz//g;
			$filepath = $filepath0;			
			$filetype = 'fpkm';
			$localkeyone = "$filetype-$sample";
			if (exists($existingsam{$localkeyone})){
				
				if ($existingsam{$localkeyone} eq 'nanana') {
					$localkeyone = "$localkeyone--$manarray[0]";
				}else{
					delete($fpkm{$localkeyone});
					my $reallykey = "$localkeyone"."--$existingsam{$localkeyone}";
					$systemcommand = "\\cp -f cache/getgct/getgctfourtemp/"."$localkeyone".".txt cache/getgct/getgctfourtemp/$reallykey.txt";
					$fpkm{$reallykey} = 1;
					$localkeyone = "$localkeyone--$manarray[0]";
					$existingsam{$localkeyone} = 'nanana';

				}
		
			
			}else{
				$existingsam{$localkeyone} = "$manarray[0]";
			}
			$fpkm{$localkeyone} = 1;

	
		}elsif($manarray[1] =~ m/mirnas\.quantification\.txt/) {
	
			$filepath = "data/alldata/$manarray[0]/$manarray[1]";
			$filetype = 'mirna';
			$localkeyone = "$filetype-$sample";
			if (exists($existingsam{$localkeyone})){
				
				if ($existingsam{$localkeyone} eq 'nanana') {
					$localkeyone = "$localkeyone--$manarray[0]";
				}else{
					delete($mirna{$localkeyone});
					my $reallykey = "$localkeyone"."--$existingsam{$localkeyone}";
					$systemcommand = "\\cp -f cache/getgct/getgctfourtemp/"."$localkeyone".".txt cache/getgct/getgctfourtemp/$reallykey.txt";
					$mirna{$reallykey} = 1;
					$localkeyone = "$localkeyone--$manarray[0]";
					$existingsam{$localkeyone} = 'nanana';

				}
		
			
			}else{
				$existingsam{$localkeyone} = "$manarray[0]";
			}
			$mirna{$localkeyone} = 1;
	
		}elsif($manarray[1] =~ m/FPKM-UQ\.txt\.gz/){
	
			my $filepath0 = "data/alldata/$manarray[0]/$manarray[1]";
			$filepath0 =~ s/\.gz//g;
			$filepath = $filepath0;			 
			$filetype = 'fpkmuq';
			$localkeyone = "$filetype-$sample";
			if (exists($existingsam{$localkeyone})){
				
				if ($existingsam{$localkeyone} eq 'nanana') {
					$localkeyone = "$localkeyone--$manarray[0]";
				}else{
					delete($fpkmuq{$localkeyone});
					my $reallykey = "$localkeyone"."--$existingsam{$localkeyone}";
					$systemcommand = "\\cp -f cache/getgct/getgctfourtemp/"."$localkeyone".".txt cache/getgct/getgctfourtemp/$reallykey.txt";
					$fpkmuq{$reallykey} = 1;
					$localkeyone = "$localkeyone--$manarray[0]";
					$existingsam{$localkeyone} = 'nanana';

				}
		
			
			}else{
				$existingsam{$localkeyone} = "$manarray[0]";
			}
			$fpkmuq{$localkeyone} = 1;
	
				
		}elsif($manarray[1] =~ m/counts\.gz/){
	
			my $filepath0 = "data/alldata/$manarray[0]/$manarray[1]";
			$filepath0 =~ s/\.gz//g;
			$filepath = $filepath0;
			$filetype = 'count';
			$localkeyone = "$filetype-$sample";
			if (exists($existingsam{$localkeyone})){
				
				if ($existingsam{$localkeyone} eq 'nanana') {
					$localkeyone = "$localkeyone--$manarray[0]";
				}else{
					delete($count{$localkeyone});
					my $reallykey = "$localkeyone"."--$existingsam{$localkeyone}";
					$systemcommand = "\\cp -f cache/getgct/getgctfourtemp/"."$localkeyone".".txt cache/getgct/getgctfourtemp/$reallykey.txt";
					$count{$reallykey} = 1;
					$localkeyone = "$localkeyone--$manarray[0]";
					$existingsam{$localkeyone} = 'nanana';

				}
		
			
			}else{
				$existingsam{$localkeyone} = "$manarray[0]";
			}
			$count{$localkeyone} = 1;
			
		
		}else{
			print "First place:unknown file type $manarray[1].\t";
		}

		open IN, "$filepath" or die "$filepath\n";
		

		my $inini = 0;
		my %genecontent;
		
		my %trouble;
		while (my $dataone = <IN>) {
			$inini += 1;
			next if $inini <= 1;
			my $gene;
			my $number;
			if ($filetype eq 'mirna') {
				$gene = (split(/\t/, $dataone))[0];
				$number = (split(/\t/, $dataone))[1];
			}else{
				$gene = (split(/\t/, $dataone))[0];
				$number = (split(/\t/, $dataone))[1];
			}
			
			my $geneid;
			if (exists($genenum{$gene})) {
				$geneid = $genenum{$gene};

			}else{

				die "impossible gene: $gene!!!!\n";
				next;
			}
			#$number = sprintf "%.3f", $number;
			chomp($number);
			
			if (exists($genecontent{$geneid})) {

				die "TCGA have errors: $gene :: $filepath\n";
				next;
				if (exists($trouble{$gene})) {
					$trouble{$gene} += 1;
				}else{
					$trouble{$gene} = 2;
				}
				$genecontent{$geneid} = ($number + (($trouble{$gene} - 1)*$genecontent{$geneid})) / $trouble{$gene};
			}else{
				$genecontent{$geneid} = $number;
			}

			###
			###
			###
			if (($filetype eq 'mirna') && ($gene eq "ENSG00000000003.13")){
				print "$pos1\t$geneid\t$genecontent{$geneid}\n";
			}
			###
			###
			###

		}

		close IN;
		open TEMP, '>', "cache/getgct/getgctfourtemp/$localkeyone.txt" or die;
		for (my $var = 1; $var <= $totalgenenum; $var++) {
			
			my $outputnum;
			if (exists($genecontent{$var})) {
				$outputnum = $genecontent{$var};
			}else{
				$outputnum = 0;
			}
			print TEMP "$outputnum\n";

		}
		close TEMP;
		if ($systemcommand ne 'nouse') {
			sleep(20);
			system "$systemcommand";
		}
		$mandeali += 1;

	}

}	


sub gctoutput {
	my $thistype = $_[0];
	my $thiscite = $_[1];
	my %thishash = %{$thiscite};
	my @thishashallkey = keys(%thishash);
	@thishashallkey = sort(@thishashallkey);

	my $sampleoneii = 0;
	for my $sampleone (@thishashallkey) {
		$sampleoneii += 1;
		open AFILE, "cache/getgct/getgctfourtemp/$sampleone.txt" or die;
		open TEMPFILE, '>', "cache/getgct/getgctfourtemp/getgct4temp$thistype.txt" or die;
		open TEMPTT, "cache/getgct/getgctfourtemp/getgct4temp$thistype.gctt" or die unless $sampleoneii == 1;
		my $gcoutput3 = 0;
		while (my $aline = <AFILE>) {
			$gcoutput3 += 1;
			
			if ($sampleoneii == 1) {
				chomp($aline);
				my $wholeoutput = "$aline\n";
				print TEMPFILE "$wholeoutput";
			}else{
				my $wholeline = <TEMPTT>;
				chomp($wholeline);
				chomp($aline);
				my $wholeoutput = "$wholeline\t$aline\n";
				print TEMPFILE "$wholeoutput";
			}
			
		}
		#print "total num is $gcoutput3\n";
		close AFILE;
		close TEMPTT;
		close TEMPFILE;
		system "\\cp -f cache/getgct/getgctfourtemp/getgct4temp$thistype.txt cache/getgct/getgctfourtemp/getgct4temp$thistype.gctt";
		
	
	}
	open TEMP, '>', "result/$thistype.gct" or die;
	print TEMP "Name\tDescription";
	for my $sampleone  (@thishashallkey) {
		my $tdiao = "$thistype".'-';
		$sampleone =~ s/$tdiao//;
		print TEMP "\t$sampleone";
	}

	print TEMP "\n";
	open TEMPT, "cache/getgctfourtemp/getgct4temp$thistype.gctt" or die;
	my $alinei = 0;
	while (my $wholeline = <TEMPT>) {
		$alinei += 1;

		my $genename = $numgene{$alinei};
		print TEMP "$genename\t$genename\t";
		print TEMP "$wholeline";
	}
	close TEMPT;
	close TEMP;
	return 1;
}


=pod
if (exists($existingsam{$samthis})) {
		if ($existingsam{$samthis} eq 'nanana') {
			$key = "$key--$samthis";
			$cli{$key} = $samthis;
		}else{
			$key = "$key--$samthis";
			$cli{$key} = $samthis;
			$cli{$existingsam{$samthis}} = "$cli{$existingsam{$samthis}}--$existingsam{$samthis}";
			$existingsam{$samthis} = 'nanana';
		}
		
	}else{s