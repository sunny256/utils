#!/usr/bin/env perl

#=======================================================================
# sort-sqlite.t
# File ID: b5f7d80e-70ff-11e5-96fa-fefdb24f8e10
#
# Test suite for sort-sqlite(1).
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

our $CMD_BASENAME = "sort-sqlite";
our $CMD = "../$CMD_BASENAME";
our $SQLITE = "sqlite3";

our %Opt = (

    'all' => 0,
    'help' => 0,
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
    'todo|t' => \$Opt{'todo'},
    'verbose|v+' => \$Opt{'verbose'},
    'version' => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

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
    ok(chdir("sort-sqlite-files"), "chdir sort-sqlite-files");
    $CMD = "../$CMD";
    testcmd("tar xzf sqlite-dbs.tar.gz", # {{{
        '',
        '',
        0,
        "Untar sqlite-dbs.tar.gz",
    );

    # }}}
    ok(chdir("sqlite-dbs"), "chdir sqlite-dbs");
    $CMD = "../$CMD";
    testcmd("$CMD non-existing.sqlite", # {{{
        "",
        "sort-sqlite: non-existing.sqlite: File is not readable by you or is not a regular file\n",
        1,
        "Try to open a non-existing file",
    );

    # }}}
    testcmd("$CMD unsorted1.sqlite", # {{{
        "",
        "",
        0,
        "Sort unsorted1.sqlite",
    );

    # }}}
    is(dump_db("unsorted1.sqlite"), # {{{
        <<END,
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE t (
  a TEXT
);
INSERT INTO "t" VALUES('a');
INSERT INTO "t" VALUES('b');
INSERT INTO "t" VALUES('c');
INSERT INTO "t" VALUES('d');
COMMIT;
END
        "unsorted1.sqlite looks ok",
    );

    # }}}
    ok(-f "unsorted1.sqlite.20151012T164244Z.bck", "Backup file 1 exists");
    testcmd("$CMD -v unsorted2.sqlite unsorted3.sqlite", # {{{
        "",
        "sort-sqlite: Sorting unsorted2.sqlite\n" .
        "sort-sqlite: Sorting unsorted3.sqlite\n",
        0,
        "Sort unsorted2.sqlite",
    );

    # }}}
    is(dump_db("unsorted2.sqlite"), # {{{
        <<END,
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE u (
  a TEXT
);
INSERT INTO "u" VALUES('0');
INSERT INTO "u" VALUES('1');
INSERT INTO "u" VALUES('a');
INSERT INTO "u" VALUES('aa');
INSERT INTO "u" VALUES('→');
CREATE TABLE t (
  a TEXT
);
INSERT INTO "t" VALUES('a');
INSERT INTO "t" VALUES('b');
INSERT INTO "t" VALUES('c');
INSERT INTO "t" VALUES('d');
COMMIT;
END
        "unsorted2.sqlite looks ok",
    );

    # }}}
    is(dump_db("unsorted3.sqlite"), # {{{
        <<END,
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE u (
  a TEXT
);
INSERT INTO "u" VALUES('0');
INSERT INTO "u" VALUES('1');
INSERT INTO "u" VALUES('a');
INSERT INTO "u" VALUES('aa');
INSERT INTO "u" VALUES('→');
CREATE TABLE one (
  single TEXT
);
INSERT INTO "one" VALUES('z');
CREATE TABLE t (
  a TEXT
);
INSERT INTO "t" VALUES('a');
INSERT INTO "t" VALUES('b');
INSERT INTO "t" VALUES('c');
INSERT INTO "t" VALUES('d');
COMMIT;
END
        "unsorted3.sqlite looks ok",
    );

    # }}}
    ok(-f "unsorted2.sqlite.20151012T164437Z.bck", "Backup file 2 exists");
    ok(-f "unsorted3.sqlite.20151012T181141Z.bck", "Backup file 3 exists");
    ok(unlink("unsorted1.sqlite"), "Delete unsorted1.sqlite");
    ok(unlink("unsorted2.sqlite"), "Delete unsorted2.sqlite");
    ok(unlink("unsorted3.sqlite"), "Delete unsorted3.sqlite");
    ok(unlink("unsorted1.sqlite.20151012T164244Z.bck"), "Delete backup 1");
    ok(unlink("unsorted2.sqlite.20151012T164437Z.bck"), "Delete backup 2");
    ok(unlink("unsorted3.sqlite.20151012T181141Z.bck"), "Delete backup 3");
    ok(chdir(".."), "chdir ..");
    ok(rmdir("sqlite-dbs"), "rmdir sqlite-dbs");

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

sub dump_db {
    # Return SQLite dump of database file {{{
    my $File = shift;
    my $Txt;
    if (open(my $fp, "$SQLITE $File .dump |")) {
        local $/ = undef;
        $Txt = <$fp>;
        close($fp);
        return($Txt);
    } else {
        return;
    }
    # }}}
} # dump_db()

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc}) && BAIL_OUT("testcmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'sort-sqlite-stderr.tmp';
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
    defined($descriptions{$Desc}) && BAIL_OUT("likecmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'sort-sqlite-stderr.tmp';
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

Contains tests for the sort-sqlite(1) program.

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

sort-sqlite.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the sort-sqlite(1) program.

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