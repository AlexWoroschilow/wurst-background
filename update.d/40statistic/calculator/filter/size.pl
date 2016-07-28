#!/usr/bin/perl
# Copyright 2015 Alex Woroschilow (alex.woroschilow@gmail.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
use v5.10;

use strict;
use warnings;
use FindBin;
use Data::Dumper;
use File::Copy;
use threads;
use Thread::Queue;
use strict;
use warnings;
use File::Basename;

require( dirname(__FILE__) . "/bootstrap.pl" );

sub main ( ) {

	my %clusters;

	foreach my $line (<STDIN>) {
		chomp($line);

		my ( $cluster, $index, $struct ) = split( /\s+/, $line );

		if ( defined( $clusters{"$cluster"} ) ) {
			$clusters{"$cluster"}++;
			next;
		}
		$clusters{"$cluster"} = 1;
	}

	my $max = 0;
	while ( my ( $cluster, $count ) = each(%clusters) ) {
		$max = $count if ( $count > $max );
	}

	return ("$max");
}

exit( not print( main() ) );
