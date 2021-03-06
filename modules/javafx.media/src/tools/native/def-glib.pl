#!/usr/bin/perl -w

#
# Copyright (c) 2015, 2021, Oracle and/or its affiliates. All rights reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
#
# This code is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 2 only, as
# published by the Free Software Foundation.  Oracle designates this
# particular file as subject to the "Classpath" exception as provided
# by Oracle in the LICENSE file that accompanied this code.
#
# This code is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# version 2 for more details (a copy is included in the LICENSE file that
# accompanied this code).
#
# You should have received a copy of the GNU General Public License version
# 2 along with this work; if not, write to the Free Software Foundation,
# Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
# or visit www.oracle.com if you need additional information or have any
# questions.
#

my @files = ("../../main/native/gstreamer/3rd_party/glib/build/win32/vs100/glib-lite.def");

foreach $file (@files)
{
	process_file($file);
}

sub process_file
{
	my $infile = shift(@_);
	my %symbols = ();
	my $duplicates = 0;

	print ("Processing file $infile\n");
	open(INFILE, $infile) or die $!;

	while (my $str = <INFILE>)
	{
		$str =~ tr/\r\n//d;

		if ($str !~ /^EXPORTS/ && $str =~ /(\w+)/)
		{
			if (exists( $symbols{$1}))
			{
				$duplicates++;
				$symbols{$1}++;
			}
			else
			{
				$symbols{$1} = 1;
			}
		}
	}
	close(INFILE);

	my ($tmpfile) = $infile . ".tmp";
	print("Found $duplicates duplicates.\nSaving results to: $tmpfile\n");

	my $ordinal = 1;
	open(OUTFILE, ">$tmpfile") or die $!;
	print OUTFILE "EXPORTS\r\n";
	foreach $symbol (sort keys(%symbols))
	{
		print OUTFILE "${symbol}\t\@${ordinal}\tNONAME\r\n";
#		print OUTFILE "${symbol}\r\n";
		$ordinal++;
	}

	close(OUTFILE);

	print("Renaming $tmpfile to $infile\n\n");
	rename($tmpfile, $infile);
}
