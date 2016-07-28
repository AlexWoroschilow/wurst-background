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
use FindBin;
use lib "$FindBin::Bin/../../../lib/perl";
use ZBH::SGE;
use ZBH::Local;
use ZBH::Flensburg;

use Config::Simple;
use Log::Log4perl;

sub main {
	my $file    = shift;
	my $logging = shift;

	my $max  = shift;
	my $intersection = shift;
	my $size  = shift;

	Log::Log4perl->init($logging);
	my $logger = Log::Log4perl->get_logger("40statistic");

	my $config = new Config::Simple($file);

	my $cath_eval = $config->param("cath.eval");
	my $cath_clust = $config->param("cath.clust");

	my $scop_eval = $config->param("scop.eval");
	my $scop_clust = $config->param("scop.clust");

	my $pdb50_eval = $config->param("pdb50.eval");
	my $pdb50_clust = $config->param("pdb50.clust");

	my $pdb90_eval = $config->param("pdb90.eval");
	my $pdb90_clust = $config->param("pdb90.clust");

	my $salami_eval = $config->param("salami.eval");
	my $salami_clust = $config->param("salami.clust");

	say("name;size;max;tm_score;seq_id;rmsd;cath;scop;pdb50;pdb90;salami");

	my $cath_max = `cat $cath_clust | $max`;
	my $cath_size = `cat $cath_clust | $size`;
	my $cath_cath = `$intersection $cath_clust $cath_clust`;
	my $cath_scop = `$intersection $cath_clust $scop_clust`;
	my $cath_pdb50 = `$intersection $cath_clust $pdb50_clust`;
	my $cath_pdb90 = `$intersection $cath_clust $pdb90_clust`;	
	my $cath_salami = `$intersection $cath_clust $salami_clust`;
	say("cath;$cath_size;$cath_max;tm_score;seq_id;rmsd;$cath_cath;".
			"$cath_scop;$cath_pdb50;$cath_pdb90;$cath_salami");

	my $scop_max = `cat $scop_clust | $max`;
	my $scop_size = `cat $scop_clust | $size`;
	my $scop_cath = `$intersection $scop_clust $cath_clust`;
	my $scop_scop = `$intersection $scop_clust $scop_clust`;
	my $scop_pdb50 = `$intersection $scop_clust $pdb50_clust`;
	my $scop_pdb90 = `$intersection $scop_clust $pdb90_clust`;	
	my $scop_salami = `$intersection $scop_clust $salami_clust`;
	say("scop;$cath_size;$scop_max;tm_score;seq_id;rmsd;$scop_cath;".
			"$scop_scop;$scop_pdb50;$scop_pdb90;$scop_salami");

	my $pdb50_max = `cat $pdb50_clust | $max`;
	my $pdb50_size = `cat $pdb50_clust | $size`;
	my $pdb50_cath = `$intersection $pdb50_clust $cath_clust`;
	my $pdb50_scop = `$intersection $pdb50_clust $scop_clust`;
	my $pdb50_pdb50 = `$intersection $pdb50_clust $pdb50_clust`;
	my $pdb50_pdb90 = `$intersection $pdb50_clust $pdb90_clust`;	
	my $pdb50_salami = `$intersection $pdb50_clust $salami_clust`;
	say("pdb50;$pdb50_size;$pdb50_max;tm_score;seq_id;rmsd;$pdb50_cath;".
			"$pdb50_scop;$pdb50_pdb50;$pdb50_pdb90;$pdb50_salami");

	my $pdb90_max = `cat $pdb90_clust | $max`;
	my $pdb90_size = `cat $pdb90_clust | $size`;
	my $pdb90_cath = `$intersection $pdb90_clust $cath_clust`;
	my $pdb90_scop = `$intersection $pdb90_clust $scop_clust`;
	my $pdb90_pdb50 = `$intersection $pdb90_clust $pdb50_clust`;
	my $pdb90_pdb90 = `$intersection $pdb90_clust $pdb90_clust`;	
	my $pdb90_salami = `$intersection $pdb90_clust $salami_clust`;
	say("pdb90;$pdb90_size;$pdb90_max;tm_score;seq_id;rmsd;$pdb90_cath;".
			"$pdb90_scop;$pdb90_pdb50;$pdb90_pdb90;salami");

	my $salami_max = `cat $salami_clust | $max`;
	my $salami_size = `cat $salami_clust | $size`;
	my $salami_cath = `$intersection $salami_clust $cath_clust`;
	my $salami_scop = `$intersection $salami_clust $scop_clust`;
	my $salami_pdb50 = `$intersection $salami_clust $pdb50_clust`;
	my $salami_pdb90 = `$intersection $salami_clust $pdb90_clust`;
	my $salami_salami = `$intersection $salami_clust $salami_clust`;
	say("salami;$salami_size;$salami_max;tm_score;seq_id;rmsd;$salami_cath;".
			"$salami_scop;$salami_pdb50;$salami_pdb90;$salami_salami");
}

exit(
	not print(
		main(
			"$FindBin::Bin/../../../etc/40statistic.conf",
			"$FindBin::Bin/../../../etc/logging.conf",
			"$FindBin::Bin/filter/size.pl",
			"$FindBin::Bin/filter/intersect.pl",
			"$FindBin::Bin/filter/count.pl"			
		  )
	)
);
