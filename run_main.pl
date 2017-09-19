use strict;
use IPC::System::Simple qw(system systemx capture capturex);
#---------------------------------------------------------------
# for the main clients' codes
# MSD, SouthernCross, Meridian Energy, Fonterra, TelstraClear
#---------------------------------------------------------------
my @args = ("MSD", "STHX", "MNRG", "FONT", "TCL");
#---------------------------------------------------------------
# Command Example => perl bar_chart.pl MSD
#---------------------------------------------------------------
foreach my $arg_variable (@args) { 
    print "processing "."[ ".$arg_variable." ]"."\n";
	system('bar_chart.pl'.' '.'"'.$arg_variable.'"');
	#exec('bar_chart.pl'.' '.'"'.$arg_variable.'"');
}
# END