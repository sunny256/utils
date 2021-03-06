#!/usr/bin/env perl

#=======================================================================
# filesynced.t
# File ID: 8f5fa76e-a802-11e5-bb87-fefdb24f8e10
#
# Test suite for filesynced(1).
#
# Character set: UTF-8
# ©opyleft 2015– Øyvind A. Holm <sunny@sunbase.org>
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
use IPC::Open3;

local $| = 1;

our $CMD_BASENAME = "filesynced";
our $CMD = "../$CMD_BASENAME";
my $SQLITE = "sqlite3";

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

my $sql_error = 0;

exit(main());

sub main {
    # {{{
    my $Retval = 0;

    diag(sprintf('========== Executing %s v%s ==========',
                 $progname, $VERSION));

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
    likecmd("$CMD -h -v", # {{{
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

    my $Tmptop = "tmp-filesynced-t-$$-" . substr(rand, 2, 8);
    my $GIT = "git";

    ok(mkdir($Tmptop), "mkdir [Tmptop]");
    ok(chdir($Tmptop), "chdir [Tmptop]") || BAIL_OUT();
    likecmd("$GIT init repo-fs-t", # {{{
        '/.*/',
        '/.*/',
        0,
        "git init repo-fs-t",
    );

    # }}}
    ok(-d "repo-fs-t/.git", "repo-fs-t/.git exists") || BAIL_OUT();
    ok(-d "../$Tmptop", "We're in [Tmptop]") || BAIL_OUT();
    ok(chdir("repo-fs-t"), "chdir repo-fs-t");
    $CMD = "../../../$CMD_BASENAME";
    ok(-f $CMD, "Executable is in place") || BAIL_OUT();
    testcmd("$CMD -v", # No options, no database {{{
        '',
        "filesynced: synced.sqlite: Sync database not found\n",
        1,
        "No options, no database",
    );

    # }}}
    testcmd("$CMD -l -v", # No database and -l {{{
        '',
        "filesynced: synced.sqlite: Sync database not found\n",
        1,
        "No database and -l",
    );

    # }}}
    diag("--init");
    chomp(my $sql_create_synced = <<END); # {{{
CREATE TABLE synced (
  file TEXT
    CONSTRAINT synced_file_length
      CHECK (length(file) > 0)
    UNIQUE
    NOT NULL
  ,
  orig TEXT
  ,
  rev TEXT
    CONSTRAINT synced_rev_length
      CHECK (length(rev) = 40 OR rev = '')
  ,
  date TEXT
    CONSTRAINT synced_date_length
      CHECK (date IS NULL OR length(date) = 19)
    CONSTRAINT synced_date_valid
      CHECK (date IS NULL OR datetime(date) IS NOT NULL)
);
END
    # }}}
    chomp(my $sql_create_todo = <<END); # {{{
CREATE TABLE todo (
  file TEXT
    CONSTRAINT todo_file_length
      CHECK(length(file) > 0)
    UNIQUE
    NOT NULL
  ,
  pri INTEGER
    CONSTRAINT todo_pri_range
      CHECK(pri BETWEEN 1 AND 5)
  ,
  comment TEXT
);
END
    # }}}
    testcmd("$CMD --init", # {{{
        "",
        "",
        0,
        "--init without options",
    );

    # }}}
    is(sql_dump("synced.sql"), <<END, "synced.sql is ok"); # {{{
$sql_create_synced
$sql_create_todo
END

    # }}}
    likecmd("$CMD --init", # {{{
        '/^$/',
        '/\/repo-fs-t\/synced.sql already exists\n$/s',
        1,
        "Refuse to --init when synced.sql exists",
    );

    # }}}
    testcmd("sqlite3 synced.sqlite <synced.sql", '', '', 0, # {{{
        "Create synced.sqlite from synced.sql");

    # }}}
    ok(unlink("synced.sql"), "Delete synced.sql");
    likecmd("$CMD --init", # {{{
        '/^$/',
        '/\/repo-fs-t\/synced.sqlite: File already exists\n' .
            'filesynced: No token received from filesynced --lock\n' .
            '$/s',
        1,
        "It also reacts negatively to the presence of synced.sqlite",
    );

    # }}}
    ok(unlink("synced.sqlite"), "Delete synced.sqlite");
    diag("--lock");
    testcmd("$CMD --init", # {{{
        "",
        "",
        0,
        "Create synced.sql again with --init",
    );

    # }}}
    testcmd("$CMD --lock >key.txt", "", "", 0, # {{{
        "Use --lock, store key in key.txt",
    );

    # }}}
    my $realtoken = file_data("key.txt");
    likecmd("$CMD --lock --timeout 0", # {{{
        '/^$/',
        '/^' .
            'filesynced --lock: .+\/repo-fs-t\/synced.sql\.lock: ' .
              'Waiting for lockdir\.\.\.\n' .
            'filesynced: Lock not aquired after 0 seconds, aborting\n' .
            '$/s',
        1,
        "Try to lock again, wimp gives up after 0 seconds",
    );

    # }}}
    like($realtoken, # {{{
        (
            '/^' .
            'token_' .
            '20\d\d' . '[01]\d' . '\d\d' .
            'T' .
            '[0-2]\d' . '[0-5]\d' . '[0-6]\d' .
            'Z' .
            '\.' .
            '\d+' .
            '\n' .
            '$/s'
        ),
        "key.txt looks ok",
    );

    # }}}
    diag("--unlock");
    testcmd("$CMD --unlock", # {{{
        "",
        "filesynced --unlock: Token mismatch\n",
        1,
        "No argument to --unlock",
    );

    # }}}
    testcmd("$CMD --unlock ''", # {{{
        "",
        "filesynced --unlock: Token mismatch\n",
        1,
        "--unlock receives empty string",
    );

    # }}}
    testcmd("$CMD --unlock token_20141212T123456Z.1234." . ("2" x 40), # {{{
        "",
        "filesynced --unlock: Token mismatch\n",
        1,
        "--unlock token is wrong",
    );

    # }}}
    testcmd("$CMD --unlock $realtoken", # {{{
        "",
        "",
        0,
        "--unlock token is valid",
    );

    # }}}
    likecmd("$CMD --lock", # {{{
        '/^token_\S+\n$/',
        '/^$/',
        0,
        "--lock, throw away the token",
    );

    # }}}
    testcmd("$CMD --unlock -f", # {{{
        "",
        "",
        0,
        "--unlock with -f (force)",
    );

    # }}}
    likecmd("$CMD --lock", # {{{
        '/^token_\S+\n$/',
        '/^$/',
        0,
        "--lock again, throw away the token",
    );

    # }}}
    testcmd("$CMD --force --unlock", # {{{
        "",
        "",
        0,
        "--unlock with --force",
    );

    # }}}
    diag("--add");
    testcmd("$CMD --add nonexisting.txt", # {{{
        "",
        "filesynced: nonexisting.txt: File not found, no entries updated\n",
        1,
        "Try to --add non-existing file",
    );

    # }}}
    ok(create_file("tmpfile.txt", "This is tmpfile.txt"),
        "Create tmpfile.txt");
    testcmd("$CMD --add tmpfile.txt nonexisting.txt", # {{{
        "",
        "filesynced: nonexisting.txt: File not found, no entries updated\n",
        1,
        "Try to --add existing and non-existing file",
    );

    # }}}
    is(sql_dump("synced.sql"), # {{{
        <<END,
$sql_create_synced
$sql_create_todo
END
        "tmpfile.txt is not added to synced.sql yet",
    );

    # }}}
    testcmd("$CMD --add tmpfile.txt", # {{{
        "",
        "",
        0,
        "Add tmpfile.txt with --add",
    );

    # }}}
    is(sql_dump("synced.sql"), # {{{
        <<END,
$sql_create_synced
$sql_create_todo
synced|tmpfile.txt|NULL|NULL|NULL
END
        "tmpfile.txt is added to synced.sql",
    );

    # }}}
    likecmd("$CMD --add tmpfile.txt", # {{{
        '/^$/s',
        '/filesynced: Cannot add "tmpfile\.txt" to the database, ' .
            'no entries updated\n/s',
        1,
        "Fail to add it again",
    );

    # }}}
    is(sql_dump("synced.sql"), # {{{
        <<END,
$sql_create_synced
$sql_create_todo
synced|tmpfile.txt|NULL|NULL|NULL
END
        "There's only one tmpfile.txt in synced.sql",
    );

    # }}}
    ok(!-d "synced.sql.lock", "synced.sql.lock/ is gone");
    diag("--delete");
    testcmd("$CMD --delete nonexisting.txt", # {{{
        "",
        "",
        1,
        "--delete nonexisting.txt",
    );

    # }}}
    testcmd("$CMD --delete tmpfile.txt", # {{{
        "",
        "filesynced: Deleted tmpfile.txt from synced\n",
        0,
        "--delete tmpfile.txt",
    );

    # }}}
    is(sql_dump("synced.sql"), # {{{
        <<END,
$sql_create_synced
$sql_create_todo
END
        "tmpfile.txt is gone from synced.sql",
    );

    # }}}
    testcmd("$CMD --add -t bash tmpfile.txt", # {{{
        "",
        "",
        0,
        "Add tmpfile.txt again, now with -t bash",
    );

    # }}}
    is(sql_dump("synced.sql"), # {{{
        <<END,
$sql_create_synced
$sql_create_todo
synced|tmpfile.txt|Lib/std/bash|NULL|NULL
END
        "tmpfile.txt is added to synced.sql with orig value",
    );

    # }}}
    diag("--unsynced");
    create_file("file1", "This is file1.\n");
    testcmd("git add file1", # {{{
        '',
        '',
        0,
        "git add file1",
    );

    # }}}
    likecmd("git commit -m 'Add file1'", # {{{
        '/^.+Add file1.+$/s',
        '/^$/',
        0,
        "git commit file1",
    );

    # }}}
    testcmd("$CMD --unsynced", # {{{
        "",
        "",
        0,
        "file1 is not listed by --unsynced because " .
          "it's not in synced.sql",
    );

    # }}}
    testcmd("$CMD --add -t Lib/std/bash file1", # {{{
        "",
        "",
        0,
        "--add file1",
    );

    # }}}
    testcmd("$CMD --unsynced", # {{{
        "file1\n",
        "",
        0,
        "file1 is listed by --unsynced",
    );

    # }}}
    testcmd("$CMD HEAD file1", # {{{
        "",
        "",
        0,
        "Mark file1 as updated",
    );

    # }}}
    testcmd("$CMD --unsynced", # {{{
        "",
        "",
        0,
        "file1 should be gone from --unsynced now",
    );

    # }}}
    # diag("--valid-sha");
    # FIXME: Create tests for --valid-sha. Have to set up some sync 
    # rules first.
    testcmd("$CMD --delete file1", # {{{
        "",
        "filesynced: Deleted file1 from synced\n",
        0,
        "--delete file1",
    );

    # }}}
    diag("--create-index");
    testcmd("$CMD --create-index", # {{{
        "",
        "",
        0,
        "Use with --create-index",
    );

    # }}}
    is(sql_dump("synced.sql"), # {{{
        <<END,
$sql_create_synced
$sql_create_todo
CREATE INDEX idx_synced_file ON synced (file);
CREATE INDEX idx_synced_orig ON synced (orig);
CREATE INDEX idx_synced_rev ON synced (rev);
synced|tmpfile.txt|Lib/std/bash|NULL|NULL
END
        "synced.sql contains indexes",
    );

    # }}}

    diag("Clean up");
    ok(chdir(".."), "chdir ..");
    testcmd("rm -rf repo-fs-t", '', '', 0, "Delete repo-fs-t/");
    ok(chdir(".."), "chdir ..");
    ok(rmdir($Tmptop), "rmdir [Tmptop]");

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
    return $Retval;
    # }}}
} # main()

sub sql {
    # {{{
    my ($db, $sql) = @_;
    my @retval = ();

    msg(5, "sql(): db = '$db'");
    local(*CHLD_IN, *CHLD_OUT, *CHLD_ERR);

    my $pid = open3(*CHLD_IN, *CHLD_OUT, *CHLD_ERR, $SQLITE, $db) or (
        $sql_error = 1,
        msg(0, "sql(): open3() error: $!"),
        return("sql() error"),
    );
    msg(5, "sql(): sql = '$sql'");
    print(CHLD_IN "$sql\n") or msg(0, "sql(): print CHLD_IN error: $!");
    close(CHLD_IN);
    @retval = <CHLD_OUT>;
    msg(5, "sql(): retval = '" . join('|', @retval) . "'");
    my @child_stderr = <CHLD_ERR>;
    if (scalar(@child_stderr)) {
        msg(1, "$SQLITE error: " . join('', @child_stderr));
        $sql_error = 1;
    }
    return(join('', @retval));
    # }}}
} # sql()

sub sqlite_dump {
    # Return contents of database file {{{
    my $File = shift;

    return sql($File, <<END);
.nullvalue NULL
.schema
SELECT 'synced', * FROM synced;
END
    # }}}
} # sqlite_dump()

sub sql_dump {
    # {{{
    my $File = shift;
    my $db = "$File.sqlite";
    my $Txt;

    is(system("$SQLITE $db <$File"), 0, "Create $db from $File");
    ok(-f $db, "$db exists");
    $Txt = sqlite_dump("$db");
    ok(unlink($db), "Delete $db");

    return $Txt;
    # }}}
} # sql_dump()

sub testcmd {
    # {{{
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
        $retval &= is(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
        unlink($TMP_STDERR);
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    $retval &= is($ret_val >> 8, $Exp_retval, "$Txt (retval)");

    return $retval;
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
    my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
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

    return $retval;
    # }}}
} # likecmd()

sub file_data {
    # Return file content as a string {{{
    my $File = shift;
    my $Txt;

    open(my $fp, '<', $File) or return undef;
    local $/ = undef;
    $Txt = <$fp>;
    close($fp);
    return $Txt;
    # }}}
} # file_data()

sub create_file {
    # Create new file and fill it with data {{{
    my ($file, $text) = @_;
    my $retval = 0;
    if (open(my $fp, ">$file")) {
        print($fp $text);
        close($fp);
        $retval = is(
            file_data($file),
            $text,
            "$file was successfully created",
        );
    }
    return($retval); # 0 if error, 1 if ok
    # }}}
} # create_file()

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
    # }}}
} # usage()

sub msg {
    # Print a status message to stderr based on verbosity level {{{
    my ($verbose_level, $Txt) = @_;

    $verbose_level > $Opt{'verbose'} && return;
    print(STDERR "$progname: $Txt\n");
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
