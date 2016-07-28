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

sub cache {
	my $clusters = shift;

	my %cache;
	my @test = values( %{$clusters} );
	while ( my ( $index, $cluster ) = each(@test) ) {

		foreach my $seq_a (@$cluster) {
			foreach my $seq_b (@$cluster) {

				next if ( defined( $cache{"$seq_a$seq_b$index"} ) );
				next if ( defined( $cache{"$seq_b$seq_a$index"} ) );

				$cache{"$seq_a$seq_b$index"} = "$seq_a$seq_b";
			}
		}
	}
	return values(%cache);
}

sub main {
	my $file1 = shift;
	my $file2 = shift;

	die("First cluster file should be defined")
	  if ( not defined($file1) );

	die("Second cluster file should be defined")
	  if ( not defined($file2) );

	my %clustering1 = get_clusters($file1);
	my @cache1      = cache( \%clustering1 );

	my %clustering2 = get_clusters($file2);
	my @cache2      = cache( \%clustering2 );

	my $intersection = 0;
	my %cache2 = map { $_ => 1 } @cache2;
	foreach my $pair (@cache1) {
		$intersection++ if ( defined( $cache2{"$pair"} ) );
	}

	return ( ( ( $intersection / scalar(@cache1) ) * 100 ) );
}

exit( not print( main( $ARGV[0], $ARGV[1] ) ) );
