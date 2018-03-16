#! /usr/bin/perl


# parse query string
if (length ($ENV{'QUERY_STRING'}) > 0){
      $buffer = $ENV{'QUERY_STRING'};
      @pairs = split(/&/, $buffer);
      foreach $pair (@pairs){
           ($name, $value) = split(/=/, $pair);
           $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
           $in{$name} = $value; 
      }
 }else{

my ($sec,$min,$hour,$day,$month,$yr19,@rest) =   localtime(time);
if (length($hour) == 1) {$hour = "0$hour";}
if (length($min)  == 1) {$min = "0$min";}
# http://frame/cgi-bin/speak.pl?action=say&words=hello
# http://frame/cgi-bin/speak.pl?action=time&time=09:00
#    my $rc = system("echo /mnt/usb/TalkingChumby/flite_time \"${hour}:${min}\" ");
    my $rc = system("/mnt/usb/TalkingChumby/flite_time \"${hour}:${min}\" ");

    print "content-type:text\/html\r\n\r\n";
    print "done=true\r\n\r\n";

}


if ($in{'action'} eq "time") { #say the time HH:MM 
    my $rc = system("/mnt/usb/TalkingChumby/flite_time $in{'time'}");

    print "content-type:text\/html\r\n\r\n";   
    print "done=true\r\n\r\n";
}

if ($in{'action'} eq "say") { #say the words 
    my $rc = system("/mnt/usb/TalkingChumby/flite_cmu_us_kal16 -t \"$in{'words'}\"");

    print "content-type:text\/html\r\n\r\n";   
    print "done=true\r\n\r\n";
}

if ($in{'action'} eq "policy") { # send policy file to flash 
    # send the crossdomain policy file
    print "Content-type:text\/x-cross-domain-policy\r\n";
    print "X-Permitted-Cross-Domain-Policies: all\r\n\r\n";
    print "<\?xml version=\"1.0\"\?>\r\n\r\n";
    print "<cross-domain-policy>\n";
    print "  <allow-access-from domain=\"\*\" \/>\n";
    print "<\/cross-domain-policy>\n";
}

