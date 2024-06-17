#!/usr/bin/perl -w

#This script opens all *.keep1.phy files in a directory - e.g., the output of keepone.pl
#It prunes all of these alignments to remove columns with less that $minnum nucleotides.  In other words, it prunes out columns in the alignment with a lot of missing data. The output file called *.prune.nex

#The variable $minnum is the minimum amount of nucleotides required to keep a column.  You can alter that by changing $minnum below. 
#Also in the following line, change *keep1.phy to *nodups.phy if you ran rmall.pl instead of keepone.pl. 

$minnum = 10;

system "ls -l *nodups.ED.phy >filenames";

open FHx, "<filenames";

while (<FHx>)
{

#open each nexus file
    if (/(\S+).phy/ && ! /prune/)
    {
	$file = $1;
	print "$file\n";
	open FH, "<$file.phy";
	$ok = 0;
	%columnhash = ();

#Read through the nexus file
#count number of a,c,g, or t characters in each column
	while (<FH>)
	{
	    if (/^(\d+)\s+(\d+)/)
	    {
		$numtax = $1;
		$nchar = $2;
		$ok++;
	    }


	    elsif (/^\S+\s+(\S+)/ && $ok > 0)
	    {
		$seq = $1;
#turning each sequence into an array of characters
		@seqarray = split('',$seq);
		$char = 0;
		for $nuc(@seqarray)
		{
		    $char++;
#I have a hash- the keys are the column numbers.  The values are the number of times an a,c,g, or t is in the column.
		    if ($nuc =~ m/[A-Z]/)
		    {
			$columnhash{$char}++;
		    }
		}
	    }
	}
	close FH;

#now I will count how many alignment columns characters meet minimum requirement

	$keepchars = 0;

	for (1..$nchar)
	{
	    $count = $_;
	    if (exists $columnhash{$count})
	    {
		if ($columnhash{$count} >= $minnum)
		{
		    $keepchars++;
		}
	    }
	}

#now i will open a new nexus file for the pruned data
#I will print only the columns with data in more than $minpercent of the cells
	if ($keepchars > 0)
	{
	    open FH2, "<$file.phy";
	    open OUT, ">$file.prune.phy";
	    print OUT "$numtax $keepchars\n";

	    while (<FH2>)
	    {
		if (/^(\S+)\s+(\S+)/ && ! /^\d+/)
		{
		    $TAX = $1;
		    $SEQ = $2;
		    print OUT "$TAX\t";
		    @SEQARRAY = split('',$SEQ);
		    $NUM = 0;
		    for $NUC(@SEQARRAY)
		    {
			$NUM++;
			if (exists $columnhash{$NUM})
			{
			    if ($columnhash{$NUM} >= $minnum)
			    {
				print OUT "$NUC";
			    }
			}
		    }
		    print OUT "\n";
		}
	    }
	    close FH2;
	    close OUT;
	}
    }
}

	    
