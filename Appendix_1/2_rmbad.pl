#!/usr/bin/perl -w

# I ran the script "rmbad.pl". This script reads in the sample names in the file "names_delet_test04.txt", which you provided - it removes # those samples from the files "L*.nodups.phy", and for the other sample names, it changes any periods "." to underscores "_". The output # files are named "L*.nodups.ED.phy".

open FH, "<names_delet_test04.txt";
%badhash = ();

while (<FH>)
{
    if (/^(\S+)/)
    {
	$badhash{$1} = 1;
    }
}
close FH;

@filearray = glob("*.nodups.phy");

for $file(@filearray)
{
    if ($file =~ m/(\S+).phy/)
    {
	$filename = $1;
	open FH2, "<$file";
	$numbad = 0;
	while (<FH2>)
	{
	    if (/^(\d+)\s+(\d+)/)
	    {
		$numtax = $1;
		$len = $2;
	    }
	    elsif (/^(\S+)/)
	    {
		$taxname = $1;
		if (exists $badhash{$taxname})
		{
		    $numbad++;
		    $numtax = $numtax - 1;
		}
	    }
	}
	close FH2;

	open FH3, "<$file";
	open OUT, ">$filename.ED.phy";
#	print "$file\n";

	while (<FH3>)
	{
	    if (/^\d+\s+\d+/)
	    {
	        print OUT "$numtax $len\n";
	    }
	    elsif (/^(\S+)\s+(\S+)/)
	    {
		$taxname = $1;
		$seq = $2;
		if (! exists $badhash{$taxname})
		{
		    $taxname =~ s/\./\_/g;
		    print OUT "$taxname\t$seq\n";
		}
	    }
	}
	close FH3;
	print OUT "\n";
	close OUT;

    }
}



