#perl scripts/onestepoverlap-great.pl -g gencode.v28.gtf -m hsa.gff3 -o result/overlap-great.txt
use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_g $opt_m $opt_o);
getopts('g:m:o:');


my %usemirna;
my @usemirna0;

open REF, "$opt_m" or die;
while (<REF>) {


	s/\r//g;
	chomp;
	next if $_ =~ m/^#/;
	my ($chr, $type, $start, $end, $plus, $anno) = (split(/\t/, $_))[0,2,3,4,6,8];
	next if $type ne "miRNA_primary_transcript";
	my $name;
	my $id;
	if ($anno =~ m/ID=([^;]+);.*;Name=([^;]+)/) {
		$id = $1;
		$name = $2;
	}else{
		die "$anno\n";
	}
	if ($name =~ m/([^-]+)-([^-]+)-([^-]+)-([^-]+)/ ) {
		next;
	}
	$usemirna{$id} = 1;

}
close REF;


open REF, "$opt_m" or die;

while (<REF>) {


	s/\r//g;
	chomp;
	next if $_ =~ m/^#/;
	my ($chr, $type, $start, $end, $plus, $anno) = (split(/\t/, $_))[0,2,3,4,6,8];
	next if $type ne "miRNA";
	my $name;
	my $id;
	if ($anno =~ m/;Name=([^;]+);Derives_from=([^;]+)/) {
		$id = $2;
		$name = $1;
	}else{
		die "$anno\n";
	}
	
	push @usemirna0, "$chr\t$start\t$end\t$plus\t$name" if exists($usemirna{$id});

}
close REF;


my @genes;


my %count;
my %norepeat;
my %mirnagene;
my %genegene;


for my $onemirna (@usemirna0) {
	my ($chr2, $start2, $end2, $plus2, $name) = (split(/\t/, $onemirna))[0,1,2,3,4];
	if (exists($norepeat{$name})) {
		$norepeat{$name} = 'NA';
	}else{
		$norepeat{$name} = $onemirna;
	}

}
my @usemirna;

for my $onekey (keys(%norepeat)) {
	next if $norepeat{$onekey} eq 'NA';
	push @usemirna, $norepeat{$onekey};
}


open IN, "$opt_g" or die;
open OUT, '>', "$opt_o" or die;
while (<IN>) {
	s/\r//g;
	chomp;
	next if $_ =~ m/^#/;
	
	my ($chr, $type, $start, $end, $plus, $anno) = (split(/\t/, $_))[0,2,3,4,6,8];
	next if $type ne "gene";
	my $ensg;
	my $whemirna = 0;

	if ($anno =~ m/gene_id "([^"]+)"/) {
		$ensg = $1;
	}else{
		die "$anno\n";
	}
	if ($anno =~ m/gene_type "miRNA";/) {
		$whemirna = 1;
	}
	$ensg =~ s/\.(.*)$//g;
	for my $onemirna (@usemirna) {
		#print "$onemirna";
		my ($chr2, $start2, $end2, $plus2, $name) = (split(/\t/, $onemirna))[0,1,2,3,4];
		if ( ($chr2 eq $chr) && ($plus2 eq $plus)) {
			if (($start2 <= $end) && ($end2 >= $start)) {

				if ($whemirna == 0) {
					if (exists($genegene{$name})) {
						$genegene{$name} = 'NANA' ;
					}else{
						$genegene{$name} = "$name\t$ensg\n";
						$count{$name} = 1;
					}
				}
				if ($whemirna == 1) {
					if (exists($mirnagene{$name})) {
						$mirnagene{$name} = 'NANA' ;
					}else{
						$mirnagene{$name} = "$name\t$ensg\n";
						$count{$name} = 1;
					}
				}
				
			}
		}
	}
}

for my $countone (keys(%count)) {
	if (exists($genegene{$countone})) {
		next if $genegene{$countone} eq 'NANA';
		print OUT "$genegene{$countone}";
	}elsif(exists($mirnagene{$countone})) {
		next if $mirnagene{$countone} eq 'NANA';
		print OUT "$mirnagene{$countone}";
	}else{
		next;
	}
	
	
}

close OUT;

