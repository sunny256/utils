#!/usr/bin/perl -w

#===============================================================
# $Id$
# [Description]
#
# Character set: UTF-8
# License: GNU General Public License
# ©opyleft 2004 Øyvind A. Holm <sunny@sunbase.org>
#===============================================================

use strict;

$| = 1;

use Getopt::Std;
our ($opt_d, $opt_h, $opt_i, $opt_s, $opt_v) = ("", 0, 0, 0, 0);
getopts('h') || die("Option error. Use -h fopr help.");

$opt_h && usage(0);



sub usage {
	# Send the help message to stdout {{{
	my $Retval = shift;
	print(<<END);

Usage:

END
	exit($Retval);
	# }}}
}

__END__

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME



=head1 REVISION

$Id$

=head1 SYNOPSIS



=head1 DESCRIPTION



=head1 OPTIONS

=over 4

=item B<-h>

Print a brief help summary.

=back

=head1 BUGS



=head1 AUTHOR

Made by Øyvind A. Holm S<E<lt>sunny _AT_ sunbase.orgE<gt>>.

=head1 COPYRIGHT

Copyleft © Øyvind A. Holm &lt;sunny@sunbase.org&gt;
This is free software; see the file F<COPYING> for legalese stuff.

=head1 LICENCE

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=head1 SEE ALSO

=cut

# }}}

# vim: set fileencoding=UTF-8 filetype=perl foldmethod=marker foldlevel=0 :
# End of file $Id$
