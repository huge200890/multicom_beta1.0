#!/usr/bin/perl -w

##########################################################################
#The main script of template-based modeling using muster 
#Inputs: option file, fasta file, output dir.
#Outputs: muster output file, local alignment file, pir file,
#         pdb file (if available, and log file
#Author: Jianlin Cheng
#Modifided tm_hhpred_main.pl 
#Date: 11/23/2011
##########################################################################

if (@ARGV != 3)
{
	die "need three parameters: option file, sequence file, output dir.\n"; 
}

$option_file = shift @ARGV;
$fasta_file = shift @ARGV;
$work_dir = shift @ARGV;

#make sure work dir is a full path (abosulte path)
$cur_dir = `pwd`;
chomp $cur_dir; 
#change dir to work dir
if ($work_dir !~ /^\//)
{
	if ($work_dir =~ /^\.\/(.+)/)
	{
		$work_dir = $cur_dir . "/" . $1;
	}
	else
	{
		$work_dir = $cur_dir . "/" . $work_dir; 
	}
	print "working dir: $work_dir\n";
}
-d $work_dir || die "working dir doesn't exist.\n";

`cp $fasta_file $work_dir`; 
`cp $option_file $work_dir`; 
chdir $work_dir; 

#take only filename from fasta file
$pos = rindex($fasta_file, "/");
if ($pos >= 0)
{
	$fasta_file = substr($fasta_file, $pos + 1); 
}

#read option file
$pos = rindex($option_file, "/");
if ($pos > 0)
{
	$option_file = substr($option_file, $pos+1); 
}
open(OPTION, $option_file) || die "can't read option file.\n";
$prosys_dir = "";
$blast_dir = "";
$modeller_dir = "";
$pdb_db_dir = "";
$nr_dir = "";
$atom_dir = "";
$psipred_dir = "";
#initialized with default values
$cm_blast_evalue = 1;
$cm_align_evalue = 1;
$cm_max_gap_size = 20;
$cm_min_cover_size = 20;
$pulchra = "";

$cm_comb_method = "new_comb";
$cm_model_num = 5; 

$cm_max_linker_size=10;
$cm_evalue_comb=0;

$adv_comb_join_max_size = -1; 

#options for sorting local alignments
$sort_blast_align = "no";
$sort_blast_local_ratio = 2;
$sort_blast_local_delta_resolution = 2;
$add_stx_info_rm_identical = "no";
$rm_identical_resolution = 2;

$cm_clean_redundant_align = "no";

$cm_evalue_diff = 1000; 


#for muster search
$muster_dir = "";
$itasser_dir = "";

while (<OPTION>)
{
	$line = $_; 
	chomp $line;

	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
		$script_dir = "$prosys_dir/script";
	}

	if ($line =~ /^blast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_dir = $value; 
	}
	if ($line =~ /^modeller_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$modeller_dir = $value; 
	}
	if ($line =~ /^pdb_db_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pdb_db_dir = $value; 
	}
	if ($line =~ /^nr_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_dir = $value; 
	}
	if ($line =~ /^atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$atom_dir = $value; 
	}

	if ($line =~ /^muster_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$muster_dir = $value; 
	}

	if ($line =~ /^itasser_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$itasser_dir = $value; 
	}

	if ($line =~ /^meta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_dir = $value; 
	}

	if ($line =~ /^pulchra/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pulchra = $value; 
	}

	if ($line =~ /^meta_common_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_common_dir = $value; 
	}

	if ($line =~ /^psipred_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$psipred_dir = $value; 
	}

	if ($line =~ /^cm_blast_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_blast_evalue = $value; 
	}
	if ($line =~ /^cm_align_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_align_evalue = $value; 
	}
	if ($line =~ /^cm_max_gap_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_max_gap_size = $value; 
	}
	if ($line =~ /^cm_min_cover_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_min_cover_size = $value; 
	}
	if ($line =~ /^cm_model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_model_num = $value; 
	}

	if ($line =~ /^cm_max_linker_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_max_linker_size = $value; 
	}

	if ($line =~ /^cm_evalue_comb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_evalue_comb = $value; 
	}

	if ($line =~ /^cm_comb_method/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_comb_method = $value; 
	}

	if ($line =~ /^adv_comb_join_max_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$adv_comb_join_max_size = $value; 
	}

	if ($line =~ /^chain_stx_info/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$chain_stx_info = $value; 
	}

	if ($line =~ /^sort_blast_align/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_align = $value; 
	}

	if ($line =~ /^sort_blast_local_ratio/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_local_ratio = $value; 
	}

	if ($line =~ /^sort_blast_local_delta_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_local_delta_resolution = $value; 
	}

	if ($line =~ /^add_stx_info_rm_identical/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$add_stx_info_rm_identical = $value; 
	}

	if ($line =~ /^rm_identical_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rm_identical_resolution = $value; 
	}

	if ($line =~ /^cm_clean_redundant_align/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_clean_redundant_align = $value; 
	}

	if ($line =~ /^cm_evalue_diff/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_evalue_diff = $value; 
	}
	if ($line =~ /^nr_iteration_num/)
	{
		$nr_iteration_num = ""; 
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_iteration_num = $value; 
	}
	if ($line =~ /^nr_return_evalue/)
	{
		$nr_return_evalue = ""; 
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_return_evalue = $value; 
	}
	if ($line =~ /^nr_including_evalue/)
	{
		$nr_including_evalue = ""; 
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_including_evalue = $value; 
	}

}

#check the options
-d $script_dir || die "can't find script dir: $script_dir.\n"; 
-d $blast_dir || die "can't find blast dir.\n";
-d $modeller_dir || die "can't find modeller_dir.\n";
-d $pdb_db_dir || die "can't find pdb database dir.\n";
-d $muster_dir || die "can't find muster dir.\n";
-d $itasser_dir || die "can't find itasser dir.\n";
-d $psipred_dir || die "can't find psipred dir.\n"; 
-d $nr_dir || die "can't find nr dir.\n";
-d $atom_dir || die "can't find atom dir.\n";
-d $meta_dir || die "can't find $meta_dir.\n";
-d $meta_common_dir || die "can't find $meta_common_dir.\n";
-f $pulchra || die "can't find program $pulchra\n";

if ($cm_blast_evalue <= 0 || $cm_blast_evalue >= 10 || $cm_align_evalue <= 0 || $cm_align_evalue >= 10)
{
	die "blast evalue or align evalue is out of range (0,10).\n"; 
}
#if ($cm_max_gap_size <= 0 || $cm_min_cover_size <= 0)
if ($cm_min_cover_size <= 0)
{
	die "max gap size or min cover size is non-positive. stop.\n"; 
}
if ($cm_model_num < 1)
{
	die "model number should be bigger than 0.\n"; 
}

if ($cm_evalue_comb > 0)
{
#	die "the evalue threshold for alignment combination must be <= 0.\n";
}

if ($sort_blast_align eq "yes")
{
	if (!-f $chain_stx_info)
	{
		warn "chain structural information file doesn't exist. Don't sort blast local alignments.\n";
		$sort_blast_align = "no";
	}
}

if ($add_stx_info_rm_identical eq "yes")
{
	if (!-f $chain_stx_info)
	{
		warn "chain structural information file doesn't exist. Don't add structural information to alignments.\n";
		$add_stx_info_rm_identical = "no";
	}
}

if ($sort_blast_local_ratio <= 1 || $sort_blast_local_delta_resolution <= 0)
{
		warn "sort_blast_local_ratio <= 1 or delta resolution <= 0. Don't sort blast local alignments.\n";
		$sort_blast_align = "no";
}
if ($rm_identical_resolution <= 0)
{
	warn "rm_identical_resolution <= 0. Don't add structure information and remove identical alignments.\n";
	$add_stx_info_rm_identical = "no";
}

#check fast file format
open(FASTA, $fasta_file) || die "can't read fasta file.\n";
$name = <FASTA>;
chomp $name; 
$seq = <FASTA>;
chomp $seq;
close FASTA;
if ($name =~ /^>/)
{
	$name = substr($name, 1); 
}
else
{
	die "fasta foramt error.\n"; 
}



################################################################
#use muster to identify templates
#################################################################

print "Use muster to do fold recognition...\n";
`cp $fasta_file $work_dir/seq.fasta`; 
open(ERR, ">err.log") || die "can't create err.log file.\n";
print ERR "Start to run TASSER...\n";

if ($itasser_dir =~ /3\.0/)
{
	print "Run itasser 3.0...\n";
	system("$itasser_dir/I-TASSERmod/runMUSTER.pl -pkgdir $itasser_dir -libdir $itasser_dir -seqname $name -datadir $work_dir -usrname chengji"); 
}
else
{
	print "Run $itasser_dir ...\n";
	system("$itasser_dir/I-TASSERmod/runMUSTER.pl -pkgdir $itasser_dir -libdir $itasser_dir/ITLIB -seqname $name -datadir $work_dir"); 
}

print ERR "Finish running TASSER.\n";


#generate ranking list, and parse the output into local alignment format
#open(INIT, "initres.MUSTER") || die "can't read initres.MUSTER\n";
if (!open(INIT, "initres.MUSTER"))
{
	print ERR "Can't open initres.MUSTER file. Probably fail to execute runMUSTER.pl\n";

	close ERR; 
	die "can't read initres.MUSTER\n";
}

@init = <INIT>;
close INIT;
shift @init; 

#open(RANK, ">$name.rank") ||die "can't create $name.rank.\n";
if (!open(RANK, ">$name.rank"))
{
	print ERR "Can't create $name.rank\n";
	close ERR;

	die "can't create $name.rank.\n";
}


print RANK "Rank templates for $name\n";
while (@init)
{
	$entry = shift @init;
	if ($entry =~ /^\s+(\S.+)$/)
	{
		@fields = split(/\s+/, $1); 
		$id = shift @fields;
		$tname = shift @fields;
		$tname = uc($tname);
		$tname = substr($tname, 0, 5); 
		print RANK "$id\t$tname\t", join("\t", @fields), "\n"; 
	}
}
close RANK; 

#filter muster ranking
system("$meta_dir/script/filter_rank.pl $pdb_db_dir/pdb_cm $name.rank $name.filter.rank"); 

if (! -f "$name.filter.rank")
{
	print ERR "can't find $name.filter.rank\n";
}
print ERR "$name.filter.rank is successfully created.\n";

#convert alignment file into pir format
for ($i = 1; $i <= 10; $i++)
{
	$org_align = "align_MUSTER_$i.txt";
	$new_pir = "muster$i.pir";
	$atom_file = "threading_MUSTER_$i.pdb";

	print ERR "Generate muster$i.pir...\n";
	if (! -f $org_align)
	{
		print ERR "$org_align does not exist, fail to generate the model.\n";
		next;
	}

	open(ORG, $org_align) || die "can't read $org_align\n";
	@org = <ORG>;
	close ORG;

	#get target sequence
	$target = "";
	while (@org)
	{
		$line = shift @org;
		chomp $line; 
		if (substr($line, 0, 1) eq ">")
		{
			next;
		}
		if (substr($line, 0, 3) eq "seq")
		{
			next;
		}
		if ($line =~/\*$/)
		{
			#last line
			chop $line;
			$target .= $line;	
			last;
		}
		#sequence line
		$target .= $line;
	}

	$ini_target = $target; 

	#get template sequence
	$template_align = "";
	$template_id = "";
	while (@org)
	{
		$line = shift @org;
		chomp $line; 
		if (substr($line, 0, 1) eq ">")
		{
			$template_id = substr($line, 4, 5); 
			$template_id = uc($template_id); 
			next;
		}
		if (substr($line, 0, 4) eq "stru")
		{
			@ini_fields = split(/:/, $line);	
			$ini_name = substr(uc($ini_fields[1]), 0, 5); 
			next;
		}
		if ($line =~/\*$/)
		{
			chop $line;
			$template_align .= $line;	
			last;
		}
		$template_align .= $line;
	}

	$ini_template = $template_align; 

	if ($i < 10)
	{
		$temp_id = "MU0${i}A";
	}
	else
	{
		$temp_id = "MU${i}A";
	}
	
	#get length of the template sequence

	#do a pairwise copy
	if (length($target) != length($template_align))
	{
		next;
	}
	$talign = "";
	for($j = 0; $j < length($target); $j++)
	{
		$aa = substr($target, $j, 1);
		$bb = substr($template_align, $j, 1);		
		if ($aa eq "-")
		{
			$talign .= "-";	
		}
		elsif ($bb eq "-")
		{
			$talign .= "-"; 
		}
		else
		{
			$talign .= $aa; 
		}
	}

	#remove both gaps
	$align_target = "";
	$align_temp = "";
	for($j = 0; $j < length($target); $j++)
	{
		$aa = substr($target, $j, 1);
		$bb = substr($talign, $j, 1);		
		if ($aa ne "-" || $bb ne "-")
		{
			$align_target .= $aa;
			$align_temp .= $bb; 
		}
	}
	$talign = $align_temp;
	$target = $align_target;
	
	$talign2 = $talign;
	$talign2 =~ s/-//g; 
	$len = length($talign2); 

	#generate pir alignment
	open(NEW, ">$new_pir") || die "can't create $new_pir.\n";
	print NEW "C;template\n"; 
	print NEW ">P1;$template_id\n";
	print NEW "structureX:$temp_id: 1: : $len: : : : : \n";
	print NEW "$talign*\n\n";

	print NEW "C;query\n";
	print NEW ">P1;$name\n";
	print NEW " : : : : : : : : : \n";
	print NEW "$target*\n";
	close NEW; 

	open(INI, ">$new_pir.ini") || die "can't create $new_pir.ini.\n";
	print INI "C;template\n"; 
	print INI ">P1;$ini_name\n";
	print INI "structureX:$ini_name: : : : : : : : \n";
	print INI "$ini_template*\n\n";

	print INI "C;query\n";
	print INI ">P1;$name\n";
	print INI " : : : : : : : : : \n";
	print INI "$ini_target*\n";
	close INI; 
	
	

	if (-f $atom_file)
	{
		#add backbone
		`cp $atom_file $temp_id.pdb`;

		#re-order residues in the pdb file
		open(PDB, "$temp_id.pdb") || die "can't read $temp_id.pdb\n";
		@pdb = <PDB>;
		close PDB;

		open(PDB, ">$temp_id.pdb") || die "can't write $temp_id.pdb\n";			

		$order = 0; 
		while (@pdb)
		{
			$record = shift @pdb;
			chomp $record; 
			$left = substr($record, 0, 22);
			$right = substr($record, 26); 

			$order++; 	
			
			$serial = "$order";
			while (length($serial) < 4)
			{
				$serial = " $serial";	
			}
			print PDB "$left$serial$right\n";
		}
		close PDB; 

		system("$pulchra $temp_id.pdb");
		#print "cp $temp_id.rebuilt.pdb $temp_id.atom\n"; 
		`cp $temp_id.rebuilt.pdb $temp_id.atom`; 
		`gzip -f $temp_id.atom`; 
		`rm $temp_id.rebuilt.pdb`; 
	}	
	else
	{
		next;
	}

	#generate models

	system("$script_dir/pir2ts_energy.pl $modeller_dir . . $new_pir 5 2>/dev/null");
	
	if (-f "$name.pdb")
	{
		`mv $name.pdb muster$i.pdb`; 
	}

	#restore to original pir file
	`mv $new_pir $new_pir.used`; 
	`mv $new_pir.ini $new_pir`; 

	#check if the chain of the model is broken
	system("$script_dir/clash_check_broken.pl $fasta_file muster$i.pdb > clash$i.txt"); 
	open(CLASH, "clash$i.txt") || die "can't read clash$i.txt";
	@clash = <CLASH>;
	close CLASH;
	foreach $entry (@clash)
	{
		if ($entry =~ /chain broken/)
		{
			print "muster$i.pdb's chain is broken, removed!\n";
			`mv muster$i.pdb muster$i.pdb.broken`; 
			`mv $new_pir $new_pir.broken`; 
			last;
		}
	}
}

close ERR; 

print "MUSTER comparative modeling is done.\n";


