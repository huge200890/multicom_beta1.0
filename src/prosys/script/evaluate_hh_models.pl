#!/usr/bin/perl -w
##########################################################################
#Evaluate structure models generated by multicom-cm or multicom-hhsearch
#Input: prosys_dir, model dir, output file 
#model_name, top_template name, coverage of top,
#identity of top, blast-evalue,  
#Author: Jianlin Cheng
#Start date: 3/3/2008
##########################################################################  

sub round
{
	my $value = $_[0];
	$value = int($value * 100) / 100;
	return $value;
}

if (@ARGV != 4)
{
	die "need four parameters: prosys dir, model dir, target name, output file.\n";
}

$prosys_dir = shift @ARGV;
$model_dir = shift @ARGV;
$target_name = shift @ARGV;
$out_file = shift @ARGV;

-d $prosys_dir || die "can't find $prosys_dir.\n";

opendir(MOD, $model_dir) || die "can't read $model_dir.\n";
@files = readdir MOD;
closedir MOD;
@pdb_files = ();
@models = ();
while (@files)
{
	$file = shift @files;
	if ($file =~ /(.+)\.pdb$/)
	{
		$prefix = $1;
	}
	else
	{
		next;
	}

	if ($file !~ /^cm(\d*)\.pdb/ && $file !~ /^hh(\d*)\.pdb/)
	{
		next;
	}
	
	push @pdb_files, $file;


	$pir_file = "$model_dir/$prefix.pir";

	if (-f $pir_file)
	{
		open(PIR, $pir_file) || die "can't read $pir_file.\n";
		@pir = <PIR>;
		close PIR;

		#get blast or hhsearch evalue of the top template
		$comment = $pir[0];
		@fields = split(/\s+/, $comment);
		$blast_evalue = $fields[11];


		$title = $pir[1];
		chomp $title;
		@fields = split(/;/, $title);
		$temp_name = $fields[1];
		$talign = $pir[3];
		$qalign = $pir[$#pir];

		#get coverage and identity
		chomp $talign;
		chop $talign;

		chomp $qalign;
		chop $qalign;

		$qlen = 0;
		$align_len = 0;
		$coverage = 0;
		$identity = 0;

		$len = length($qalign);
		for ($i = 0; $i < $len; $i++)
		{
			$qaa = substr($qalign, $i, 1);	
			$taa = substr($talign, $i, 1);	

			if ($qaa ne "-")
			{
				$qlen++;
				if ($taa ne "-")
				{
					$align_len++;	
					if ($qaa eq $taa)
					{
						$identity++;
					}
				}
			}
		}

		$coverage = $align_len / $qlen;
		$identity = $identity / $align_len;
	}
	else
	{
		$coverage = "N/A";
		$identity = "N/A";	
	}
	
	#get number of clashes
	$clash = 0;
	$servere = 0;
	$out = `$prosys_dir/script/clash_check.pl $model_dir/$target_name $model_dir/$file`; 
	if (defined $out)
	{
		@fields = split(/\n/, $out);
		while (@fields)
		{
			$line = shift @fields;
			if ($line =~ /^clash/)
			{
				$clash++;
			}
			if ($line =~ /^servere/ || $line =~ /^overlap/)
			{
				$servere++;
			}
		}
	}
	else
	{
		$clash = 0;
		$servere = 0;
	}

	push @models, {
		name => $file,
		template => $temp_name,
		coverage => $coverage,
		identity => $identity,
		blast_evalue => $blast_evalue, #valid for comparative models
		reg_clashes => $clash,
		ser_clashes => $servere
	} 
			
}

#sort by model names 
@rank_models = sort {$a->{"name"} cmp $b->{"name"}} @models;

open(OUT, ">$out_file");

print OUT "name\t\ttemp\tcov\tident\tblast_e\treg_cla\tser_cla\n";
$prev_temp = "";
for ($i = 0; $i < @rank_models; $i++)
{

	print OUT $rank_models[$i]{"name"}, "\t\t";
	print OUT $rank_models[$i]{"template"}, "\t";
	print OUT &round($rank_models[$i]{"coverage"}), "\t";
	print OUT &round($rank_models[$i]{"identity"}), "\t";
	print OUT $rank_models[$i]{"blast_evalue"}, "\t";
	print OUT $rank_models[$i]{"reg_clashes"}, "\t";
	print OUT $rank_models[$i]{"ser_clashes"}, "\n";

	$rclashes = $rank_models[$i]{"reg_clashes"};
	$sclashes = $rank_models[$i]{"ser_clashes"};

	
	if ( ($rank_models[$i]{"blast_evalue"} eq "0" || $rank_models[$i]{"blast_evalue"} =~ /^0+\.0+$/) && $rank_models[$i]{"coverage"} > 0.70 && $rclashes < 15 && $sclashes < 1)
	{
		#print out selected models

		if ($rank_models[$i]{"template"} ne $prev_temp)
		{
			print $rank_models[$i]{"name"}, "\t";
			print $rank_models[$i]{"template"}, "\t";
			print &round($rank_models[$i]{"coverage"}), "\t";
			print &round($rank_models[$i]{"identity"}), "\t";
			print $rank_models[$i]{"blast_evalue"}, "\t";
			print $rank_models[$i]{"reg_clashes"}, "\t";
			print $rank_models[$i]{"ser_clashes"}, "\n";
			$prev_temp = $rank_models[$i]{"template"};
		}

	}
	elsif ($rank_models[$i]{"blast_evalue"} =~ /[Ee](-\d+)/ && $rclashes < 15 && $sclashes < 1)
	{
		if ($1 < -15 && $rank_models[$i]{"coverage"} > 0.65)
		{

			if ($rank_models[$i]{"template"} ne $prev_temp)
			{

				print $rank_models[$i]{"name"}, "\t";
				print $rank_models[$i]{"template"}, "\t";
				print &round($rank_models[$i]{"coverage"}), "\t";
				print &round($rank_models[$i]{"identity"}), "\t";
				print $rank_models[$i]{"blast_evalue"}, "\t";
				print $rank_models[$i]{"reg_clashes"}, "\t";
				print $rank_models[$i]{"ser_clashes"}, "\n";
				$prev_temp = $rank_models[$i]{"template"};
			}
		}
	}

}
		
close OUT;


