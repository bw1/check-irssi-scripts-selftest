use strict;
use warnings;
use YAML::XS qw/LoadFile DumpFile/;
use Irssi;

use vars qw($VERSION %IRSSI);
$VERSION = '0.1';
%IRSSI = (
    authors     => 'bw1',
    contact     => 'bw1@aol.at',
    name        => 'testhelperscript',
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

Irssi::print("Selfcheck: startlog", MSGLEVEL_CRAP);
Irssi::command('^window log on selfcheck.log');
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

Irssi::signal_register({
	"selfcheckstop" => [ qw/string/ ]
	});
Irssi::signal_add("selfcheckstop", \&myquit);

Irssi::print("Selfcheck: run self check ($info{selfcheckcmd})", MSGLEVEL_CRAP);
Irssi::command($info{selfcheckcmd});

#Irssi::timeout_add_once(20000, \&myquit, 'Error: timeout');
