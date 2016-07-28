#!/usr/bin/perl

use strict;
use warnings;
use List::MoreUtils qw(any);
use File::Copy qw(copy);
use lib "/work/public/bm/salamiServer";
use Salamisrvini;

use lib $LIB_LIB;     #initialize in local Salamisrvini.pm;
use lib $LIB_ARCH;    #initialize in local Salamisrvini.pm;

use Wurst;

# Remove empty spaces
# at start and at the end of
# given string
sub trim {
	my $s = shift;
	$s =~ s/^\s+|\s+$//g;
	return $s;
}

# Parse cluster string
# to cluster fields
sub get_fields ($) {
	my $string = shift;
	return split( /\s+/, $string );
}

# Parse cluster file and get
# associative array pro cluster
# with structures
sub get_clusters($) {
	my $file = shift;

	die("cannot open file $file\n")
	  if ( not open( STREAM, $file ) );

	my %cache = ();
	while ( my $temp = <STREAM> ) {
		my ( $cluster, $id, $structure ) = get_fields($temp);
		if ( not exists( $cache{$cluster} ) ) {
			$cache{$cluster} = [];
		}
		push( @{ $cache{$cluster} }, $structure );
	}

	close(STREAM) or warn "Cannot close $file";

	return %cache;
}

return 1;
