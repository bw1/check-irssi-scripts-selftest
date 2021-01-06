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

my $startup= <<'END';
^set settings_autosave off
^set use_status_window off
^set autocreate_windows off
^set -clear autocreate_query_level
^set autoclose_windows off
^set reuse_unused_windows on
^load perl
save
^script exec $$^W = 1
run "$W/testhelperscript.pl"
END

# ^set -clear log_close_string
# ^set -clear log_day_changed
# ^set -clear log_open_string
# ^set log_timestamp * 

rmtree $wp;
mkdir $wp;
mkdir "$wp/$configp/";
write_text("$wp/$configp/startup", $startup);
my $t;
$t="$wp/$configp/scripts";
`ln -s $wd/scripts.irssi.org/scripts/ $t`; #!!
$t="$wp/testhelperscript.pl";
`ln -s $wd/testhelperscript.pl $t`; #!!

chdir $wp;
$ENV{CURRENT_SCRIPT}='chansearch';
$ENV{TERM}='vt100';
if ( $debug > 0 ) {
	system("irssi", "--home=$configp");
} else {
	`nohup irssi --home=$configp 2>stderr.log`;
}
chdir $wd;

print "-------------\n";
system "cat", "$wp/info.yaml";
print "-------------\n";
system "cat", "$wp/selfcheck.log";
print "-------------\n";
system "cat", "$wp/stderr.log";
