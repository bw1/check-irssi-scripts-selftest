use strict;
use warnings;
use YAML qw/LoadFile DumpFile/;
use Irssi;

use vars qw($VERSION %IRSSI);
$VERSION = '0.1';
%IRSSI = (
    authors     => 'bw1',
    contact     => 'bw1@aol.at',
    name        => 'selfcheckhelperscript',
    description => 'helper script for self test',
    license     => 'GPLv2',
    url         => 'http://scripts.irssi.org/',
    changed     => $VERSION,
);

my $CURRENT_SCRIPT = $ENV{CURRENT_SCRIPT};
my (%info, $version, @commands);

sub myquit {
	my ( $s )=@_;
	Irssi::print("Selfcheck: ".$s, MSGLEVEL_CRAP);
	$info{selfcheckresult}=$s;
	DumpFile("info.yaml", \%info);
	Irssi::command('quit');
}

sub cmd {
	my ($args, $server, $witem)=@_;
	myquit( $args );
}

Irssi::command_bind($IRSSI{name},\&cmd);

Irssi::print("Selfcheck: perl_version: $^V", MSGLEVEL_CRAP);
#Irssi::print("Selfcheck: perl_inc:", MSGLEVEL_CRAP);
#foreach my $l ( @INC ) {
#	Irssi::print("        $l", MSGLEVEL_CRAP);
#}

Irssi::print("Selfcheck: loadscript ($CURRENT_SCRIPT)", MSGLEVEL_CRAP);
Irssi::command("script load $CURRENT_SCRIPT");

Irssi::print("Selfcheck: get info", MSGLEVEL_CRAP);
%info = do { no strict 'refs'; %{"Irssi::Script::${CURRENT_SCRIPT}::IRSSI"} };
$version = do { no strict 'refs'; ${"Irssi::Script::${CURRENT_SCRIPT}::VERSION"} };
@commands = sort map { $_->{cmd} } grep { $_->{category} eq "Perl scripts' commands" } Irssi::commands;
$info{version}=$version;
$info{commands}= join " ", @commands;
Irssi::print("Selfcheck: script version: $version", MSGLEVEL_CRAP);
DumpFile("info.yaml", \%info);

myquit('-') unless (exists $info{selfcheckcmd} );


Irssi::print("Selfcheck: run self check ($info{selfcheckcmd})", MSGLEVEL_CRAP);
Irssi::command($info{selfcheckcmd});

Irssi::timeout_add_once(20000, \&myquit, 'Error: timeout');
