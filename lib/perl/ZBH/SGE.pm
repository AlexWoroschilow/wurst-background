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
package ZBH::SGE;
@EXPORT    = qw(is_background_process is_background_process_sge is_background_process_started_sge is_background_process_done is_background_process_status);
use strict;
use warnings;
use Data::Dump qw( dump pp );

sub start ($) {
    my $command = shift;    
    system("nohup $command >/dev/null 2>&1 &");
}


sub in_background($) {
	my $starter = shift;
	my $name = substr( $starter, rindex( $starter, "/" ) + 1 );
	my $result = `qstat -r -ext 2>/dev/null`;
	return ( index( $result, $name ) > -1 );
}

sub is_background_process_done ($ $) {
	my $logfile   = shift;
	my $keystring = shift;

	return 0 if (not is_file_exists($logfile));	

	my $result = `tail -n 2 $logfile 2>/dev/null`;
	return ( index( $result, $keystring ) > -1 );
}

sub is_background_process_status ($ $) {
	my $logfile   = shift;
	my $keystring = shift;

	return 0 if (not is_file_exists($logfile));	

	my $result = `tail -n 2 $logfile`;
	return ( index( $result, $keystring ) > -1 );
}

1;
