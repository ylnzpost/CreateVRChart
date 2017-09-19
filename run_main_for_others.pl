use strict;
use IPC::System::Simple qw(system systemx capture capturex);
#---------------------------------------------------------------
# for the other clients' codes
# clients in ALL report file
# 
# Genesis, Vero, Vodafone, Fleet Holdings, NZPost, Yellow Pages, Co-operative Bank
# Kiwibank, Humes Pipeline Systems, Converga Group, Converga Pty, NZEI Te Riu Roa
#---------------------------------------------------------------
my @args = ("ANZ", "GEN", "VERO", "FLTP", "NZP", "YPG", "KWBK", "HUME", "NZEI");
#----------------------------------------------------------------
# Command Example => perl bar_chart.pl ANZ ALL
#----------------------------------------------------------------
foreach my $arg_variable (@args) { 
    print "processing "."[ ".$arg_variable." ]"."\n";
	system('bar_chart.pl'.' '.'"'.$arg_variable.'"'.' '.'"'.'ALL'.'"');
}
# END