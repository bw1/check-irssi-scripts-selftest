#!/usr/bin/perl
#
#  scanns for modules
#
use strict;
use YAML qw/Dump DumpFile LoadFile/;
use File::Slurper qw/read_text/;
use Perl::PrereqScanner;
use CPAN::Meta::Requirements;
use Module::CoreList;

my $p= "scripts.irssi.org/scripts";
my %smod;

sub modscanner {
	my ( $filename ) = @_;
	my $prereq_results = 
		Perl::PrereqScanner->new->scan_file($filename);
	my %mo= %{$prereq_results->as_string_hash()};
	my @moduls = keys %mo;
	@moduls = grep { $_ !~ m/^Irssi/ } @moduls;
	@moduls = grep { !Module::CoreList->first_release($_) } @moduls;
	@moduls = grep { $_=~ m/^[[:upper:]]/ } @moduls;
	map { $smod{$_}=1 } @moduls;
	return @moduls;
}

modscanner("runselfcheck.pl");
modscanner("selfcheckhelperscript.pl");

opendir my $di, $p;
my @dl = readdir $di;
closedir $di;
@dl= grep { $_=~m/\.pl$/ } @dl;

my %scr;
foreach my $fn ( @dl ) {
	my $sn = $fn;
	next unless ( -e "$p/$fn" );
	$sn =~ s/\.pl//;
	$scr{$sn}->{filename}= $sn;

	my $ft= read_text("$p/$fn",":latin1");
	if ( $ft =~ m/selfcheckcmd/ ) {
		$scr{$sn}->{selfcheck}= 1;
		$scr{$sn}->{moduls}= 
			[modscanner("$p/$fn")];
	}
}

my $scrf = (
	'scripts' => { %scr},
);

DumpFile('myscripts.yaml', $scrf);

#print join( "\n", keys %smod),"\n";

foreach my $pa ( keys %smod ) {
	system('sudo cpanm --quiet '.$pa);
}


