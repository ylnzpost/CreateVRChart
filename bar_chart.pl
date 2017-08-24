#!/usr/bin/perl
# General Modules
use strict;
use GD;
use GD::Graph::bars;
use Math::Round;
use IO::Handle;
use File::Stat;
use File::Basename;
use HTTP::Date;
use POSIX qw(floor ceil);
#use POSIX qw(ceil);
use Data::Dumper qw(Dumper);
use Cwd;

# define ARGUMENTS passed from PERL command
my ($CLIENT_CODE_ARG) = @ARGV;
my $CLIENT_CODE = $CLIENT_CODE_ARG;
# define different client doc type arrays
# MSD
my @msd_Admin_arr = ();
my @msd_StudyLink_arr = ();
my @msd_WorkAndIncome_arr = ();
# MNRG
my @mnrg_RSP_arr = ();
my @mnrg_Meridian_arr = ();
# STHX
my @sthx_BRRS_arr = ();
my @sthx_CareAdvantage_arr = ();
my @sthx_AP_arr = ();
my @sthx_Agency_arr = ();
my @sthx_RSP_arr = ();
my @sthx_SouthernCross_arr = ();

# define graph object
my $graph = GD::Graph::bars->new(1000, 1000);
# --------------------------------------------------
# define array objects for different document types
# --------------------------------------------------
my @CLIENTS_ARR = ("MSD", "MNRG", "STHX", "FONT", "TCL");
my @MSD_DOC_TYPES = ("Admin", "StudyLink", "Work And Income");
my @MNRG_DOC_TYPES = ("Meridian RSP", "Meridian");
my @STHX_DOC_TYPES = ("BRRS", "Care Advantage", "Southern Cross AP", "Southern Cross Agency", "Southern Cross RSP", "Southern Cross");
my %HASH_DOC_TYPES=("MSD" => [@MSD_DOC_TYPES], "MNRG" => [@MNRG_DOC_TYPES], "STHX" => [@STHX_DOC_TYPES]);
=start
foreach my $key (@CLIENTS_ARR) 
{
  if ($key eq "MSD")
  {
    $HASH_DOC_TYPES{$key} = \@MSD_DOC_TYPES;
    # OR
    #$HASH_DOC_TYPES{$key} = [@MSD_DOC_TYPES];
  }
  elsif ($key eq "MNRG")
  {
    $HASH_DOC_TYPES{$key} = \@MNRG_DOC_TYPES;
    # OR
    #$HASH_DOC_TYPES{$key} = [@MNRG_DOC_TYPES];
  }
  elsif ($key eq "STHX")
  {
    $HASH_DOC_TYPES{$key} = \@STHX_DOC_TYPES;
    # OR
    #$HASH_DOC_TYPES{$key} = [@STHX_DOC_TYPES];
  }
  else
  {}
}
=cut
#print Dumper HASH_DOC_TYPES."\n"
print "----------------------"."\n";
print "[ HASH DOC TYPES ]"."\n";
print "----------------------"."\n";
print Dumper(\%HASH_DOC_TYPES);
print "----------------------"."\n";
# --------------------------------------------------
sub size_in_kb {
	my $size_in_bytes = $_[0];
	return $size_in_bytes / (1024);
}

sub size_in_mb {
	my $size_in_bytes = $_[0];
	return $size_in_bytes / (1024 * 1024);
}

sub size_in_gb {
	my $size_in_bytes = $_[0];
	return $size_in_bytes / (1024 * 1024 * 1024);
}

sub convert_bytes {
	my $size_in_bytes = $_[0];
	if ($size_in_bytes < 1024)
	{
		return $size_in_bytes." BYTES ";
	}
	elsif ($size_in_bytes >= 1024 && $size_in_bytes < 1024 * 1024)
	{
		return size_in_kb($size_in_bytes)." KB ";
	}
	elsif ($size_in_bytes >= 1024 * 1024 && $size_in_bytes < 1024 * 1024 * 1024)
    {
    	return size_in_mb($size_in_bytes)." MB ";
    }
    elsif ($size_in_bytes >= 1024 * 1024 * 1024)
    {
    	return size_in_gb($size_in_bytes)." GB ";
    }
	else
	{}
}

sub convert_bytes_roundup {
	my $size_in_bytes = $_[0];
	if ($size_in_bytes < 1024)
	{
		return $size_in_bytes." BYTES ";
	}
	elsif ($size_in_bytes >= 1024 && $size_in_bytes < 1024 * 1024)
	{
		return nearest(.01, size_in_kb($size_in_bytes))." KB ";
	}
	elsif ($size_in_bytes >= 1024 * 1024 && $size_in_bytes < 1024 * 1024 * 1024)
    {
    	return nearest(.01, size_in_mb($size_in_bytes))." MB ";
    }
    elsif ($size_in_bytes >= 1024 * 1024 * 1024)
    {
    	return nearest(.01, size_in_gb($size_in_bytes))." GB ";
    }
	else
	{}
}

sub print_array_content
{
	my @array = @_;
	foreach (@array) {
		print "$_\n";
	}
}

sub process_file_data
{
  my $clientcode = $_[0];
  my $filename = $_[1];

  # use the perl open function to open the file
  open(FILE_DATA, $filename) or die "Could not read from $filename, open file failed.";

  my @fields_arr;
  my @data_arr;
  my $line;

  while(<FILE_DATA>){
    chomp;
    $line = $_;
    @fields_arr = split(/\|/, $line);
    print Dumper \@fields_arr;
	my $CLIENT_CODE_VAL;
	my $DOC_TYPE_VAL;
	my $BYTES_VAL;
	
    foreach my $one_field (@fields_arr){
      print "FIELD VALUE: ".$one_field."\n";
	  $CLIENT_CODE_VAL = $fields_arr[0];
	  $DOC_TYPE_VAL = $fields_arr[1];
	  $BYTES_VAL = $fields_arr[5];
    }
	load_data($CLIENT_CODE_VAL, $DOC_TYPE_VAL, convert_bytes_roundup($BYTES_VAL));
  }

  close FILE_DATA;
}

sub load_data
{
  my $clientcode = $_[0];
  my $doctype = $_[1];
  my $value = $_[2];
  
  if ($clientcode eq "MSD")
  {
	if ($doctype eq "Admin")
	{
		push (@msd_Admin_arr, $value);
	}
	elsif ($doctype eq "StudyLink")
	{
		push (@msd_StudyLink_arr, $value);
	}
	elsif ($doctype eq "Work And Income")
	{
		push (@msd_WorkAndIncome_arr, $value);
	}
	else
	{}
  }
  elsif ($clientcode eq "MNRG")
  {

  }
  elsif ($clientcode eq "STHX")
  {
    
  }
  elsif ($clientcode eq "FONT")
  {
    
  }
  elsif ($clientcode eq "TCL")
  {
    
  }
  else
  {}
}

sub get_check_files 
{
    # Return full paths of all files in single directory
    #my ($check_dir_path) = @_;   
    my $check_dir_path = $_[0];
    my $SEARCH_CLIENT_CODE = $_[1];
    print "--------------------------"."\n";
    print "CHECKING IN DIRECTORY"."\n";
    print "--------------------------"."\n";
    print $check_dir_path."\n";
    print "--------------------------"."\n";
    print "CHECKING FOR CLIENT CODE"."\n";
    print "--------------------------"."\n";
    print $SEARCH_CLIENT_CODE."\n";
    print "--------------------------"."\n";
    my @fullpath_files_list = ();
    #my ($check_dir_path) = $_[0];
    print "checking files in $check_dir_path\n";
    # Check if file exists
    if (-e $check_dir_path) 
    { 
      chmod (0777, $check_dir_path);
      opendir(my $dir, $check_dir_path) or die "Error - cannot open directory $check_dir_path";
      #my @files_list = readdir $dir;
      my @files_list = map { "$check_dir_path/$_" } readdir $dir;
      closedir($dir);
      #do not check for these file extensions
      my @file_suffixes = (".txt", ".dat", ".zip");
      
      while (my $file = shift(@files_list)) 
      {
        #print("Full File Path -> $file\n");
        #my $fullpath_file = $check_dir_path."/".$file;
        my $fullpath_file = $file;
        if (not defined basename($fullpath_file) || $fullpath_file eq '')
        {
          #error out
        }
        else
        {
          my $filename = basename($fullpath_file, @file_suffixes);
          #print "--------------------------"."\n";
          #print "FILE NAME -> ".$filename."\n";
          #print "--------------------------"."\n";
          if ($filename ne '.' && $filename ne '..')
          {
            #print "--------------------------"."\n";
            #print "FOUND "."[ ".ext_only($filename)." ]"." FILE"."\n";
            #print "--------------------------"."\n";

            if (ext_only($filename) eq 'report')
            {
              #print "--------------------------"."\n";
              print ("REPORT FILE -> $filename\n");
              #print "--------------------------"."\n";

              my $REPORT_CLIENT_CODE_STR = '_'.$SEARCH_CLIENT_CODE.'_';
              if (IsStringContains($filename, $REPORT_CLIENT_CODE_STR) == 1)
              {
                print "--------------------------"."\n";
                print ("[ $SEARCH_CLIENT_CODE ] REPORT FILE -> $filename\n");
                print "--------------------------"."\n";
                if (-f $fullpath_file)
                {
                  push (@fullpath_files_list, $fullpath_file);
                }
              }
            }
          }
        }
      }
    }
    return @fullpath_files_list;
}

sub LTrim
{
  my $s = shift; $s =~ s/^\s+//;
  return $s;
};

sub RTrim
{
  my $s = shift; $s =~ s/\s+$//;
  return $s;
};

sub Trim
{
  my $s = shift; $s =~ s/^\s+|\s+$//g;
  return $s;
};

sub without_ext {
    my ($file) = @_;
    return substr($file, 0, rindex($file, '.'));
}

sub ext_only {
    my ($file) = @_;
    return substr($file, rindex($file, '.') + 1);
}

sub StringContains
{
  #my ($arr_parm) = @_; 
  my $string = $_[0];
  my $substring = $_[1];
  if (index($string, $substring) != -1) {
    print $string." contains ".$substring."\n";
  }
}

sub IsStringContains
{
  my $string = $_[0];
  my $substring = $_[1];
  if (index($string, $substring) != -1) {
    return 1;
  }
  return 0;
}

# get current directory
my $pwd = cwd();
my $reports_dir = $pwd."/reports";
# change dir to /reports
chdir("/reports");
print "--------------------------"."\n";
print "CHECKING REPORTS DIRECTORY"."\n";
print "--------------------------"."\n";
print $reports_dir."\n";
print "--------------------------"."\n";
my $CHECK_DIR = Trim($reports_dir);      
my @report_files_arr = get_check_files($CHECK_DIR, $CLIENT_CODE);
foreach my $report_file (@report_files_arr)
{
  print "--------------------------"."\n";
  print "PROCESSING REPORT FILE"."\n";
  print "--------------------------"."\n";
  print $report_file."\n";
  print "--------------------------"."\n";
  process_file_data($CLIENT_CODE, $report_file);
  print "--------------------------"."\n";
  print "[ msd_Admin_arr ]"."\n";
  print "--------------------------"."\n";
  foreach my $one_item (@msd_Admin_arr){
	print $one_item."\n";
  }
  print "--------------------------"."\n";
  print "[ msd_StudyLink_arr ]"."\n";
  print "--------------------------"."\n";
  foreach my $one_item (@msd_StudyLink_arr){
	print $one_item."\n";
  }
  print "--------------------------"."\n";
  print "[ msd_WorkAndIncome_arr ]"."\n";
  print "--------------------------"."\n";
  foreach my $one_item (@msd_WorkAndIncome_arr){
	print $one_item."\n";
  }
  print "--------------------------"."\n";
}

#foreach (@report_files_arr) 
#{ 
#    print $_."\n";
#}

# go back to original directory
chdir($pwd);

my @report_data_labels_arr = ("Admin","StudyLink","Work And Income");
my @report_data_arr = ();
my $report_data_labels_arr_matrix = \@report_data_labels_arr;
#my $report_data_arr_matrix = \@report_data_arr;
#print Dumper $report_data_labels_arr_matrix;
#print Dumper $report_data_arr_matrix;
=start
my @data = ( 
  $report_data_labels_arr_matrix,
  [ convert_bytes_roundup(33816522601), convert_bytes_roundup(1555073714334), convert_bytes_roundup(3720421023591) ],
  [ convert_bytes_roundup(34130361462), convert_bytes_roundup(1567262065125), convert_bytes_roundup(3792789686833) ],
  [ convert_bytes_roundup(34413973423), convert_bytes_roundup(1583691158306), convert_bytes_roundup(3830241681626) ]
);
=cut
=start
my @data = ( 
  $report_data_labels_arr_matrix,
  [ convert_bytes_roundup(33816522601), convert_bytes_roundup(34130361462), convert_bytes_roundup(34413973423) ],
  [ convert_bytes_roundup(1555073714334), convert_bytes_roundup(1567262065125), convert_bytes_roundup(1583691158306) ],
  [ convert_bytes_roundup(3720421023591), convert_bytes_roundup(3792789686833), convert_bytes_roundup(3830241681626) ]
);
=cut
=start
my @data = ( 
  $report_data_labels_arr_matrix,
  [ convert_bytes_roundup(33816522601), convert_bytes_roundup(34130361462), convert_bytes_roundup(34413973423) ],
  [ convert_bytes_roundup(1555073714334), convert_bytes_roundup(1567262065125), convert_bytes_roundup(1583691158306) ],
  [ convert_bytes_roundup(3720421023591), convert_bytes_roundup(3792789686833), convert_bytes_roundup(3830241681626) ]
);
=cut
my @data;
# -----------------------------------------------------------
# MSD
# -----------------------------------------------------------
my $msd_Admin_arr_matrix = \@msd_Admin_arr;
my $msd_StudyLink_arr_matrix = \@msd_StudyLink_arr;
my $msd_WorkAndIncome_arr_matrix = \@msd_WorkAndIncome_arr;
# -----------------------------------------------------------
@data = ( 
  $report_data_labels_arr_matrix,
  $msd_Admin_arr_matrix,
  $msd_StudyLink_arr_matrix,
  $msd_WorkAndIncome_arr_matrix
);
# -----------------------------------------------------------

print "----------------------"."\n";
print Dumper @data;
print "----------------------"."\n";
my $chart_data_matrix = \@data;
print Dumper $chart_data_matrix;
print "----------------------"."\n";
print_array_content(@data);
print "----------------------"."\n";
#print (size_in_kb(1555073714334)." KB "."\n");
#print (size_in_mb(1555073714334)." MB "."\n");
#print (size_in_gb(1555073714334)." GB "."\n");
#print (nearest(.01, convert_bytes(1555073714334))."\n");
#print ("TOTAL: ".(convert_bytes_roundup(1555073714334))."\n");

$graph->set( 
  x_label           => 'X Axis',
  y_label           => 'Y Axis',
  title             => 'Simple Graph Sample',
  y_max_value       => 5000,
  y_tick_number     => 500,
  y_label_skip      => 50 
) or die $graph->error;

my $gd = $graph->plot(\@data) or die $graph->error;

open(IMG, '>msd_report_bar_chart_01.png') or die $!;
binmode IMG;
print IMG $gd->png;
close IMG;
