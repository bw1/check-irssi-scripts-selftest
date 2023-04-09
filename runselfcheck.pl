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
my @scripts;
my $scrf= LoadFile('myscripts.yaml');
@scripts = @{ $scrf->{selfcheck} };

my $startup= <<'END';
log open selfcheck.log all
^set use_status_window off
^set autocreate_windows off
^set -clear autocreate_query_level
^set autoclose_windows off
^set reuse_unused_windows on
^set timestamp_format %H:%M:%S
^set log_timestamp %H:%M:%S
^set autolog_level all
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
print `irssi --version`;
print "perl_version: $^V\n";
print "\033[0;35m Run Tests: \033[0m\n";
#print "perl_inc:\n".join("\n", @INC)."\n";


my $result=0;
foreach my $scr ( @scripts ) {
	print "\033[0;36m $scr \033[0m";
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
	$ENV{CURRENT_SCRIPT}=$scr;
	$ENV{USER}='action';
	$ENV{TERM}='vt100';
	if ( $debug > 0 ) {
		system("irssi", "--home=$configp");
	} else {
		`screen -S test-scripts -d -m irssi --home=$configp`;
	}
	chdir $wd;
}
print "\n\nWait ...\n\n";

for( my $c=60; $c>=0; $c-= 5 ) {
	sleep 5;
	my $r =`screen -S test-scripts -ls`;
	last if ( $r=~ m/No Sockets found/);
}

foreach my $scr ( @scripts ) {
	print "\033[0;36m selfcheck $scr \033[0m";
	my $wp="tmp/$scr";

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
	print "----info------------------\n";
	system "cat", "$wp/info.yaml";
	print "----selfcheck-------------\n";
	system "cat", "$wp/selfcheck.log";
	$result=-1;
}

exit($result);
