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
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use JSON;
use File::Slurp;
use Log::Log4perl;
use Gearman::Client;
use Getopt::Lucid qw( :all );
use List::MoreUtils qw(zip);
use ZBH::File;
use Config::Simple;
use Data::Dumper qw(Dumper);
use Sys::Hostname;


sub connected($) {
  my $client = shift;
  my $response = $client->do_task( "ping", hostname );
  return defined($response);
}

sub main ($) {
  my $opt = shift;

  my $cfg = new Config::Simple( $opt->get_config );

  my $port               = $cfg->param("planner.port");
  my $host               = $cfg->param("planner.host");
  my $cluster            = $cfg->param("planner.cluster");
  my $source             = $cfg->param("planner.source");
  my $temp               = $cfg->param("planner.temp");
  my $output_bin         = $cfg->param("planner.output_bin");
  my $output_vec_6       = $cfg->param("planner.output_vec_6");
  my $output_vec_6_all   = $cfg->param("planner.output_vec_6_all");
  my $output_vec_7       = $cfg->param("planner.output_vec_7");
  my $output_vec_7_all   = $cfg->param("planner.output_vec_7_all");
  my $output_vec_tau     = $cfg->param("planner.output_vec_tau");
  my $output_vec_tau_all = $cfg->param("planner.output_vec_tau_all");
  my $class_vec_6         = $cfg->param("planner.class_vec_6");
  my $class_vec_7         = $cfg->param("planner.class_vec_7");
  my $output_list_lib    = $cfg->param("planner.outlist_lib");

  my $reconnect_timeout  = $cfg->param("planner.reconnect_timeout");
  my $reconnect_attempts = $cfg->param("planner.reconnect_attempts");

  Log::Log4perl->init( $opt->get_logger );
  my $logger = Log::Log4perl->get_logger("planner");

  $logger->debug( "Config: ",        $opt->get_config );
  $logger->debug( "Logger: ",        $opt->get_logger );
  $logger->debug( "Cluster: ",       $cluster );
  $logger->debug( "Source: ",        $source );
  $logger->debug( "Temp: ",          $temp );
  $logger->debug( "Output bin: ",    $output_bin );
  $logger->debug( "Output vec 6: ",   $output_vec_6 );
  $logger->debug( "Output vec 7: ",   $output_vec_7 );
  $logger->debug( "Output vec tau: ", $output_vec_tau );

  $logger->debug( "Class vec1: ",    $class_vec_6 );
  $logger->debug( "Class vec2: ",    $class_vec_7 );
  $logger->debug( "Pdb lib list file: ", $output_list_lib );

  my $attempt = 0;
  my $client  = Gearman::Client->new;
  $client->job_servers("$host:$port");
  while ( not connected($client) ) {
    $logger->debug("connect to server, attemption: $attempt");
    if ( $attempt >= $reconnect_attempts ) {
      $logger->debug("connect to server, attemption limit reached");
      return 0;
    }
    sleep($reconnect_timeout);
    $client = Gearman::Client->new;
    $client->job_servers("$host:$port");
    $attempt = $attempt + 1;
  }

  my $json  = JSON->new;
  my $tasks = $client->new_task_set;
  my $pdbfile = ZBH::File->new($logger);

  my $library_binary_lib = [];
  my $library_binary_all = [];
  # Read cluster from file and convert
  # each pdb file to binary file
  $pdbfile->cluster_each( $cluster, my $first, my $last, sub {
    my $acq = shift;
    my $chain  = shift;
    my $cluster_length = scalar(@$acq);
    my $cluster_string = join( ', ', @$acq );
    # This parameters should be pass through
    # a network, it may be http or something else
    # we do not know and can not be sure
    # so just encode to json with respect to order
    my $options = $json->encode([
      $acq,           # Pdb cluster
      $chain,         # Pdb cluster chains
      $source,        # Pdb files source folder
      $temp,          # Temporary folder to store unpacked pdb
      $output_bin,    # Folder to store binary files
      40,             # Minimal structure size
      1    	    # Should calculate all binary files for a cluster
    ]);

    $tasks->add_task( "cluster_to_bin" => $options, {
      on_fail => sub {
	$logger->error( "cluster_to_bin failed ", $cluster_string);
      },
      on_complete => sub {
	my $response = $json->decode( ${ $_[0] } );
	if ( scalar(@$response) ) {
	  push( $library_binary_lib, $$response[0] );
	  for ( my $i = 0 ; $i < @$response ; $i++ ) {
	    push( $library_binary_all, $$response[$i] );
	  }
	}
	$logger->debug( "cluster_to_bin success ", $cluster_string );
      }
    });
  });

  $tasks->wait;
  $logger->debug( "clusters to binary done");

  my $library_binary_lib_length = @$library_binary_lib;
  my $library_binary_all_length = @$library_binary_all;
  if(not $library_binary_lib_length or not $library_binary_all_length) {
      $logger->fatal( "Binary library should not be empty");
      return 0;
  }

  if (length($output_list_lib)) {
    $logger->debug( "write output_list_lib: $output_list_lib");
    my $string_lib = join( "\n", @$library_binary_lib );
    write_file( $output_list_lib, "$string_lib\n" );
  }

  my $library_vector_lib = [];
  foreach my $code (@$library_binary_lib){
    my $options = $json->encode( [
      $code,          #library record code
      $output_bin,    # source folder with binary structures
      $output_vec_6,  # destination folder for vector structures, version 1
      $output_vec_7,  # destination folder for vector structures, version 2
      $output_vec_tau,# destination folder for vector structures, version 2
      $class_vec_6,    # class file for vector structures, version 1
      $class_vec_7     # class file for vector structures, version 2
    ]);

    $tasks->add_task( "bin_to_vec" => $options, {
      on_fail => sub {
	$logger->error( "bin_to_vec failed ", $code );
      },
      on_complete => sub {
	$logger->debug( "bin_to_vec success ", $code );
	push( $library_vector_lib, $code );
      },
    });
  }

  $tasks->wait;

  if(not scalar(@$library_vector_lib)) {
    $logger->fatal( "Vector library is empty");
    return 0;
  }

  my $library_vector_all = [];
  foreach my $code (@$library_binary_all){
    my $options = $json->encode( [
      $code,         	#library record code
      $output_bin,   	# source folder with binary structures
      $output_vec_6_all,  # destination folder for vector structures, version 1
      $output_vec_7_all,  # destination folder for vector structures, version 2
      $output_vec_tau_all,# destination folder for vector structures, version 2
      $class_vec_6,   	# class file for vector structures, version 1
      $class_vec_7    	# class file for vector structures, version 2
    ]);

    $tasks->add_task( "bin_to_vec" => $options, {
      on_fail => sub {
	$logger->error( "bin_to_vec failed ", $code );
      },
      on_complete => sub {
	$logger->debug( "bin_to_vec done ", $code );
	push( $library_vector_all, $code );
      },
    });
  }

  $tasks->wait;

  if(not scalar(@$library_vector_all)) {
    $logger->fatal( "Vector library is empty");
    return 0;
  }

  # do not remove this line, this is an indicator
  # for other scripts that all tasks has been finished
  $logger->info( "wurst-vector done");

  return 0;
}

my @specs = (
  Param("--config")->default("$FindBin::Bin/../etc/vector.conf"),
  Param("--logger")->default("$FindBin::Bin/../etc/logger.conf"),
);

my $opt = Getopt::Lucid->getopt( \@specs );
$opt->validate( { 'requires' => [] } );

exit( main($opt) );

