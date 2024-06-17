#!/usr/bin/perl -w

###This script will take as input a collection of output files from the GoFlag pipeline ("L*.afterMerge.mafft.oneline.fasta"), and it will create a corresponding set of phylip file ("L*.keep1.phy").  If a sample in any GoFlag pipeline output file had more than one sequence, the corresponding phylip file will select one sequence (the sequence with the most nucleotides) to represent that sample

@filearray = glob("L*.afterMerge.mafft.oneline.fasta");

for $file(@filearray)
{
    if ($file =~ m/L(\d+).afterMerge.mafft.oneline.fasta/)
    {
	$filenum = $1;
	open FH, "<$file";
	%lenhash = ();
	%seqhash = ();
	$numtax = 0;
	$fulllen = 0;
	while (<FH>)
	{
	    if (/^>(\S+)(\.+\d)/|/^>(\S+\__REF)/)
	    
	    #original
	    #if (/^>(\S+)/)
	    {
		$name = $1;
		if (! exists $lenhash{$name})
		{
		    $lenhash{$name} = 0;
		    $numtax++;
		}
	    }
	    elsif (/^(\S+)/)
	    {
		$seq = $1;
		$fulllen = length $seq;
		$nuc = $seq;
		$nuc =~ s/\-//g;
		$len = length $nuc;
		if ($len > $lenhash{$name})
		{
		    $lenhash{$name} = $len;
		    $seqhash{$name} = $seq;
		}
	    }
	}
	close FH;

	if ($numtax > 3)
	{
	    open OUT, ">L$filenum.keep1.phy";
	    print OUT "$numtax $fulllen\n";
	    for $SEQ(keys %seqhash)
	    {
		print OUT "$SEQ\t$seqhash{$SEQ}\n";
	    }
	    close OUT;
	}
    }
}

	    
