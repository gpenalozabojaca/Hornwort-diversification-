#!/usr/bin/perl -w

#This script takes all the phylip files ending in *prune.phy (i.e., the output of filtermissing.pl), and concatenates them into a supermatrix 
#You can change the glob function below to read in the names of different phylip files you want to concatenate
#change the names of the 2 output files- the supermatrix file and the gene boundaries file- below

@filearrayx = glob("L*.ED.prune.phy");

%locushash = ();
for $filex(@filearrayx)
{
    if ($filex =~ m/L(\d+).nodups/)
    {
	$locushash{$1} = 1;
    }
}

#find out how many locus alignment files are there for each 1kp gene 
%genehash = ();
%matchhash = ();
open FHa, "<GFvs1kp.txt";

while(<FHa>)
{
    if (/^(\d+)\s+L(\d+)/)
    {
	$lnum = $1;
	$gnum = $2;
	if (exists $locushash{$lnum})
	{
	    if (! exists $genehash{$gnum})
	    {
		$genehash{$gnum} = 1;
		$matchhash{$gnum} = $lnum;
	    }
	    else {$genehash{$gnum}++;}
	}
    }
}
close FHa;


#For genes that only have 1 locus - rename locus file
%genehash2 = ();
for $G(keys %genehash)
{
    if ($genehash{$G} == 1)
    {
	system "cp L$matchhash{$G}.nodups.ED.prune.phy G$G.nodups.ED.prune.phy";
    }
    else {$genehash2{$G} = 1;}
}

####################

for $gene2(keys %genehash2)
{
    print "combining $gene2\n";
    @filearray = ();
    open FHb, "<GFvs1kp.txt";
    while (<FHb>)
    {
	if (/^(\d+)\s+L$gene2\_/)
	{
	    $Locus = $1;
	    if (exists $locushash{$Locus})
	    {
		push @filearray, "L$Locus.nodups.ED.prune.phy";
	    }
	}
    }
    close FHb;

    open OUT1, ">G$gene2.nodups.ED.prune.phy";
    open OUT2, ">G$gene2.nodups.ED.prune.GeneBoundaries.txt";

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
}
