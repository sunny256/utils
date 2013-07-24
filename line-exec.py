#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""line-exec.py - Send all lines from stdin to specified programs

Reads from stdin and sends every line to the program(s) specified on the 
command line.

File ID: 0a869b50-f45a-11e2-bb76-a088b4ddef28
License: GNU General Public License version 3 or later.

"""

import sys
import subprocess

def exec_line(line, args):
    for cmd in args:
        pipe = subprocess.Popen(cmd, stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (stdout, stderr) = pipe.communicate(line)
        sys.stdout.write(stdout)

def main(args = None):
    from optparse import OptionParser
    parser = OptionParser()
    (opt, args) = parser.parse_args()

    fp = sys.__stdin__
    line = fp.readline()
    while line:
        exec_line(line, args)
        line = fp.readline()

if __name__ == "__main__":
    main()
