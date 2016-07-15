#!/usr/bin/env perl

#=======================================================================
# sortxml.t
# File ID: 8c064bc0-1463-11de-b31f-000475e441b9
#
# Test suite for sortxml(1).
#
# Character set: UTF-8
# ©opyleft 2009– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;

BEGIN {
    use Test::More qw{no_plan};
    # use_ok() goes here
}

use Getopt::Long;

local $| = 1;

our $CMD_BASENAME = "sortxml";
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
our $VERSION = '0.1.0';

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
    # {{{
    my $Retval = 0;

    diag(sprintf('========== Executing %s v%s ==========',
        $progname,
        $VERSION));

    if ($Opt{'todo'} && !$Opt{'all'}) {
        goto todo_section;
    }

=pod

    testcmd("$CMD command", # {{{
        <<'END',
[expected stdout]
END
        '',
        0,
        'description',
    );

    # }}}

=cut

    diag('Testing -h (--help) option...');
    likecmd("$CMD -h", # {{{
        '/  Show this help/i',
        '/^$/',
        0,
        'Option -h prints help screen',
    );

    # }}}
    diag('Testing -v (--verbose) option...');
    likecmd("$CMD -hv", # {{{
        '/^\n\S+ \d+\.\d+\.\d+/s',
        '/^$/',
        0,
        'Option -v with -h returns version number and help screen',
    );

    # }}}
    diag('Testing --version option...');
    likecmd("$CMD --version", # {{{
        '/^\S+ \d+\.\d+\.\d+/',
        '/^$/',
        0,
        'Option --version returns version number',
    );

    # }}}
    diag("Test sorting...");
    testcmd("$CMD -s b sortxml-files/a.xml", # {{{
        <<END,
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE a [
<!ELEMENT a (b)+>
<!ELEMENT b (c , d?)>
<!ELEMENT c (#PCDATA)>
<!ELEMENT d (#PCDATA)>
]>
<a>
  <b>
    <c>abc</c>
    <d>dsfv</d>
  </b>
  <b>
    <c>add</c>
  </b>
  <b>
    <c>ba</c>
  </b>
  <b>
    <c>bbb</c>
    <d>gurgle</d>
  </b>
  <b>
    <c>bbb</c>
    <d>gurgle</d>
  </b>
  <b>
    <c>ggg</c>
    <d>fgh</d>
  </b>
  <b>
    <c>ggg</c>
    <d>pdfg</d>
  </b>
  <b>
    <c>zsd</c>
  </b>
</a>
END
        "",
        0,
        "Sorting XML document",
    );

    # }}}
    testcmd("$CMD -s b sortxml-files/oneliners.xml", # {{{
        <<END,
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE a [
<!ELEMENT a (b)+>
<!ELEMENT b (c , d?)>
<!ELEMENT c (#PCDATA)>
<!ELEMENT d (#PCDATA)>
]>
<a>
  <b> <c>abc</c> <d>dsfv</d> </b>
  <b> <c>add</c> </b>
  <b> <c>ba</c> </b>
  <b> <c>bbb</c> <d>gurgle</d> </b>
  <b> <c>ggg</c> <d>fgh</d> </b>
  <b> <c>ggg</c> <d>pdfg</d> </b>
  <b> <c>zsd</c> </b>
</a>
END
        "",
        0,
        "XML uses oneliners",
    );

    # }}}
    diag("Test reverse sorting...");
    testcmd("$CMD -s b -r sortxml-files/a.xml", # {{{
        <<END,
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE a [
<!ELEMENT a (b)+>
<!ELEMENT b (c , d?)>
<!ELEMENT c (#PCDATA)>
<!ELEMENT d (#PCDATA)>
]>
<a>
  <b>
    <c>zsd</c>
  </b>
  <b>
    <c>ggg</c>
    <d>pdfg</d>
  </b>
  <b>
    <c>ggg</c>
    <d>fgh</d>
  </b>
  <b>
    <c>bbb</c>
    <d>gurgle</d>
  </b>
  <b>
    <c>bbb</c>
    <d>gurgle</d>
  </b>
  <b>
    <c>ba</c>
  </b>
  <b>
    <c>add</c>
  </b>
  <b>
    <c>abc</c>
    <d>dsfv</d>
  </b>
</a>
END
        "",
        0,
        "Reverse sort XML document",
    );

    # }}}
    testcmd("$CMD -s b -r sortxml-files/oneliners.xml", # {{{
        <<END,
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE a [
<!ELEMENT a (b)+>
<!ELEMENT b (c , d?)>
<!ELEMENT c (#PCDATA)>
<!ELEMENT d (#PCDATA)>
]>
<a>
  <b> <c>zsd</c> </b>
  <b> <c>ggg</c> <d>pdfg</d> </b>
  <b> <c>ggg</c> <d>fgh</d> </b>
  <b> <c>bbb</c> <d>gurgle</d> </b>
  <b> <c>ba</c> </b>
  <b> <c>add</c> </b>
  <b> <c>abc</c> <d>dsfv</d> </b>
</a>
END
        "",
        0,
        "Reverse sort onelined XML",
    );

    # }}}
    diag('Testing -u (--unique) option...');
    testcmd("$CMD -s b -u sortxml-files/a.xml", # {{{
        <<END,
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE a [
<!ELEMENT a (b)+>
<!ELEMENT b (c , d?)>
<!ELEMENT c (#PCDATA)>
<!ELEMENT d (#PCDATA)>
]>
<a>
  <b>
    <c>abc</c>
    <d>dsfv</d>
  </b>
  <b>
    <c>add</c>
  </b>
  <b>
    <c>ba</c>
  </b>
  <b>
    <c>bbb</c>
    <d>gurgle</d>
  </b>
  <b>
    <c>ggg</c>
    <d>fgh</d>
  </b>
  <b>
    <c>ggg</c>
    <d>pdfg</d>
  </b>
  <b>
    <c>zsd</c>
  </b>
</a>
END
        "",
        0,
        "Duplicated <b> removed",
    );

    # }}}

    todo_section:
    ;

    if ($Opt{'all'} || $Opt{'todo'}) {
        diag('Running TODO tests...'); # {{{

        TODO: {

            local $TODO = '';
            # Insert TODO tests here.

        }
        # TODO tests }}}
    }

    diag('Testing finished.');
    return($Retval);
    # }}}
} # main()

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc}) &&
        BAIL_OUT("testcmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
    my $Txt = join('',
        $cmd_outp_str,
        defined($Desc)
            ? $Desc
            : ''
    );
    my $TMP_STDERR = "$CMD_BASENAME-stderr.tmp";
    my $retval = 1;

    if (defined($Exp_stderr)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    $retval &= is(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        $retval &= is(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
        unlink($TMP_STDERR);
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    $retval &= is($ret_val >> 8, $Exp_retval, "$Txt (retval)");
    return($retval);
    # }}}
} # testcmd()

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc}) &&
        BAIL_OUT("likecmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
    my $Txt = join('',
        $cmd_outp_str,
        defined($Desc)
            ? $Desc
            : ''
    );
    my $TMP_STDERR = "$CMD_BASENAME-stderr.tmp";
    my $retval = 1;

    if (defined($Exp_stderr)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    $retval &= like(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        $retval &= like(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
        unlink($TMP_STDERR);
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    $retval &= is($ret_val >> 8, $Exp_retval, "$Txt (retval)");
    return($retval);
    # }}}
} # likecmd()

sub file_data {
    # Return file content as a string {{{
    my $File = shift;
    my $Txt;
    if (open(my $fp, '<', $File)) {
        local $/ = undef;
        $Txt = <$fp>;
        close($fp);
        return($Txt);
    } else {
        return;
    }
    # }}}
} # file_data()

sub print_version {
    # Print program version {{{
    print("$progname $VERSION\n");
    return;
    # }}}
} # print_version()

sub usage {
    # Send the help message to stdout {{{
    my $Retval = shift;

    if ($Opt{'verbose'}) {
        print("\n");
        print_version();
    }
    print(<<"END");

Usage: $progname [options] [file [files [...]]]

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
    # }}}
} # usage()

sub msg {
    # Print a status message to stderr based on verbosity level {{{
    my ($verbose_level, $Txt) = @_;

    if ($Opt{'verbose'} >= $verbose_level) {
        print(STDERR "$progname: $Txt\n");
    }
    return;
    # }}}
} # msg()

__END__

# This program is free software; you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by 
# the Free Software Foundation; either version 2 of the License, or (at 
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program.
# If not, see L<http://www.gnu.org/licenses/>.

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
