README for utils.git
====================

This is a collection of scripts I've had in my `~/bin/` directory since 
the previous century. Some of them are quite specific for my own use, 
but many of them have evolved into a mature state and could probably 
have their own repository as their own project. That will probably not 
happen, as most of the scripts consists of only one file.

The `master` branch is considered stable and will never be rebased. 
Every new functionality or bug fix is created on topic branches which 
may be rebased now and then. All tests on `master` (executed with "make 
test") should succeed. If any test fails, it’s considered a bug. Please 
report any failing tests in the issue tracker.

License
-------

Everything here created by Øyvind A. Holm (<sunny@sunbase.org>) is 
licensed under the GNU General Public License version 2 or later.

Download
--------

This repository can be cloned from

- `git@gitlab.com:sunny256/utils.git` / 
  <https://gitlab.com/sunny256/utils.git> (Main repo)
- `git@bitbucket.org:sunny256/utils.git`
- `ssh://sunny256@repo.or.cz/srv/git/sunny256-utils.git`

The repositories are synced with 
[Gitspread](https://gitlab.com/sunny256/gitspread).

Stable utilities
----------------

These scripts are stable and ready for public use.

### Git extensions, check out first

#### git-dangling

Scan the current repository for dangling heads (dead branches where the 
branch names have been deleted) or tags and create branches with the 
format `commit-SHA1` and `tag-SHA1`. This makes it easy to locate 
branches and tags that shouldn't have been deleted. No need to dig 
around in the reflog anymore. Needs `git-delete-banned`.

#### git-dbr

Delete remote and local branches specified on the command line, but can 
be used with the output from `git log --format=%d` or `%D`. A quick and 
easy way to clean up the branch tree with copy+paste.

#### git-rcmd

Execute commands in remote ssh repositories. For example, to make all 
connected ssh repos (if they have a local shell, of course) fetch all 
new commits from all remotes:

    git-rcmd -c "git fetch --all --prune"

#### git-testadd

Execute a command with only the staged changes in Git applied.

If you have lots of unrelated uncommitted changes in the current 
repository and want to split up the commit, how can you easily check if 
the changes passes the test suite? With all the other unrelated changes 
it can be hard to make sure that only relevant changes becomes part of 
the commit, and that they don't result in regressions. This script 
clones the repository to the directory `.testadd.tmp` in the current 
directory and applies the staged chenges there (unless 
`-u`/`--unmodified` is specified), chdirs to the same relative directory 
in the clone and executes the command specified on the command line 
there.

If the command contains any options starting with `-`, add `--` in front 
of the command so they won't be parsed by git-testadd, or surround it 
with quotes.

##### Examples

    user@host:~/src/myproject/src/t $ git-testadd make test

The command will be executed in `~/src/myproject/src/t/.testadd.tmp/` 
with only the staged changes applied.

    user@host:~/src/myproject/src/t $ git-testadd -- ./run-tests -v

This command contains a `-v` option. Disable option parsing of the 
command by prefixing it with `--`.

    $ git-testadd "make && cd t && make 2>&1 | less || echo fail"

With quotes, even control operators and pipes can be used.

#### git-wip

Useful for working with topic branches. Create subbranches separated 
with a full stop in the branch name. It can create new subbranches, 
merge to parent branches or `master` with or without fast-forward and 
squash the whole branch to the parent branch or `master`.

### Other stable Git extensions

#### git-allbr

Scan remotes for branches and recreate them in the local repository.

#### git-bare

Change the state of the current repository to/from a bare repository 
to/from a regular repository.

#### git-bs

Alias for `git bisect`, but allows execution from a subdirectory.

#### git-delete-banned

Delete unwanted `commit-SHA1` branches and `tag-SHA1` tags created by 
`git-dangling`. Some people like to keep old branches around after 
they've been squashed or rebased, but there are always some worthless 
branches around that only clutter the history. Those commits can be 
specified in `~/.git-dangling-banned`, and this command will delete 
them.

#### git-delete-old-branches

Delete obsolete Git branches locally and from all remotes. For each
branch, display a `git diff --stat` against all local and remote
branches with this name, a simplified `git log --graph`, and finally a 
`git log` with patch against all branches. Display this in less(1), and 
ask if all branches with this name should be deleted.

The following responses are valid:

- **y** - Delete all branches with this name locally and from all 
  remotes and mark it as garbage.
- **n** - Don't delete the branch. If `-o`/`--once` is used later, files 
  marked with `n` will not be checked.
- **d** - Mark branch as "don't know", to be perused later.
- **q** - Exit the program.

The answers can also be stored in an SQLite database to automate 
subsequent runs.

#### git-delrembr

Delete all remote and local branches specified on the command line.

#### git-ignore

Ignore files in Git. Automatically update `.gitignore` in the local 
directory (default) or add the file, directory or symlink to the 
`.gitignore` at the top of the repository. Directories will have a slash 
automatically added, and if the file/directory/symlink already exists in 
Git, it will be removed from the repository without touching the actual 
file.

#### git-logdiff

Show log differences between branches with optional patch.

#### git-mnff

Merge a topic branch without using fast-forward, always create a merge 
commit. This is used for collecting related changes together and makes 
things like `git log --oneline --graph` more readable. IMHO. After the 
branch is merged, it's deleted.

#### git-nocom

Filter output from `git branch` through this to remove `commit-SHA1` 
branches.

#### git-pa

Push to all predefined remotes with a single command.

#### git-restore-dirs

Restore empty directories from the `.emptydirs` file created by 
`git-store-dirs`.

#### git-rpull

Shortcut for `git rcmd -c "git pull --ff-only"`.

#### git-store-dirs

Store the names of all empty directories in a file called `.emptydirs` 
at the top of the repository. The names are zerobyte-separated to work 
with all kinds of weird characters in the directory names. Use 
`git-restore-dirs` to recreate the directories.

#### git-wait-until-clean

If there are any modifications or unknown files in the current 
repository, wait until it's been cleaned up. Useful in scripts where the 
following commands need a clean repository. Can also ignore unknown 
files or check for the existence of ignored files.

### Various

#### ampm

Read text from stdin or files and convert from am/pm to 24-hour clock.

#### datefn

Insert, replace or delete UTC timestamp from filenames.

#### dostime

Cripple the file modtime by truncating odd seconds to even. To make life 
easier for rsync and friends if one has to interact with those kinds of 
"file systems".

#### edit-sqlite3

Edit an SQLite 3.x database file in your favourite text editor. The 
original version is backuped with the file modification time in the file 
name as seconds since 1970-01-01 00:00:00 UTC.

#### find\_8bit

Read text from stdin and output all lines with bytes &gt; U+007F.

#### find\_inv\_utf8

Read text from stdin and print all lines containing invalid UTF-8.

#### goal

Print timestamp when a specific goal will be reached. Specify start date 
with value, goal value and current value, and it will print the date and 
time of when the goal will be reached.

#### md-header

Create commented-out Vim fold markers (&#60;!-- \{\{\{_num_ --&#62;) 
with header level in Commonmark/Markdown files at the end of every 
header line where hash signs are used. Useful for big documents.

#### zeropad

Pad decimal or hecadecimal numbers with zeroes to get equal length.

#### zerosplit

Split contents into files based on separation bytes.

## Stable, but has some limitations

### sort-sqlite

Sort the rows in an SQLite database. A backup of the previous version is 
copied to a \*.bck file containing the date of the file modification 
time in the file name.

## Not described yet

- git-add-missing-gpg-keys
- git-all-blobs
- git-all-repos
- git-allfiles
- git-authoract
- git-context-diff
- git-dl
- git-dobranch
- git-expand
- git-imerge
- git-lc
- git-listbundle
- git-mkrepo
- git-plot
- git-reach-commit
- git-scanrefs
- git-upstream

Create a graph in Gnuplot of the commit activity. Needs `ep`, 
`inc\_epstat` and `stpl`. And Gnuplot, of course.

FIXME: `ep` is in Nårwidsjn.

- git-realclean
- git-remote-hg
- git-repos
- git-savecommit
- git-size
- git-svn-myclone
- git-tree-size
- git-update-dirs
- git-wn

"git What's New". Create an ASCII representation of all commits that 
contain the current commit. Useful after a `git fetch` to list all new 
commits. Needs `git-lc`.

FIXME: Uses "git lg". Change that to a proper `git log` command or put 
the alias somewhere.

### git diff drivers

- rdbl-garmin-gpi
- rdbl-gpg
- rdbl-gramps-backup
- rdbl-odt
- rdbl-sort\_k5
- rdbl-sqlite3
- rdbl-unzip

### git-annex

- ga
- ga-au
- ga-findkey
- ga-fixnew
- ga-fsck-size
- ga-getnew
- ga-ignore-remote
- ga-key
- ga-other
- ga-sjekk
- ga-sumsize
- ga-tree

### Apache logs

- access\_log-date
- access\_log-drops
- access\_log2epstat
- access\_log2tab
- access\_log\_ip

### Other

- 256colors2.pl
- BUGS
- Div
- Git
- Lib
- Local
- Makefile
- Patch
- README.build-git.md
- README.md
- STDexecDTS
- Screen
- TODO
- Tools
- Utv
- access-myf
- ack
- act
- activesvn
- addpoints
- afv
- afv\_move
- afv\_rename
- afvctl
- age
- all-lpar
- allrevs
- annex-cmd
- ascii
- au
- avlytt
- bell
- bigsh
- bpakk
- bs
- build-git
- build-perl
- build-postgres
- build-vim
- ccc
- cdiff
- cdlabel
- center
- cfold
- charconv
- ciall
- cl
- clean\_files
- cmds
- colourtest
- commify
- commout
- construct\_call\_graph.py
- conv-old-suuid
- convkeyw
- cp1252
- cp865
- create\_cproject
- create\_imgindex
- create\_new
- create\_svn
- cryptit
- csv2gpx
- cunw
- cutfold
- cvscat
- cvse
- cvsvimdiff
- date2iso
- dbk
- dbllf
- debugprompt
- deep
- degpg
- detab
- dings\_it
- dings\_vimtrans
- dir-elems
- doc
- dprofpp.graphviz
- emptydirs
- enc-mp4
- encap
- encr
- ep
- ep-pause
- ep\_day
- eplog2date
- epstat
- extract\_mail
- ferdig
- fibonacci
- fileid
- filenamelower
- filesynced
- filmer
- filt
- filter\_ep
- filtrer\_access\_log
- findbom
- finddup
- findhex
- findrev
- firefox
- fix\_filenames
- fix\_mailman
- flac\_to\_ogg
- fldb
- fold-stdout
- fra\_linode
- fromdos
- fromhex
- g
- g0
- g1
- gammelsvn
- genpasswd
- geohashing
- getapr
- getpic
- getsvnfiles
- gfuck
- githubnetwork
- gotexp
- gpath
- gpgpakk
- gpsfold
- gpslist
- gpsman2gpx
- gpst
- gpst-file
- gpst-pic
- gptrans\_conv
- gq
- gqfav
- gqview
- grafkjent
- h2chin
- h2t
- h2u
- hentfilm
- hf
- hfa
- hhi
- hmsg
- href
- html2cgi
- html2db
- html2wiki
- htmlfold
- httplog
- hvor
- inc\_epstat
- irc-conn
- irssi
- isoname
- jday
- jsonfmt.py
- kar
- kbd
- keyw
- kl
- klokke
- konvflac
- l
- l33t
- lag3d
- lag\_gqv
- lag\_linker
- latlon
- line\_exec.py
- list-extensions
- list-tables
- list-youtube
- livecd-exit
- livecd-init
- ll
- log\_df
- log\_load
- logg
- logging
- lpar
- ls-broken
- lsreadable
- maileditor
- make\_tags
- makemesh
- manyfiles
- markdown
- mc
- mergesvn
- mime2txt
- mincvs\_vim
- mixline
- mixword
- mkFiles
- mkFiles\_rec
- mk\_local\_links
- mkcvsbck
- mkd
- mklist
- mkrepo
- mkt
- mktar
- mobilstripp
- mountusb
- mp3\_to\_ogg
- mtube
- multiapt
- mvdirnewest
- myf
- mymkdir
- n95film
- netgraph
- nettradio
- nf
- ngttest
- nogit
- nosvn
- ns
- oggname
- old-git
- outl
- p
- pakk
- pakk\_logg
- pakkings
- pakkut
- perldeboff
- perldebon
- perlfold
- personnr
- pget
- pgsafe
- pine
- pingstat
- plass
- pmsetdate
- po-merge.py
- poiformat
- pols
- posmap
- prearmor
- pri
- primitiv\_prompt
- purgewiki
- push-annex-sunbase
- pynt
- q3r
- r
- radiolagring
- random
- rcs-extract
- remove\_perltestnumbers
- rensk
- repo
- repodiffer
- repopuller
- reposurgeon
- rm\_backup
- rmdup
- rmheadtail
- rmspc
- rmspcall
- rmspcbak
- rmspcforan
- rmxmlcomm
- rot13
- roundgpx
- run-test
- scrdump
- scrplay
- sea-repo
- sess
- sget
- shellshock
- sident
- sj
- sjekk\_iso
- sjekkhtmlindent
- sjekkrand
- sjekksommer
- skipline
- skiptoplines
- slekt
- slogg
- smsum
- snu\_epstat
- sommer
- sortcvs
- sortxml
- split\_access\_log
- split\_ep-logg
- split\_log
- split\_md5
- spreadsheet
- src
- ssht
- sssh
- statplot
- std
- storelog
- stpl
- strip-conflict
- strip-nonexisting
- strip\_english
- strip\_msgstr
- sumdup
- sums
- sunnyrights
- suntodofold
- suuid
- svedit
- svn-po
- svnclean
- svndiff
- svnfiledate
- svnlog2tab
- svnrevs
- svnsize
- svnstat
- t
- t2h
- ta\_backup
- tab
- tail-errorlog
- tarsize
- telenorsms
- testfail
- tests
- til-ov
- tmux\_local\_install.sh
- todos
- togpx
- tohex
- tojson
- tolower
- tosec
- towav
- txt2uc
- txtfold
- u
- u2h
- uc
- uj
- unichar
- unicode\_htmlchart
- unik\_df
- unz
- uoversatt
- upd
- urlstrip
- usedchars
- ustr
- utc
- v
- vd
- vekt
- vg
- vgr – Run a command through Valgrind
- view\_df
- vx
- vy
- wav\_to\_flac
- wav\_to\_mp3
- wavto16
- wdiff
- wdisk
- wikipedia-export
- wlan-list
- wlan0
- wlan1
- wn
- wpt-dupdesc
- wpt-line
- wpt-rmsym
- xf
- xml-to-lisp
- xml2html
- xmlformat
- xmlstrip
- xt
- yd
- ydd
- youtube-dl
- zero-to-lf

----

    File ID: a8487d1c-1c4f-11e5-b5a1-398b4cddfd2b
    vim: set ts=2 sw=2 sts=2 tw=72 et fo=tcqw fenc=utf8 :
    vim: set com=b\:#,fb\:-,fb\:*,n\:> ft=markdown :
