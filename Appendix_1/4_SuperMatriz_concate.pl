#!/usr/bin/perl -w

#This script takes all the phylip files ending in *prune.phy (i.e., the output of filtermissing.pl), and concatenates them into a supermatrix 
#You can change the glob function below to read in the names of different phylip files you want to concatenate
#change the names of the 2 output files- the supermatrix file and the gene boundaries file- below

@filearray = glob("L*.nodups.ED.prune.phy");
open OUT1, ">Locis_95taxaHornw_ConcateFull.phy";
open OUT2, ">Locis_95taxaHornw_ConcateFull_LocisBoundaries.txt";

%taxhash = ();
$numtax = 0;
$totallen = 0;

for $file(@filearray)
{
    open FH, "<$file";
    while (<FH>)
    {
	if (/^\d+\s+(\d+)/)
	{
	    $totallen = $totallen + $1;
	}
	elsif (/^(\S+)\s+\S+/)
	{
	    $tax = $1;
	    if (! exists $taxhash{$tax})
	    {
		$taxhash{$tax} = "";
		$numtax++;
	    }
	}
    }
    close FH;
}

print OUT1 "$numtax $totallen\n";
$start = 0;
$end = 0;

for $file(@filearray)
{
    open FH2, "<$file";
    print "working on $file\n";
    %genehash = ();
    while (<FH2>)
    {
	if (/^\d+\s+(\d+)/)
	{
	    $Len = $1;
	    $start = $end + 1;
	    $end = $end + $Len;
	    print OUT2 "$file\t$start\-$end\n";
	}
	elsif (/^(\S+)\s+(\S+)/)
	{
	    $genehash{$1} = $2;
	}
    }
    close FH2;

    for $TAX(keys %taxhash)
    {
	if (exists $genehash{$TAX})
	{
	    $taxhash{$TAX} = $taxhash{$TAX} . $genehash{$TAX};
	}
	else
	{
	    for (1..$Len)
	    {
		$taxhash{$TAX} = $taxhash{$TAX} . "-";
	    }
	}
    }
}

for $TAX(keys %taxhash)
{
    print OUT1 "$TAX\t$taxhash{$TAX}\n";
}
close OUT1;
close OUT2;
