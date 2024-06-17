#!/usr/bin/perl -w

#####SETUP#####

use strict;
use Getopt::Long;
use Pod::Usage;

my ($help, $indir, $config, $outdir);
GetOptions(
    'h|help'          => \$help,
    'i|indir=s'       => \$indir,
    'o|outdir=s'      => \$outdir,
    'c|config=s'      => \$config,
    ) or pod2usage;

pod2usage if $help;

for my $option ($indir, $outdir, $config){
    (warn ("Missing a required option\n") and pod2usage)
	unless ($option);
}

`mkdir -p $outdir/results`;
`mkdir -p $outdir/stderr`;

#####MAIN#####

# get the config
my $conf = parse_config ($config);

# do the raxml run for every aln
opendir (I, "$indir");
my @alns = sort (readdir (I));
shift @alns;
shift @alns;
closedir (I);

foreach my $aln (@alns){
    warn "RAXML $aln\n";
    raxml_run ($aln, $indir, $conf, $outdir);
}


#####SUBS#####

sub raxml_run{
    my $aln  = shift;
    my $in   = shift;
    my $conf = shift;
    my $out  = shift;

    # raxml
    my $raxml = "$conf->{RAXML}";
    ($raxml .= " $conf->{'PARAMETERS'}") if ($conf->{'PARAMETERS'});
    $raxml .= " -s $in/$aln";
    $raxml .= " -n $aln";
    $raxml .= " -w /project/jcvaguilar/users/labvilla/amsip1/Hornworts_GoFlag/Gabriel/Genes_RAXML_out/results";
    `$raxml &> $out/stderr/$aln.stderr`;
}

sub parse_config{
    my $file = shift;

    my %config;
    open (F, "$file");
    while (my $line = <F>){
        chomp $line;
        my ($key, $value) = split (/\=/, $line, 2);
        $config{$key} = $value;

    }
    close (F);

    return (\%config);
}
