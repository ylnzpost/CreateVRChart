#!/usr/bin/perl
print "--------------------------"."\n";
print "REQUIRE SUB PERL SCRIPT"."\n";
print "--------------------------"."\n";

# GEN
my @msd_CustomerCommunicationRSP_arr = ();
my @msd_CustomerCommunication_arr = ();
my @msd_InstallationDocument_arr = ();
my @msd_PaymentPreference_arr = ();
my @msd_Template_arr = ();

my @GEN_DOC_TYPES = 
	(
		"CustomerCommunicationRSP", 
		"CustomerCommunication", 
		"InstallationDocument",
		"PaymentPreference",
		"Template"
	);