#!/usr/bin/env perl

#==============================================================================
# sh.t
# File ID: c22bbf3c-ae3e-11e6-8a6c-279c2a0468a3
#
# Test suite for sh(1).
#
# Character set: UTF-8
# ©opyleft 2016– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of file for 
# legal stuff.
#==============================================================================

use strict;
use warnings;

BEGIN {
	use Test::More qw{no_plan};
	# use_ok() goes here
}

use Getopt::Long;

local $| = 1;

our $CMD_BASENAME = "sh";
our $CMD = "../$CMD_BASENAME";

our %Opt = (

	'all' => 0,
	'help' => 0,
	'quiet' => 0,
	'todo' => 0,
	'verbose' => 0,
	'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.0.0';

my %descriptions = ();

Getopt::Long::Configure('bundling');
GetOptions(

	'all|a' => \$Opt{'all'},
	'help|h' => \$Opt{'help'},
	'quiet|q+' => \$Opt{'quiet'},
	'todo|t' => \$Opt{'todo'},
	'verbose|v+' => \$Opt{'verbose'},
	'version' => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'verbose'} -= $Opt{'quiet'};
$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
	print_version();
	exit(0);
}

exit(main());

sub main {
	my $Retval = 0;

	diag(sprintf('========== Executing %s v%s ==========',
	             $progname, $VERSION));

	if ($Opt{'todo'} && !$Opt{'all'}) {
		goto todo_section;
	}

	test_standard_options();

	todo_section:
	;

	if ($Opt{'all'} || $Opt{'todo'}) {
		diag('Running TODO tests...');
		TODO: {
			local $TODO = '';
			# Insert TODO tests here.
		}
	}

	diag('Testing finished.');

	return $Retval;
}

sub test_standard_options {
	diag('Testing -h (--help) option...');
	likecmd("$CMD -h",
	        '/  Show this help/i',
	        '/^$/',
	        0,
	        'Option -h prints help screen');
	likecmd("$CMD --help",
	        '/  Show this help/i',
	        '/^$/',
	        0,
	        'Option --help prints help screen');

	diag('Testing -v (--verbose) option...');
	likecmd("$CMD -h -v",
	        '/^\n\S+ \d+\.\d+\.\d+/s',
	        '/^$/',
	        0,
	        'Option -h with -v returns version number and help screen');

	diag('Testing --version option...');
	likecmd("$CMD -h --verbose",
	        '/^\n\S+ \d+\.\d+\.\d+/s',
	        '/^$/',
	        0,
	        'Option -h with --verbose returns version number and help screen');
	likecmd("$CMD --help --verbose",
	        '/^\n\S+ \d+\.\d+\.\d+/s',
	        '/^$/',
	        0,
	        'Option --help with --verbose returns version number and help screen');
	likecmd("$CMD -v --help",
	        '/^\n\S+ \d+\.\d+\.\d+/s',
	        '/^$/',
	        0,
	        'Option -v with --help returns version number and help screen');

	diag('Testing --version option...');
	likecmd("$CMD --version",
	        '/^\S+ \d+\.\d+\.\d+/',
	        '/^$/',
	        0,
	        'Option --version returns version number');
	likecmd("$CMD --version --help",
	        '/^\S+ \d+\.\d+\.\d+/',
	        '/^$/',
	        0,
	        'Option --version --help returns version number');
	diag("Unknown options and arguments");
	testcmd("$CMD -U",
	        "",
	        "STDfilenameDTS: -U: Unknown option\n",
	        1,
	        'Unknown short option');
	testcmd("$CMD --unknown",
	        "",
	        "STDfilenameDTS: --unknown: Unknown option\n",
	        1,
	        'Unknown long option');
	testcmd("$CMD blabla",
	        "",
	        "",
	        0,
	        'Accepts non-option argument');
	testcmd("$CMD -- -U",
	        "",
	        "",
	        0,
	        'Unknown options after -- are ignored');
	testcmd("$CMD blabla -U",
	        "",
	        "",
	        0,
	        'Unknown options after first non-option are ignored');
	return;
}

sub testcmd {
	my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
	defined($descriptions{$Desc}) &&
		BAIL_OUT("testcmd(): '$Desc' description is used twice");
	$descriptions{$Desc} = 1;
	my $stderr_cmd = '';
	my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
	my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
	my $TMP_STDERR = "$CMD_BASENAME-stderr.tmp";
	my $retval = 1;

	if (defined($Exp_stderr)) {
		$stderr_cmd = " 2>$TMP_STDERR";
	}
	$retval &= is(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
	my $ret_val = $?;
	if (defined($Exp_stderr)) {
		$retval &= is(file_data($TMP_STDERR),
		              $Exp_stderr, "$Txt (stderr)");
		unlink($TMP_STDERR);
	} else {
		diag("Warning: stderr not defined for '$Txt'");
	}
	$retval &= is($ret_val >> 8, $Exp_retval, "$Txt (retval)");

	return $retval;
}

sub likecmd {
	my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
	defined($descriptions{$Desc}) &&
		BAIL_OUT("likecmd(): '$Desc' description is used twice");
	$descriptions{$Desc} = 1;
	my $stderr_cmd = '';
	my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
	my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
	my $TMP_STDERR = "$CMD_BASENAME-stderr.tmp";
	my $retval = 1;

	if (defined($Exp_stderr)) {
		$stderr_cmd = " 2>$TMP_STDERR";
	}
	$retval &= like(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
	my $ret_val = $?;
	if (defined($Exp_stderr)) {
		$retval &= like(file_data($TMP_STDERR),
		                $Exp_stderr, "$Txt (stderr)");
		unlink($TMP_STDERR);
	} else {
		diag("Warning: stderr not defined for '$Txt'");
	}
	$retval &= is($ret_val >> 8, $Exp_retval, "$Txt (retval)");

	return $retval;
}

sub file_data {
	# Return file content as a string
	my $File = shift;
	my $Txt;

	open(my $fp, '<', $File) or return undef;
	local $/ = undef;
	$Txt = <$fp>;
	close($fp);
	return $Txt;
}

sub create_file {
	# Create new file and fill it with data
	my ($file, $text) = @_;
	my $retval = 0;

	open(my $fp, ">$file") or return 0;
	print($fp $text);
	close($fp);
	$retval = is(file_data($file), $text,
	             "$file was successfully created");

	return $retval; # 0 if error, 1 if ok
}

sub print_version {
	# Print program version
	print("$progname $VERSION\n");
	return;
}

sub usage {
	# Send the help message to stdout
	my $Retval = shift;

	if ($Opt{'verbose'}) {
		print("\n");
		print_version();
	}
	print(<<"END");

Usage: $progname [options]

Contains tests for the $CMD_BASENAME(1) program.

Options:

  -a, --all
    Run all tests, also TODOs.
  -h, --help
    Show this help.
  -q, --quiet
    Be more quiet. Can be repeated to increase silence.
  -t, --todo
    Run only the TODO tests.
  -v, --verbose
    Increase level of verbosity. Can be repeated.
  --version
    Print version information.

END
	exit($Retval);
}

sub msg {
	# Print a status message to stderr based on verbosity level
	my ($verbose_level, $Txt) = @_;

	$verbose_level > $Opt{'verbose'} && return;
	print(STDERR "$progname: $Txt\n");
	return;
}

__END__

# This program is free software; you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free Software 
# Foundation; either version 2 of the License, or (at your option) any later 
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with 
# this program.
# If not, see L<http://www.gnu.org/licenses/>.

# vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 :
