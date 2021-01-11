#!/usr/bin/perl
#
#  run self check
#
use strict;
use YAML qw/DumpFile LoadFile/;
use File::Slurper qw/read_text write_text/;
use File::Path qw/make_path rmtree/;
use Cwd;

my $wd= getcwd(); 
my $wp= "tmp";
my $configp= "irssi_config";
my $debug=0;
my @scripts= qw/chansearch shorturl imdb ontv2/;

my $startup= <<'END';
^set ignore_signals int quit term alrm usr1 usr2
^set use_status_window off
^set autocreate_windows off
^set -clear autocreate_query_level
^set autoclose_windows off
^set reuse_unused_windows on
^load perl
save
^script exec $$^W = 1
run "$W/selfcheckhelperscript.pl"
END

# ^set settings_autosave off
# ^set -clear log_close_string
# ^set -clear log_day_changed
# ^set -clear log_open_string
# ^set log_timestamp * 

my $result=0;
foreach my $scr ( @scripts ) {
	print "selfcheck $scr";
	my $wp="tmp/$scr";
	rmtree $wp;
	make_path "$wp/$configp/";
	write_text("$wp/$configp/startup", $startup);
	my $t;
	$t="$wp/$configp/scripts";
	`ln -s $wd/scripts.irssi.org/scripts/ $t`; #!!
	$t="$wp/selfcheckhelperscript.pl";
	`ln -s $wd/selfcheckhelperscript.pl $t`; #!!

	chdir $wp;
	$ENV{CURRENT_SCRIPT}='chansearch';
	$ENV{USER}='action';
	$ENV{TERM}='vt100';
	if ( $debug > 0 ) {
		system("irssi", "--home=$configp");
	} else {
		`irssi --home=$configp 2>stderr.log`;
	}
	chdir $wd;


	my ($info, $ires);
	if ( -e "$wp/info.yaml" ) {
		$info= LoadFile("$wp/info.yaml");
		$ires= $info->{selfcheckresult};
		if ( $ires eq 'ok' ) {
			print " $ires\n";
			next;
		}
	} 

	print " $ires\n";
	print "-------------\n";
	system "cat", "$wp/info.yaml";
	print "-------------\n";
	system "cat", "$wp/selfcheck.log";
	print "-------------\n";
	system "cat", "$wp/stderr.log";
	$result=-1;
}

exit($result);
