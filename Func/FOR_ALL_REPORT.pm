#!/usr/bin/perl
use strict;
use Data::Dumper qw(Dumper);
#use Exporter qw(import);
#our @EXPORT_OK = qw[$report_all_data_labels_arr_matrix];
our @EXPORT_OK = qw(load_data_for_all set_arr_matrix_for_all set_graphic_data_for_all set_legend_for_all get_graphic_data $report_all_data_labels_arr_matrix $graph_obj);
our ($report_all_data_labels_arr_matrix);
$report_all_data_labels_arr_matrix = [];

print "--------------------------"."\n";
print "REQUIRE SUB PERL SCRIPT"."\n";
print "--------------------------"."\n";

#---------------------------------------
# Define Graphic Object
#---------------------------------------
our ($graph_obj) = GD::Graph::bars->new(1000, 1000);
my @graphic_colours = 
	('blue', 
	'green', 
	'cyan', 
	'yellow', 
	'purple',
	'orange',
	'red',
	'gray');
#---------------------------------------
# Graphic Data
#---------------------------------------
my @graphic_data;
#---------------------------------------
# Clients for ALL report
#---------------------------------------
my @ALL_CLIENTS_ARR = ("GEN", "ANZ");
#---------------------------------------
# ANZ
#---------------------------------------
my @ANZ_DOC_TYPES = 
	(
		"ANZNZS", 
		"ANZPaymentOperations", 
		"ANZSecurities",
		"AccountsPayable",
		"CardSupport",
		"CompensationCoupons",
		"ConsumerFinance",
		"RetailPayments"
	);

my @anz_ANZNZS_arr = ();
my @anz_ANZPaymentOperations_arr = ();
my @anz_ANZSecurities_arr = ();
my @anz_AccountsPayable_arr = ();
my @anz_CardSupport_arr = ();
my @anz_CompensationCoupons_arr = ();
my @anz_ConsumerFinance_arr = ();
my @anz_RetailPayments_arr = ();
#---------------------------------------
# GEN
#---------------------------------------
my @GEN_DOC_TYPES = 
	(
		"CustomerCommunicationRSP", 
		"CustomerCommunication", 
		"InstallationDocument",
		"PaymentPreference",
		"Template"
	);

my @gen_CustomerCommunicationRSP_arr = ();
my @gen_CustomerCommunication_arr = ();
my @gen_InstallationDocument_arr = ();
my @gen_PaymentPreference_arr = ();
my @gen_Template_arr = ();
#---------------------------------------
# for graphic data
#---------------------------------------
# ANZ
my $anz_ANZNZS_arr_matrix = [];
my $anz_ANZPaymentOperations_arr_matrix = [];
my $anz_ANZSecurities_arr_matrix = [];
my $anz_AccountsPayable_arr_matrix = [];
my $anz_CardSupport_arr_matrix = [];
my $anz_CompensationCoupons_arr_matrix = [];
my $anz_ConsumerFinance_arr_matrix = [];
my $anz_RetailPayments_arr_matrix = [];
# GEN
my $gen_CustomerCommunicationRSP_arr_matrix = [];
my $gen_CustomerCommunication_arr_matrix = [];
my $gen_InstallationDocument_arr_matrix = [];
my $gen_PaymentPreference_arr_matrix = [];
my $gen_Template_arr_matrix  = [];
#---------------------------------------
sub load_data_for_all {
	my $data_clientcode = $_[0];
	my $doctype = $_[1];
	my $value = $_[2];
=start
	print "-------------------------"."\n";
	print "LOADING DATA FOR $data_clientcode FROM ALL REPORT"."\n";
	print "-------------------------"."\n";
	print $data_clientcode."\n";
	print $doctype."\n";
	print $value."\n";
	print "-------------------------"."\n\n";
=cut
	if ($data_clientcode eq "ANZ")
	{
		if ($doctype eq "ANZ NZS")
		{
			push (@anz_ANZNZS_arr, $value);
		}
		elsif ($doctype eq "ANZ Payment Operations")
		{
			push (@anz_ANZPaymentOperations_arr, $value);
		}
		elsif ($doctype eq "ANZ Securities")
		{
			push (@anz_ANZSecurities_arr, $value);
		}
		elsif ($doctype eq "Accounts Payable")
		{
			push (@anz_AccountsPayable_arr, $value);
		}
		elsif ($doctype eq "CardSupport")
		{
			push (@anz_CardSupport_arr, $value);
		}
		elsif ($doctype eq "Compensation Coupons")
		{
			push (@anz_CompensationCoupons_arr, $value);
		}
		elsif ($doctype eq "Consumer Finance")
		{
			push (@anz_ConsumerFinance_arr, $value);
		}
		elsif ($doctype eq "RetailPayments")
		{
			push (@anz_RetailPayments_arr, $value);
		}
		else
		{}
	}
	elsif ($data_clientcode eq "GEN")
	{
		#--------------------------
		#TEST
		#--------------------------
		#print "IN [ load_data_for_all ] SUB"."\n";
		#print $doctype."\n";
		#print $value."\n";
		#--------------------------
		if ($doctype eq "Customer Communication RSP")
		{
			#print "IN { Customer Communication RSP }"."\n";
			push (@gen_CustomerCommunicationRSP_arr, $value);
		}
		elsif ($doctype eq "Customer Communication")
		{
			#print "IN { Customer Communication }"."\n";
			push (@gen_CustomerCommunication_arr, $value);
		}
		elsif ($doctype eq "Installation Document")
		{
			#print "IN { Installation Document }"."\n";
			push (@gen_InstallationDocument_arr, $value);
		}
		elsif ($doctype eq "Payment Preference")
		{
			push (@gen_PaymentPreference_arr, $value);
		}
		elsif ($doctype eq "Template")
		{
			push (@gen_Template_arr, $value);
		}
		else
		{}
	}
	else
	{
	}
}

sub set_arr_matrix_for_all {
	# ANZ
	$anz_ANZNZS_arr_matrix = \@anz_ANZNZS_arr;
	$anz_ANZPaymentOperations_arr_matrix = \@anz_ANZPaymentOperations_arr;
	$anz_ANZSecurities_arr_matrix = \@anz_ANZSecurities_arr;
	$anz_AccountsPayable_arr_matrix = \@anz_AccountsPayable_arr;
	$anz_CardSupport_arr_matrix = \@anz_CardSupport_arr;
	$anz_CompensationCoupons_arr_matrix = \@anz_CompensationCoupons_arr;
	$anz_ConsumerFinance_arr_matrix = \@anz_ConsumerFinance_arr;
	$anz_RetailPayments_arr_matrix = \@anz_RetailPayments_arr;
	# GEN
	$gen_CustomerCommunicationRSP_arr_matrix = \@gen_CustomerCommunicationRSP_arr;
	$gen_CustomerCommunication_arr_matrix = \@gen_CustomerCommunication_arr;
	$gen_InstallationDocument_arr_matrix = \@gen_InstallationDocument_arr;
	$gen_PaymentPreference_arr_matrix = \@gen_PaymentPreference_arr;
	$gen_Template_arr_matrix = \@gen_Template_arr;
}

sub set_graphic_data_for_all {
	my ($graphic_clientcode) = $_[0];
	
	if ($graphic_clientcode eq "ANZ")
	{
		#-----------------------------------------------------
		# ANZ data
		#-----------------------------------------------------
		@graphic_data = (
			$report_all_data_labels_arr_matrix,
			$anz_ANZNZS_arr_matrix,
			$anz_ANZPaymentOperations_arr_matrix,
			$anz_ANZSecurities_arr_matrix,
			$anz_AccountsPayable_arr_matrix,
			$anz_CardSupport_arr_matrix,
			$anz_CompensationCoupons_arr_matrix,
			$anz_ConsumerFinance_arr_matrix,
			$anz_RetailPayments_arr_matrix
		);
	}
	elsif ($graphic_clientcode eq "GEN")
	{
		#-----------------------------------------------------
		# GEN data
		#-----------------------------------------------------
		@graphic_data = ( 
			$report_all_data_labels_arr_matrix,
			$gen_CustomerCommunicationRSP_arr_matrix,
			$gen_CustomerCommunication_arr_matrix,
			$gen_InstallationDocument_arr_matrix,
			$gen_PaymentPreference_arr_matrix,
			$gen_Template_arr_matrix
		);
	}
	else
	{}
	
	#----------------------------------
	# TEST
	#----------------------------------
	# ANZ
	print "----------------------------"."\n";
	print "ANZ"."\n";
	print "----------------------------"."\n";
	print Dumper $report_all_data_labels_arr_matrix;
	print Dumper $anz_ANZNZS_arr_matrix;
	print Dumper $anz_ANZPaymentOperations_arr_matrix;
	print Dumper $anz_ANZSecurities_arr_matrix;
	print Dumper $anz_AccountsPayable_arr_matrix;
	print Dumper $anz_CardSupport_arr_matrix;
	print Dumper $anz_CompensationCoupons_arr_matrix;
	print Dumper $anz_ConsumerFinance_arr_matrix;
	print Dumper $anz_RetailPayments_arr_matrix;
	# GEN
	print "----------------------------"."\n";
	print "GEN"."\n";
	print "----------------------------"."\n";
	print Dumper $report_all_data_labels_arr_matrix;
	print Dumper $gen_CustomerCommunicationRSP_arr_matrix;
	print Dumper $gen_CustomerCommunication_arr_matrix;
	print Dumper $gen_InstallationDocument_arr_matrix;
	print Dumper $gen_PaymentPreference_arr_matrix;
	print Dumper $gen_Template_arr_matrix;
	#----------------------------------
}

sub set_legend_for_all {
	my ($legend_clientcode) = @_;
	#my ($legend_clientcode) = $_[0];

	if ($legend_clientcode eq "ANZ")
	{
		$graph_obj->set_legend
			(
				"ANZ NZS", 
				"ANZ Payment Operations", 
				"ANZ Securities",
				"Accounts Payable",
				"CardSupport",
				"Compensation Coupons",
				"Consumer Finance",
				"RetailPayments"
			);
	}
	elsif ($legend_clientcode eq "GEN")
	{
		$graph_obj->set_legend
			(
				"Customer Communication RSP", 
				"Customer Communication", 
				"Installation Document", 
				"Payment Preference",
				"Template"
			);
	}
	else
	{}
}

sub get_graphic_data {
	return @graphic_data;
}

1;