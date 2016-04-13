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
package ZBH::Local;
@EXPORT = qw(is_background_process);
use strict;
use warnings;
use Data::Dump qw( dump pp );

sub is_file_exists {
	my $file = shift;
	return ( ( -d $file ) || ( -e $file ) );
}

sub is_folder_empty {
	opendir( DIR, shift ) or die $!;
	my @files = grep { !m/\A\.{1,2}\Z/ } readdir(DIR);
	closedir(DIR);
	@files ? 0 : 1;
}

sub is_folder_exists {
	my $folder = shift;
	return is_file_exists($folder);
}

sub is_background_process ($) {
	my $starter = shift;
	my $result = `ps aux`;

	return ( index( $result, $starter ) > -1 );
}

1;
