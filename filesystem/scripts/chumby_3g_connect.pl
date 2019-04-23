#!/usr/bin/perl -w

# Based off uls_3g_connect.pl.
# Modified to work on a Chumby.




my ($apn, $pin, $number) = ("", "", "");
my $success = 0;

open(my $config, '<', "/psp/ppp-peer");
while(<$config>) {
    my $line = $_;
    chomp $line;
    print STDERR "Line: [$line]\n";
    if($line =~ /^#APN: /) {
        ($apn) = $line =~ /^#APN: (.*)$/;
    }
    elsif($line =~ /^#PIN: /) {
        ($pin) = $line =~ /^#PIN: (.*)$/;
    }
    elsif($line =~ /^#NUMBER: /) {
        ($number) = $line =~ /^#NUMBER: (.*)$/;
    }
}
close($config);


print STDERR "Using APN: $apn  Number: $number  Pin: $pin\n";




## From here on can probably remain as is.
$|=1;

my $log_h;
sub write_log {
    print STDERR $_[0] . "\n";
    system("echo $_[0] >> /tmp/pppd_3g.log");
}


sub send_message {                   
    my ($cmd) = @_;
    write_log("Sending $cmd");
    print "$cmd\r\n";

    # Wait for the command to be echoed back.
    while(my $echoback = <>) {
        $echoback =~ s/\s+$//s;
        print STDERR "Got input [$echoback]...";
        if( ($echoback eq $cmd) || ($cmd =~ /^ATD/ && ($echoback eq "" || $echoback eq "OK")) ) {
            print STDERR " match!\n";
            last;
        }
        print STDERR " no match\n";
    }
}


sub request {
	while (<>) {
		s/\s+$//s;
		if ($_) {
			write_log("Received: $_");
			return $_;
		}
	}
}

sub command {
    my ($cmd, $ok_arg) = @_;
    my $reply;
    my $response;
    send_message($cmd);
    my $ok = "^OK\$";
    if (defined($ok_arg)) {
        $ok = $ok_arg;
    }
    while (1) {
        $reply = request();
        if ($reply =~ $ok) {
            if (!defined($response)) {
                $response = $reply;
            }
            return $response;
        }
        elsif ($reply =~ "^\\+") {
            $response = $reply;
        }
        else {
            write_log("Failing due to $reply");
            die("Failing due to $reply\n");
        }
    }
}


write_log("Initializing modem");

alarm(10);
print "+++\r\n";
command("ATZ");

# Determine if we need a PIN.
my $pinreq = eval { command("AT+CPIN?") } || "";

# And obtain a PIN if we need it.
# XXX Not yet implemented!
if ($pinreq eq "+CPIN: SIM PIN") {
    alarm(0);
    write_log("Attempting to obtain PIN.");
#    my $pin = getpin("3G PIN");

    alarm(10);
    command("AT+CPIN=$PIN");
}



command("ATH");
if($apn ne "") {
    command("AT+CGDCONT=1,\"IP\",\"$apn\"");
}

# Wait for the device to be connected.  The response should have
# +CGREG:0,1.  If we get +CGREG:0,0, it means we're still connecting.
# You can get more information from the GPRS modem codes book at:
# http://www.rfsolutions.co.uk/acatalog/AT_cmd-GPRS_User_Guide.pdf
my $tries = 0;
my $total_tries = 100;
while(1) {
###
    $tries++;
    alarm(0);
    alarm(10);
    if($tries > $total_tries) {
        write_log("Exceeded the maximum number of retries of $total_tries");
        write_log("The modem just never responded that it was ready.");
        die("Modem never responded\n");
    }
    
    eval { send_message("AT+CGREG?") };
    last if($@);
    my $stat = request();
    
    write_log("Stat: $stat");
    if($stat =~ /CGREG\D+0,[04]/) {
        request(); # Grab "OK" message.
        sleep(5);
        next;
    }
    elsif($stat =~ /CGREG\D+0,[15]/) {
        request(); # Grab "OK" message.
        last;
    }
    elsif($stat =~ /CGREG\D+0,2/) {
        write_log("Failed to connect");
        die("Failed to connect\n");
    }
    elsif($stat =~ /COMMAND NOT SUPPORT/) {
        last;
    }
    elsif($stat =~ /ERROR/) {
        last;
    }
    else {
        write_log("Unexpected status response: $stat\n");
        die("Unexpected status response: $stat\n");
    }
}

my $connect = command("ATDT$number", "^CONNECT");
if($connect =~ "^CONNECT (.*)\$") {
    write_log("Connected at $1.");
    $success = 1;
}
elsif($connect eq "CONNECT") {
    write_log("Connected at unknown speed.");
    $success = 1;
}
else {
    print STDERR "Not connected.  Got response: $connect\n";
}
exit(0);


END {
    if(!$success) {
        system("killall pppd");
    }
}
