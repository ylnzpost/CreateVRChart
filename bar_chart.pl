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

my ($CLIENT_CODE_ARG) = @ARGV;
my $CLIENT_CODE = $CLIENT_CODE_ARG;

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
=start
sub print_deep_array($)
{
    my $arrRef = shift;
    for (my $i = 0; $i < scalar(@$arrRef); ++$i) {
        if (ref($arrRef->[$i]) eq 'ARRAY') {
            print ', ' if ($i);
            print '[';
            print_deep_array($arrRef->[$i]);
            print ']';
        } else {
            print ', ' if ($i);
            print $arrRef->[$i];
        }
    }
    print ' ' if (!scalar(@$arrRef));
}
=cut

sub print_array_content
{
	my @array = @_;
	foreach (@array) {
		print "$_\n";
	}
}

sub process_file_data
{
  my $filename = $_[0];

  # use the perl open function to open the file
  open(FILE_DATA, $filename) or die "Could not read from $filename, open file failed.";

  my @fields_arr;
  my @data_arr;
  my $line;
  my $one_field;

  while(<FILE_DATA>){
    chomp;
    $line = $_;
    @fields_arr = split(/\|/, $line);
    print Dumper \@fields_arr;
    #print @fields_arr."\n";
    #$data_arr[0]=$field[0];
    #$data_arr[1]=$field[1];
    #$data_arr[2]=$field[2];
    #$data_arr[3]=$field[3];

    foreach $one_field (@fields_arr){
      print "FIELD VALUE: ".$one_field."\n";
    }
  }

  close FILE_DATA;
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
  process_file_data($report_file);
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
my $report_data_arr_matrix = \@report_data_arr;
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
my @data = ( 
  $report_data_labels_arr_matrix,
  [ convert_bytes_roundup(33816522601), convert_bytes_roundup(34130361462), convert_bytes_roundup(34413973423) ],
  [ convert_bytes_roundup(1555073714334), convert_bytes_roundup(1567262065125), convert_bytes_roundup(1583691158306) ],
  [ convert_bytes_roundup(3720421023591), convert_bytes_roundup(3792789686833), convert_bytes_roundup(3830241681626) ]
);
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

# msd test data
=start
my @data = ( 
  ["1st","2nd","3rd","4th","5th","6th","7th", "8th", "9th"],
  [ 10, 20, 50, 60, 30, 35, 45, 32, 43],
  [ 50, 30, 80, 10, 80, 70, 90, 45, 58 ],
  [ 30, 20, 60, 15, 60, 72, 20, 25, 68 ]
);
=cut
=start
my @data = ( 
  ["Admin","StudyLink","Work And Income"],
  [ 3381652260, 1555073714334, 3720421023591 ],
  [ 3413036146, 1567262065125, 3792789686833 ],
  [ 3441397342, 1583691158306, 3830241681626 ]
);
=cut
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
