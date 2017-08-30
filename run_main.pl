use strict;
use IPC::System::Simple qw(system systemx capture capturex);

my @args = ("MSD", "STHX", "MNRG");

foreach my $arg_variable (@args) { 
    print "processing "."[ ".$arg_variable." ]"."\n";
	system('bar_chart.pl'.' '.'"'.$arg_variable.'"');
	#exec('bar_chart.pl'.' '.'"'.$arg_variable.'"');
} 
