#!/usr/bin/env perl

#=======================================================================
# ga-sumsize.t
# File ID: e64cce20-5619-11e5-a28a-000df06acc56
#
# Test suite for ga-sumsize(1).
#
# Character set: UTF-8
# ©opyleft 2015– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;

BEGIN {
    # push(@INC, "$ENV{'HOME'}/bin/STDlibdirDTS");
    use Test::More qw{no_plan};
    # use_ok() goes here
}

use Getopt::Long;

local $| = 1;

our $CMD = '../ga-sumsize';

our %Opt = (

    'all' => 0,
    'help' => 0,
    'todo' => 0,
    'verbose' => 0,
    'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.0.0';

Getopt::Long::Configure('bundling');
GetOptions(

    'all|a' => \$Opt{'all'},
    'help|h' => \$Opt{'help'},
    'todo|t' => \$Opt{'todo'},
    'verbose|v+' => \$Opt{'verbose'},
    'version' => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

exit(main(%Opt));

sub main {
    # {{{
    my %Opt = @_;
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
        '/  Show this help\./',
        '/^$/',
        0,
        'Option -h prints help screen',
    );

    # }}}
    diag('Testing -v (--verbose) option...');
    likecmd("$CMD -hv", # {{{
        '/^\n\S+ \d+\.\d+\.\d+(\+git)?\n/s',
        '/^$/',
        0,
        'Option -v with -h returns version number and help screen',
    );

    # }}}
    diag('Testing --version option...');
    likecmd("$CMD --version", # {{{
        '/^\S+ \d+\.\d+\.\d+(\+git)?\n/',
        '/^$/',
        0,
        'Option --version returns version number',
    );

    # }}}

    testcmd("$CMD </dev/null", # {{{
        "\nga-sumsize: Total size of keys: 0 (0)\n",
        '',
        0,
        'Read empty input from stdin',
    );

    # }}}
    testcmd("$CMD /dev/null", # {{{
        "\nga-sumsize: Total size of keys: 0 (0)\n",
        '',
        0,
        'Read directly from /dev/null',
    );

    # }}}
    testcmd("$CMD ga-sumsize-files/1.txt", # {{{
        <<END,
unused . (checking for unused data...) (checking master...)
  Some annexed data is no longer used by any files:
    NUMBER  KEY
    1       SHA256-s487883366--2125edd12f347e19dc9d5c2c2f4cee14b44f9cbba1ea46ff8af54ae020c58563
    2       SHA256-s484307143--049e14e3af3bf9aece17ddab008b3cb9be6ab0fb42c91e6ad383364d26b3ffa7
    3       SHA256-s490478481--12453004cbf74f56adf115f9da32d2b783c9c967469668dbf0f88b85efc856b8
    4       SHA256-s485358886--bf6c061f378e04d6f45a95e13412aabc4c420a714cfebe7ab70034b72605bc47
  (To see where data was previously used, try: git log --stat -S'KEY')

  To remove unwanted data: git-annex dropunused NUMBER

ok

ga-sumsize: Total size of keys: 1948027876 (1.9G)
END
        '',
        0,
        'Read from 1.txt',
    );

    # }}}
    testcmd("$CMD <ga-sumsize-files/1.txt", # {{{
        <<END,
unused . (checking for unused data...) (checking master...)
  Some annexed data is no longer used by any files:
    NUMBER  KEY
    1       SHA256-s487883366--2125edd12f347e19dc9d5c2c2f4cee14b44f9cbba1ea46ff8af54ae020c58563
    2       SHA256-s484307143--049e14e3af3bf9aece17ddab008b3cb9be6ab0fb42c91e6ad383364d26b3ffa7
    3       SHA256-s490478481--12453004cbf74f56adf115f9da32d2b783c9c967469668dbf0f88b85efc856b8
    4       SHA256-s485358886--bf6c061f378e04d6f45a95e13412aabc4c420a714cfebe7ab70034b72605bc47
  (To see where data was previously used, try: git log --stat -S'KEY')

  To remove unwanted data: git-annex dropunused NUMBER

ok

ga-sumsize: Total size of keys: 1948027876 (1.9G)
END
        '',
        0,
        'Read from 1.txt via stdin',
    );

    # }}}
    testcmd("$CMD --display ga-sumsize-files/1.txt", # {{{
        <<END,
0 unused . (checking for unused data...) (checking master...)
0   Some annexed data is no longer used by any files:
0     NUMBER  KEY
487883366     1       SHA256-s487883366--2125edd12f347e19dc9d5c2c2f4cee14b44f9cbba1ea46ff8af54ae020c58563
972190509     2       SHA256-s484307143--049e14e3af3bf9aece17ddab008b3cb9be6ab0fb42c91e6ad383364d26b3ffa7
1462668990     3       SHA256-s490478481--12453004cbf74f56adf115f9da32d2b783c9c967469668dbf0f88b85efc856b8
1948027876     4       SHA256-s485358886--bf6c061f378e04d6f45a95e13412aabc4c420a714cfebe7ab70034b72605bc47
1948027876   (To see where data was previously used, try: git log --stat -S'KEY')
1948027876 
1948027876   To remove unwanted data: git-annex dropunused NUMBER
1948027876 
1948027876 ok

ga-sumsize: Total size of keys: 1948027876 (1.9G)
END
        '',
        0,
        'Test --display option',
    );

    # }}}
    testcmd("$CMD -d ga-sumsize-files/1.txt", # {{{
        <<END,
0 unused . (checking for unused data...) (checking master...)
0   Some annexed data is no longer used by any files:
0     NUMBER  KEY
487883366     1       SHA256-s487883366--2125edd12f347e19dc9d5c2c2f4cee14b44f9cbba1ea46ff8af54ae020c58563
972190509     2       SHA256-s484307143--049e14e3af3bf9aece17ddab008b3cb9be6ab0fb42c91e6ad383364d26b3ffa7
1462668990     3       SHA256-s490478481--12453004cbf74f56adf115f9da32d2b783c9c967469668dbf0f88b85efc856b8
1948027876     4       SHA256-s485358886--bf6c061f378e04d6f45a95e13412aabc4c420a714cfebe7ab70034b72605bc47
1948027876   (To see where data was previously used, try: git log --stat -S'KEY')
1948027876 
1948027876   To remove unwanted data: git-annex dropunused NUMBER
1948027876 
1948027876 ok

ga-sumsize: Total size of keys: 1948027876 (1.9G)
END
        '',
        0,
        'Test -d option',
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
    # }}}
} # main()

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    my $stderr_cmd = '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'ga-sumsize-stderr.tmp';

    if (defined($Exp_stderr)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    is(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        is(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
        unlink($TMP_STDERR);
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    is($ret_val >> 8, $Exp_retval, "$Txt (retval)");
    return;
    # }}}
} # testcmd()

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    my $stderr_cmd = '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'ga-sumsize-stderr.tmp';

    if (defined($Exp_stderr)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    like(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        like(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
        unlink($TMP_STDERR);
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    is($ret_val >> 8, $Exp_retval, "$Txt (retval)");
    return;
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

Contains tests for the ga-sumsize(1) program.

Options:

  -a, --all
    Run all tests, also TODOs.
  -h, --help
    Show this help.
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

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME

run-tests.pl

=head1 SYNOPSIS

ga-sumsize.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the ga-sumsize(1) program.

=head1 OPTIONS

=over 4

=item B<-a>, B<--all>

Run all tests, also TODOs.

=item B<-h>, B<--help>

Print a brief help summary.

=item B<-t>, B<--todo>

Run only the TODO tests.

=item B<-v>, B<--verbose>

Increase level of verbosity. Can be repeated.

=item B<--version>

Print version information.

=back

=head1 AUTHOR

Made by Øyvind A. Holm S<E<lt>sunny@sunbase.orgE<gt>>.

=head1 COPYRIGHT

Copyleft © Øyvind A. Holm E<lt>sunny@sunbase.orgE<gt>
This is free software; see the file F<COPYING> for legalese stuff.

=head1 LICENCE

This program is free software; you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation; either version 2 of the License, or (at your 
option) any later version.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program.
If not, see L<http://www.gnu.org/licenses/>.

=head1 SEE ALSO

=cut

# }}}

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :