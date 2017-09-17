#!/usr/bin/perl
print "--------------------------"."\n";
print "REQUIRE SUB PERL SCRIPT"."\n";
print "--------------------------"."\n";

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

sub load_data_for_all
{
	my $clientcode = $_[0];
	my $doctype = $_[1];
	my $value = $_[2];
	
	print "-------------------------"."\n";
	print "LOAD DATA FROM ALL REPORT"."\n";
	print "-------------------------"."\n";
	if ($clientcode eq "ANZ")
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
	elsif ($clientcode eq "GEN")
	{
		if ($doctype eq "Customer Communication RSP")
		{
			push (@gen_CustomerCommunicationRSP_arr, $value);
		}
		elsif ($doctype eq "Customer Communication")
		{
			push (@gen_CustomerCommunication_arr, $value);
		}
		elsif ($doctype eq "Installation Document")
		{
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

1