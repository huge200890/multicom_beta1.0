#!/usr/bin/perl -w
###############################################################
#Generate sam model based on multiple alignment generated by
#muscle
#Inputs: input dir, output dir
#Author: Jianlin Cheng
#Date: 1/25/2008
############################################################### 
if (@ARGV != 2)
{
	die "need two parameters: input dir, output dir.\n";
}

$in_dir = shift @ARGV;
$out_dir = shift @ARGV;

use Cwd 'abs_path';
$in_dir = abs_path($in_dir);

$sam = "/home/chengji/work/marc/sam3.5.i686-linux/bin/buildmodel ";

opendir(IN, $in_dir) || die "can't read $in_dir.\n";
@files = readdir IN;
closedir IN;

chdir $out_dir;

while (@files)
{
	$file = shift @files;

	if ($file =~ /(.+)\.txt\.align$/)
	{
		$name = $1;

		system("$sam $name -train $in_dir/$file -randseed 0");
	}
}

