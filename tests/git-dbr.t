#!/usr/bin/env perl

#=======================================================================
# git-dbr.t
# File ID: f7855efa-7a4f-11e5-968c-02010e0a6634
#
# Test suite for git-dbr(1).
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

local $| = 1;

our $CMD = '../git-dbr';

our %Opt = (

    'all' => 0,
    'git' => defined($ENV{'GIT_DBR_GIT'}) ? $ENV{'GIT_DBR_GIT'} : 'git',
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
    'git|g=s' => \$Opt{'git'},
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

my $GIT = $Opt{'git'};

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
    my $Tmptop = "tmp-git-dangling-t-$$-" . substr(rand, 2, 8);
    ok(mkdir($Tmptop), "mkdir [Tmptop]");
    ok(chdir($Tmptop), "chdir [Tmptop]");
    diag("Initialise test repos");
    likecmd("$GIT init repo_a", # {{{
        '/.*/',
        '/.*/',
        0,
        "git init repo_a",
    );

    # }}}
    if (!ok(-d "repo_a/.git", "repo_a/.git exists")) { # {{{
        ok(chdir(".."), "chdir .. before bailout");
        ok(rmdir($Tmptop), "rmdir [Tmptop] before bailout");
        BAIL_OUT("repo_a wasn't created properly, aborting");
    }

    # }}}
    likecmd("$GIT init repo_b", # {{{
        '/.*/',
        '/.*/',
        0,
        "git init repo_b",
    );

    # }}}
    ok(-d "repo_b/.git", "repo_b/.git exists");
    ok(chdir("repo_a"), "chdir repo_a");
    create_remote("repo_b", "../repo_b");
    likecmd("$GIT commit --allow-empty -m 'Initial empty commit'", # {{{
        '/.*/',
        '/.*/',
        0,
        "Create initial commit in repo_a",
    );

    # }}}
    is(`$GIT log --format="%T %s"`, # {{{
        "4b825dc642cb6eb9a060e54bf8d69288fbee4904 Initial empty commit\n",
        "Initial commit in repo_a was created",
    );

    # }}}
    create_branch("branch_a");
    create_branch("branch_b");
    create_branch("oldbranch");
    ok(chdir("../repo_b"), "chdir ../repo_b");
    create_remote("repo_a", "../repo_a");
    likecmd("$GIT fetch repo_a", # {{{
        '/^$/',
        '/^' .
            'From \.\.\/repo_a\n' .
            '.+' .
            '\[new branch\].+repo_a\/branch_a\n' .
            '.+' .
            '\[new branch\].+repo_a\/branch_b\n' .
            '.+' .
            '\[new branch\].+repo_a\/master\n' .
            '.+' .
            '\[new branch\].+repo_a\/oldbranch\n' .
            '$/s',
        0,
        "Fetch from repo_a",
    );

    # }}}
    check_branches(<<END, "after initial fetch"); # {{{
  remotes/repo_a/branch_a
  remotes/repo_a/branch_b
  remotes/repo_a/master
  remotes/repo_a/oldbranch
END

    # }}}
    $CMD = "../../$CMD";
    diag("Start of git-dbr tests");
    testcmd("$CMD", # {{{
        '',
        '',
        0,
        "No arguments",
    );

    # }}}
    create_branch("oldbranch", "repo_a/oldbranch");
    check_branches(<<END, "after oldbranch was created"); # {{{
  oldbranch
  remotes/repo_a/branch_a
  remotes/repo_a/branch_b
  remotes/repo_a/master
  remotes/repo_a/oldbranch
END

    # }}}
    likecmd("$CMD oldbranch", # {{{
        '/^Deleted branch oldbranch \(was [0-9a-f]+\)\.\n$/s',
        '/^git-dbr: Executing \'git branch -D oldbranch\'\.\.\.\n$/s',
        0,
        "Delete local branch 'oldbranch'",
    );

    # }}}
    create_branch("oldbranch2", "repo_a/oldbranch");
    likecmd("$CMD oldbranch2 repo_a/oldbranch", # {{{
        '/^Deleted branch oldbranch2 \(was [0-9a-f]+\)\.\n$/s',
        '/^' .
            'git-dbr: Executing \'git branch -D oldbranch2\'\.\.\.\n' .
            'git-dbr: Executing \'git push repo_a :oldbranch\'\.\.\.\n' .
            'To \.\.\/repo_a\n' .
            '.+' .
            '\[deleted\]\s+oldbranch\n' .
            '$/s',
        0,
        "Delete local branch 'oldbranch2' and remote branch 'repo_a/oldbranch'",
    );

    # }}}
    fetch("repo_a", "after deletion of oldbranch2 and repo_a/oldbranch");
    check_branches(<<END, "after oldbranch2 and repo_a/oldbranch were deleted"); # {{{
  remotes/repo_a/branch_a
  remotes/repo_a/branch_b
  remotes/repo_a/master
END

    # }}}
    create_branch("branch_a", "repo_a/branch_a");
    likecmd("$GIT branch -a | grep branch_a | xargs $CMD", # {{{
        '/^Deleted branch branch_a \(was [0-9a-f]+\)\.\n$/s',
        '/^' .
            'git-dbr: Executing \'git branch -D branch_a\'\.\.\.\n' .
            'git-dbr: Executing \'git push repo_a :branch_a\'\.\.\.\n' .
            'To \.\.\/repo_a\n' .
            '.+' .
            '\[deleted\]\s+branch_a\n' .
            '$/s',
        0,
        "Delete all 'branch_a' branches with xargs",
    );

    # }}}
    fetch("repo_a", "after all 'branch_a' branches were deleted");
    check_branches(<<END, "after all 'branch_a' branches were deleted"); # {{{
  remotes/repo_a/branch_b
  remotes/repo_a/master
END

    # }}}
    likecmd("$CMD repo_a/branch_b,", # {{{
        '/^$/s',
        '/^' .
            'git-dbr: Executing \'git push repo_a :branch_b\'\.\.\.\n' .
            'To \.\.\/repo_a\n' .
            '.+' .
            '\[deleted\]\s+branch_b\n' .
            '$/s',
        0,
        "Delete local branch 'repo_a/branch_b' and strip trailing comma",
    );

    # }}}
    ok(chdir(".."), "chdir ..");
    diag("Delete temporary test directories");
    ok(-d "repo_a", "repo_a exists");
    testcmd("rm -rf repo_a", # {{{
        '',
        '',
        0,
        "Delete repo_a",
    );

    # }}}
    ok(!-e "repo_a", "repo_a is gone");
    ok(-d "repo_b", "repo_b exists");
    testcmd("rm -rf repo_b", # {{{
        '',
        '',
        0,
        "Delete repo_b",
    );

    # }}}
    ok(!-e "repo_b", "repo_b is gone");
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
    # }}}
} # main()

sub check_branches {
    # {{{
    my ($should_be, $desc) = @_;
    is(`$GIT branch -a`, $should_be, "Branches are ok $desc");
    return;
    # }}}
} # check_branches()

sub create_branch {
    # {{{
    my ($branch, $remote_branch) = @_;
    defined($remote_branch) || ($remote_branch = '');
    likecmd("$GIT branch $branch $remote_branch",
        '/.*/s',
        '/^$/s',
        0,
        "Create '$branch' branch" .
            (length($remote_branch) ? " from $remote_branch" : ""),
    );
    return;
    # }}}
} # create_branch()

sub create_remote {
    # {{{
    my ($name, $url) = @_;
    testcmd("$GIT remote add $name $url",
        '',
        '',
        0,
        "Create remote '$name'",
    );
    return;
    # }}}
} # create_remote()

sub fetch {
    # {{{
    my ($remote, $desc) = @_;
    testcmd("$GIT fetch --prune $remote",
        '',
        '',
        0,
        "Fetch from $remote ($desc)",
    );
    return;
    # }}}
} # fetch()

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
    my $TMP_STDERR = 'git-dbr-stderr.tmp';
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
    my $TMP_STDERR = 'git-dbr-stderr.tmp';
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

Contains tests for the git-dbr(1) program.

Options:

  -a, --all
    Run all tests, also TODOs.
  -g X, --git X
    Specify alternative git executable to use. Used to execute the tests 
    with different git versions. This can also be set with the 
    GIT_DBR_GIT environment variable.
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

git-dbr.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the git-dbr(1) program.

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