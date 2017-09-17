#!/usr/bin/perl
# General Modules
use strict;
use GD;
use GD::Graph::bars;
use GD::Graph::Data;
use Math::Round;
use IO::Handle;
use File::Stat;
use File::Basename;
use HTTP::Date;
use POSIX qw(floor ceil);
#use POSIX qw(ceil);
use Data::Dumper qw(Dumper);
use Cwd;
# Require another Perl
require "./bar_chart_for_ALL.pl";

# define ARGUMENTS passed from PERL command
my ($CLIENT_CODE_ARG, $REPORT_ALL_ARG) = @ARGV;
my $CLIENT_CODE = $CLIENT_CODE_ARG;
my $REPORT_ALL = $REPORT_ALL_ARG;
print "----------------------"."\n";
print "[ SCRIPT ARGS ]"."\n";
print "----------------------"."\n";
print "CLIENT_CODE -> ".$CLIENT_CODE."\n";
print "REPORT_ALL -> ".$REPORT_ALL."\n";
print "----------------------"."\n";
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
# FONT
my @font_HRDocuments_arr = ();
my @font_SupplierDocumentsRSP_arr = ();
my @font_SupplierDocuments_arr = ();

# define graph object
my $graph = GD::Graph::bars->new(1000, 1000);
my @colours = 
	('blue', 
	'green', 
	'cyan', 
	'yellow', 
	'purple',
	'orange',
	'red',
	'gray');
# --------------------------------------------------
# define array objects for different document types
# --------------------------------------------------
my @CLIENTS_ARR = ("MSD", "MNRG", "STHX", "FONT", "TCL");
my @MSD_DOC_TYPES = ("Admin", "StudyLink", "Work And Income");
my @MNRG_DOC_TYPES = ("Meridian RSP", "Meridian");
my @STHX_DOC_TYPES = ("BRRS", "Care Advantage", "Southern Cross AP", "Southern Cross Agency", "Southern Cross RSP", "Southern Cross");
my @REPORT_DATES = ();
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

sub process_file_data {
	my $filename = $_[0];
	
	my $report_name = basename($filename, ".report");
	my $date_range = substr($report_name, 0, 21);
	print "--------------------------"."\n";
	print "[ DATE RANGE ]"."\n";
	print "--------------------------"."\n";
	print $date_range."\n";
	print "--------------------------"."\n";
	push(@REPORT_DATES, $date_range);
	
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

sub process_ALL_file_data {
	my $filename = $_[0];
	
	my $report_name = basename($filename, ".report");
	my $date_range = substr($report_name, 0, 21);
	print "--------------------------"."\n";
	print "[ DATE RANGE ]"."\n";
	print "--------------------------"."\n";
	print $date_range."\n";
	print "--------------------------"."\n";
	push(@REPORT_DATES, $date_range);
	
	# use the perl open function to open the file
	open(FILE_DATA, $filename) or die "Could not read from $filename, open file failed.";

	my @fields_arr;
	my @data_arr;
	my $line;

	while(<FILE_DATA>){
		chomp;
		$line = $_;
		@fields_arr = split(/\|/, $line);
		#print Dumper \@fields_arr;
		my $CLIENT_CODE_VAL;
		my $DOC_TYPE_VAL;
		my $BYTES_VAL;
		
		foreach my $one_field (@fields_arr){
			#print "FIELD VALUE: ".$one_field."\n";
			$CLIENT_CODE_VAL = $fields_arr[0];
			$DOC_TYPE_VAL = $fields_arr[1];
			$BYTES_VAL = $fields_arr[5];
		}
=start
		print "--------------------------"."\n";
		print "[ SINGLE RECORD IN ALL REPORT FILE ]"."\n";
		print "--------------------------"."\n";
		print "{ START }"."\n";
		foreach my $one_field (@fields_arr){
		  print "FIELD VALUE: ".$one_field."\n";
		  $CLIENT_CODE_VAL = $fields_arr[0];
		  $DOC_TYPE_VAL = $fields_arr[1];
		  $BYTES_VAL = $fields_arr[5];
		}
		print "{ END }"."\n";
		print "--------------------------"."\n";
=cut
		if ($CLIENT_CODE eq $CLIENT_CODE_VAL)
		{
			print "--------------------------"."\n";
			print "FOUND -> "."[ "."THIS IS "."{ ".$CLIENT_CODE." }"." RECORD"." ]"."\n";
			print "--------------------------"."\n";
			print "[ SINGLE RECORD IN ALL REPORT FILE ]"."\n";
			print "--------------------------"."\n";
			print "{ START }"."\n";
			foreach my $one_field (@fields_arr){
			  print "FIELD VALUE: ".$one_field."\n";
			  $CLIENT_CODE_VAL = $fields_arr[0];
			  $DOC_TYPE_VAL = $fields_arr[1];
			  $BYTES_VAL = $fields_arr[5];
			}
			print "{ END }"."\n";
			print "--------------------------"."\n\n";
			load_data($CLIENT_CODE_VAL, $DOC_TYPE_VAL, convert_bytes_roundup($BYTES_VAL));
		}
	}
	close FILE_DATA;
}

sub load_data {
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
		if ($doctype eq "Meridian RSP")
		{
			push (@mnrg_RSP_arr, $value);
		}
		elsif ($doctype eq "Meridian")
		{
			push (@mnrg_Meridian_arr, $value);
		}
		else
		{}
	}
	elsif ($clientcode eq "STHX")
	{
		if ($doctype eq "BRRS")
		{
			push (@sthx_BRRS_arr, $value);
		}
		elsif ($doctype eq "Care Advantage")
		{
			push (@sthx_CareAdvantage_arr, $value);
		}
		elsif ($doctype eq "Southern Cross Agency")
		{
			push (@sthx_Agency_arr, $value);
		}
		elsif ($doctype eq "Southern Cross AP")
		{
			push (@sthx_AP_arr, $value);
		}
		elsif ($doctype eq "Southern Cross RSP")
		{
			push (@sthx_RSP_arr, $value);
		}
		elsif ($doctype eq "Southern Cross")
		{
			push (@sthx_SouthernCross_arr, $value);
		}
		else
		{}
	}
	elsif ($clientcode eq "FONT")
	{
		if ($doctype eq "HR Documents")
		{
			push (@font_HRDocuments_arr, $value);
		}
		elsif ($doctype eq "Supplier Documents RSP")
		{
			push (@font_SupplierDocumentsRSP_arr, $value);
		}
		elsif ($doctype eq "Supplier Documents")
		{
			push (@font_SupplierDocuments_arr, $value);
		}
		else
		{}
	}
	elsif ($clientcode eq "TCL")
	{

	}
	else
	{
		#for ALL report file
		load_data_for_all($clientcode, $doctype, $value);
	}
}

sub get_check_files 
{
	# Return full paths of all files in single directory
    #my ($check_dir_path) = @_;   
    my $check_dir_path = $_[0];
    my $SEARCH_CLIENT_CODE = $_[1];
	my $check_file_ALL = $_[2];
    print "--------------------------"."\n";
    print "CHECKING IN DIRECTORY"."\n";
    print "--------------------------"."\n";
    print $check_dir_path."\n";
    print "--------------------------"."\n";
    print "CHECKING FOR CLIENT CODE"."\n";
    print "--------------------------"."\n";
    print $SEARCH_CLIENT_CODE."\n";
    print "--------------------------"."\n";
	print "CHECKING FILE ALL"."\n";
    print "--------------------------"."\n";
    print $check_file_ALL."\n";
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
			  
			  # this is only for client codes (MSD, MNRG, STHX, FONT, TCL, BNZ) showing in report file name
              my $REPORT_CLIENT_CODE_STR = '_'.$SEARCH_CLIENT_CODE.'_';
			  # most clients are in ALL report file
			  my $REPORT_ALL_STR = '_'.$check_file_ALL.'_';
			  print "--------------------------"."\n";
              print ("REPORT_CLIENT_CODE_STR -> $REPORT_CLIENT_CODE_STR"."\n");
              print "--------------------------"."\n";
			  print ("REPORT_ALL_STR -> $REPORT_ALL_STR"."\n");
              print "--------------------------"."\n";
              if (IsStringContains($filename, $REPORT_CLIENT_CODE_STR) == 1)
              {
				#print "--------------------------"."\n";
				#print ("[ $SEARCH_CLIENT_CODE ] REPORT FILE -> $filename\n");
				#print "--------------------------"."\n";
				if (-f $fullpath_file)
				{
				  push (@fullpath_files_list, $fullpath_file);
				}
              }
			  else
			  {
			      if (IsStringContains($filename, $REPORT_ALL_STR) == 1)
				  {
					#print "--------------------------"."\n";
					#print ("[ $check_file_ALL ] REPORT FILE -> $filename\n");
					#print "--------------------------"."\n";
					if (-f $fullpath_file)
					{
						print "--------------------------"."\n";
						print "FOUND REPORT FOR ALL"."\n";
						print "--------------------------"."\n";
						print $fullpath_file."\n";
						print "--------------------------"."\n";
						push (@fullpath_files_list, $fullpath_file);
					}
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
my @report_files_arr = get_check_files($CHECK_DIR, $CLIENT_CODE, $REPORT_ALL);

LABEL_PROCESS_FILES:
{
	foreach my $key (@CLIENTS_ARR) 
	{
		if ($key eq $CLIENT_CODE_ARG)
		{
			foreach my $report_file (@report_files_arr)
			{
				print "--------------------------"."\n";
				print "PROCESSING REPORT FILE"."\n";
				print "--------------------------"."\n";
				print $report_file."\n";
				print "--------------------------"."\n";
				process_file_data($report_file);
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
				print "[ sthx_BRRS_arr ]"."\n";
				print "--------------------------"."\n";
				foreach my $one_item (@sthx_BRRS_arr){
					print $one_item."\n";
				}
				print "--------------------------"."\n";
				print "[ sthx_CareAdvantage_arr ]"."\n";
				print "--------------------------"."\n";
				foreach my $one_item (@sthx_CareAdvantage_arr){
					print $one_item."\n";
				}
				print "--------------------------"."\n";
				print "[ sthx_AP_arr ]"."\n";
				print "--------------------------"."\n";
				foreach my $one_item (@sthx_AP_arr){
					print $one_item."\n";
				}
				print "--------------------------"."\n";
				print "[ sthx_Agency_arr ]"."\n";
				print "--------------------------"."\n";
				foreach my $one_item (@sthx_Agency_arr){
					print $one_item."\n";
				}
				print "--------------------------"."\n";
				print "[ sthx_RSP_arr ]"."\n";
				print "--------------------------"."\n";
				foreach my $one_item (@sthx_RSP_arr){
					print $one_item."\n";
				}
				print "--------------------------"."\n";
				print "[ sthx_SouthernCross_arr ]"."\n";
				print "--------------------------"."\n";
				foreach my $one_item (@sthx_SouthernCross_arr){
					print $one_item."\n";
				}
				print "--------------------------"."\n";
				print "[ mnrg_RSP_arr ]"."\n";
				print "--------------------------"."\n";
				foreach my $one_item (@mnrg_RSP_arr){
					print $one_item."\n";
				}
				print "--------------------------"."\n";
				print "[ mnrg_Meridian_arr ]"."\n";
				print "--------------------------"."\n";
				foreach my $one_item (@mnrg_Meridian_arr){
					print $one_item."\n";
				}
				print "--------------------------"."\n";
				print "[ font_HRDocuments_arr ]"."\n";
				print "--------------------------"."\n";
				foreach my $one_item (@font_HRDocuments_arr){
					print $one_item."\n";
				}
				print "--------------------------"."\n";
				print "[ font_SupplierDocumentsRSP_arr ]"."\n";
				print "--------------------------"."\n";
				foreach my $one_item (@font_SupplierDocumentsRSP_arr){
					print $one_item."\n";
				}
				print "--------------------------"."\n";
				print "[ font_SupplierDocuments_arr ]"."\n";
				print "--------------------------"."\n";
				foreach my $one_item (@font_SupplierDocuments_arr){
					print $one_item."\n";
				}
				print "--------------------------"."\n";
			}
			last LABEL_PROCESS_FILES;
		}
		else
		{
			foreach my $report_ALL_file (@report_files_arr)
			{
				print "--------------------------"."\n";
				print "PROCESSING [ ALL ] REPORT FILE"."\n";
				print "--------------------------"."\n";
				print $report_ALL_file."\n";
				print "--------------------------"."\n";
				#process for ALL report file
				process_ALL_file_data($report_ALL_file);
			}
		}
	}
}

#foreach (@report_files_arr) 
#{ 
#    print $_."\n";
#}

# go back to original directory
chdir($pwd);

my @report_data_labels_arr = ();
my @report_data_arr = ();
my $report_data_labels_arr_matrix = [];
#my $report_data_labels_arr_matrix = \@report_data_labels_arr;
#my $report_data_arr_matrix = \@report_data_arr;
#print Dumper $report_data_labels_arr_matrix;
#print Dumper $report_data_arr_matrix;
my @data;
# -----------------------------------------------------------
# different clients
# -----------------------------------------------------------
my $report_data_labels_arr_matrix = \@REPORT_DATES;
# MSD
my $msd_Admin_arr_matrix = \@msd_Admin_arr;
my $msd_StudyLink_arr_matrix = \@msd_StudyLink_arr;
my $msd_WorkAndIncome_arr_matrix = \@msd_WorkAndIncome_arr;
# STHX
my $sthx_BRRS_arr_matrix = \@sthx_BRRS_arr;
my $sthx_CareAdvantage_arr_matrix = \@sthx_CareAdvantage_arr;
my $sthx_AP_arr_matrix = \@sthx_AP_arr;
my $sthx_Agency_arr_matrix = \@sthx_Agency_arr;
my $sthx_RSP_arr_matrix = \@sthx_RSP_arr;
my $sthx_SouthernCross_arr_matrix = \@sthx_SouthernCross_arr;
# MNRG
my $mnrg_RSP_arr_matrix = \@mnrg_RSP_arr;
my $mnrg_Meridian_arr_matrix = \@mnrg_Meridian_arr;
# FONT
my $font_HRDocuments_arr_matrix = \@font_HRDocuments_arr;
my $font_SupplierDocumentsRSP_arr_matrix = \@font_SupplierDocumentsRSP_arr;
my $font_SupplierDocuments_arr_matrix = \@font_SupplierDocuments_arr;
# ---------------------------------------------------------
if ($CLIENT_CODE eq "MSD")
{
	# -----------------------------------------------------
	# MSD data
	# -----------------------------------------------------
	@data = ( 
	  $report_data_labels_arr_matrix,
	  $msd_Admin_arr_matrix,
	  $msd_StudyLink_arr_matrix,
	  $msd_WorkAndIncome_arr_matrix
	);
}
elsif ($CLIENT_CODE eq "STHX")
{
	# -----------------------------------------------------
	# STHX data
	# -----------------------------------------------------
	@data = ( 
	  $report_data_labels_arr_matrix,
	  $sthx_BRRS_arr_matrix,
	  $sthx_CareAdvantage_arr_matrix,
	  $sthx_AP_arr_matrix,
	  $sthx_Agency_arr_matrix,
	  $sthx_RSP_arr_matrix,
	  $sthx_SouthernCross_arr_matrix
	);
}
elsif ($CLIENT_CODE eq "MNRG")
{
	# -----------------------------------------------------
	# MNRG data
	# -----------------------------------------------------
	@data = ( 
	  $report_data_labels_arr_matrix,
	  $mnrg_RSP_arr_matrix,
	  $mnrg_Meridian_arr_matrix
	);
}
elsif ($CLIENT_CODE eq "FONT")
{
	# -----------------------------------------------------
	# FONT data
	# -----------------------------------------------------
	@data = ( 
	  $report_data_labels_arr_matrix,
	  $font_HRDocuments_arr_matrix,
	  $font_SupplierDocumentsRSP_arr_matrix,
	  $font_SupplierDocuments_arr_matrix
	);
}
elsif ($CLIENT_CODE eq "TCL")
{
	# -----------------------------------------------------
	# TCL data
	# -----------------------------------------------------
}
else
{}
# ---------------------------------------------------------

print "--------------------------"."\n";
print Dumper @data;
print "--------------------------"."\n";
my $chart_data_matrix = \@data;
print Dumper $chart_data_matrix;
print "--------------------------"."\n";
print_array_content(@data);
print "--------------------------"."\n";
#print (size_in_kb(1555073714334)." KB "."\n");
#print (size_in_mb(1555073714334)." MB "."\n");
#print (size_in_gb(1555073714334)." GB "."\n");
#print (nearest(.01, convert_bytes(1555073714334))."\n");
#print ("TOTAL: ".(convert_bytes_roundup(1555073714334))."\n");

$graph->set( 
  x_label           => 'X Axis',
  y_label           => 'Y Axis',
  title             => $CLIENT_CODE.' Graph and Chart',
  y_max_value       => 5000,
  y_tick_number     => 500,
  y_label_skip      => 50,
  dclrs       		=> [@colours],
  show_values		=> 1
) or die $graph->error;

#$graph->set_legend_font(GD::gdFontTiny);
if ($CLIENT_CODE eq "MSD")
{
	$graph->set_legend
		("Admin", "StudyLink", "Work And Income");
}
elsif ($CLIENT_CODE eq "STHX")
{
	$graph->set_legend
		("BRRS", 
		"Care Advantage",
		"Southern Cross Agency", 
		"Southern Cross AP", 
		"Southern Cross RSP",
		"Southern Cross");
}
elsif ($CLIENT_CODE eq "MNRG")
{
	$graph->set_legend
		("Meridian RSP", "Meridian");
}
elsif ($CLIENT_CODE eq "FONT")
{
	$graph->set_legend
		("HR Documents", "Supplier Documents RSP", "Supplier Documents");
}
else
{
	#for ALL report file
}

my $gd = $graph->plot(\@data) or die $graph->error;
my $IMAGE_FILE = $CLIENT_CODE."_report_bar_chart.png";

#open(IMG, '>msd_report_bar_chart.png') or die $!;
#binmode IMG;
#print IMG $gd->png;
#close IMG;

open(my $IMAGE_OUT, '>', $IMAGE_FILE) or die "Cannot open ".$IMAGE_FILE." for write: $!";
binmode $IMAGE_OUT;
print $IMAGE_OUT $graph->gd->png;
close $IMAGE_OUT;
