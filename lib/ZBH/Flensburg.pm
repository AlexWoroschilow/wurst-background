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
package ZBH::Flensburg;

@EXPORT = qw(failure);

use warnings;
use Data::Dump qw( dump pp );

use FindBin;
use lib "$FindBin::Bin/..";
use Net::SCP qw(scp iscp);

sub new {
    my $class = shift;

    my $self = {
        _logger => shift,
        _host => "flensburg",
        _user => "wurst"
    };
    
	bless( $self, $class );
    
    return $self;
}


sub failure($ $ $ $) {
	my $self			   = shift;
	my $task_name          = shift;
	my $task_status        = "failure";
	my $task_status_notice = shift;
	my $task_status_error  = shift;
	my $task_status_fatal  = "";
	my $task_status_log    = "";
	my $task_date          = time;

	my $file = response_file_xml(
		$task_name,         $task_status,       $task_status_notice,
		$task_status_error, $task_status_fatal, $task_status_log,
	);

	$self->{_logger}->debug("Failure fatal file to flensburg: $file");
	if ( $self->transport_to_flensburg($file) ) {
		$self->{_logger}->debug("Failure file sent to flensburg: $file");
		unlink($file);
		return 1;
	}
	$self->{_logger}->error("Failure file does not sent: $file");
	return 0;
}

sub fatal($ $ $ $) {
	my $self			   = shift;
	my $task_name          = shift;
	my $task_status        = "fatal";
	my $task_status_notice = shift;
	my $task_status_error  = "";
	my $task_status_fatal  = shift;
	my $task_status_log    = "";
	my $task_date          = time;

	my $file = response_file_xml(
		$task_name,         $task_status,       $task_status_notice,
		$task_status_error, $task_status_fatal, $task_status_log,
	);

	$self->{_logger}->debug("Sending fatal file to flensburg: $file");
	if ( $self->transport_to_flensburg($file) ) {
		$self->{_logger}->debug("Fatal file sent to flensburg: $file");
		unlink($file);
		return 1;
	}
	$self->{_logger}->error("Fatal file does not sent: $file");
	return 0;
}


sub success($ $ $ $) {
	my $self			   = shift;
	my $task_name          = shift;
	my $task_status        = "success";
	my $task_status_notice = shift;
	my $task_status_error  = "";
	my $task_status_fatal  = "";
	my $task_status_log    = shift;
	my $task_date          = time;

	my $file = response_file_xml(
		$task_name,         $task_status,       $task_status_notice,
		$task_status_error, $task_status_fatal, $task_status_log,
	);

	$self->{_logger}->debug("Sending success file to flensburg: $file");
	if ( $self->transport_to_flensburg($file) ) {
		$self->{_logger}->debug("Success file sent to flensburg: $file");
		unlink($file);
		return 1;
	}
	$self->{_logger}->error("Success file does not sent: $file");
	return 0;
}

sub pending($ $ $ $) {
	my $self			   = shift;
	my $task_name          = shift;
	my $task_status        = "pending";
	my $task_status_notice = shift;
	my $task_status_error  = shift;
	my $task_status_fatal  = "";
	my $task_status_log    = "";
	my $task_date          = time;

	my $file = response_file_xml(
		$task_name,         $task_status,       $task_status_notice,
		$task_status_error, $task_status_fatal, $task_status_log,
	);

	$self->{_logger}->debug("Sending pending file to flensburg: $file");
	if ( $self->transport_to_flensburg($file) ) {
		$self->{_logger}->debug("Pending file sent to flensburg: $file");
		unlink($file);
		return 1;
	}
	$self->{_logger}->error("Pending file does not sent: $file");
	return 0;
}

sub info($ $ $ $) {
	my $self			   = shift;
	my $task_name          = shift;
	my $task_status        = "info";
	my $task_status_notice = shift;
	my $task_status_error  = "";
	my $task_status_fatal  = "";
	my $task_status_log    = shift;
	my $task_date          = time;

	my $file = response_file_xml(
		$task_name,         $task_status,       $task_status_notice,
		$task_status_error, $task_status_fatal, $task_status_log,
	);

	$self->{_logger}->debug("Sending info file to flensburg: $file");
	if ( $self->transport_to_flensburg($file) ) {
		$self->{_logger}->debug("Info file sent to flensburg: $file");
		unlink($file);
		return 1;
	}
	$self->{_logger}->error("Info file does not sent: $file");
	return 0;
}



sub transport_to_flensburg ($ $ ) {
	my $self = shift;
	my $source = shift;
	my $date   = time;

    my $host = $self->{_host};
    my $user = $self->{_user};
   
	my $scp = Net::SCP->new( $host, $user );
	if($scp->put( $source, "/home/other/wurst/wurst_rss/xml/status-$date.xml")) {
		$self->{_logger}->info("Status file sent: $host@$user");
		return 1;
	}
	$self->{_logger}->error("$host@$user: " . $scp->{errstr});
	return 0;
}

sub response_file_xml ($ $ $ $ $ $) {
	my $task_name          = shift;
	my $task_status        = shift;
	my $task_status_notice = shift;
	my $task_status_error  = shift;
	my $task_status_fatal  = shift;
	my $task_status_log    = shift;
	my $task_date          = time;

	my $filename = "/tmp/wurst-update-status-$task_date.xml";
	open( my $stream, '>', $filename )
	  or die ("Could not open file '$filename' $!");

	print $stream <<"END_MESSAGE";
<?xml version="1.1" encoding="UTF-8" ?>
<response>
<task>$task_name</task>
<date>$task_date</date>
<status>$task_status</status>
<notice><![CDATA[$task_status_notice]]></notice>
<error><![CDATA[$task_status_error]]></error>
<fatal><![CDATA[$task_status_fatal]]></fatal>
<log><![CDATA[$task_status_log]]></log>
</response>
END_MESSAGE
	close $stream;
	return $filename;
}

1;
