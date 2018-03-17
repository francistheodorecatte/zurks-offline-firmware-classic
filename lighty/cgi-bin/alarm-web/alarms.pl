#!/usr/bin/perl -w
use BDXML;

my $alarm_file = "/psp/alarms";


main();





sub main {
    my $params = {
        page     => 'view',
        %{parse_cgi_response()}
    };
    my $alarms = read_alarm_file($alarm_file);
    
    if( $$params{'page'} eq 'edit' ) {
        edit_page($params, $alarms, $alarm_file);
    }
    elsif( $$params{'page'} eq 'save' ) {
        save_page($params, $alarms, $alarm_file);
    }
    elsif( $$params{'page'} eq 'download' ) {
        download_alarm($params, $alarms, $alarm_file);
    }
    elsif( $$params{'page'} eq 'upload' ) {
        upload_alarm($params, $alarms, $alarm_file);
    }
    else {
        view_page($params, $alarms, $alarm_file);
    }
}


sub edit_page {
    my ($params, $alarms) = @_;
    my $alarm = {};
    if(defined $$params{'id'}) {
        $alarm = $$alarms[$$params{'id'}]->{'properties'};
    }
    print_http_header();
    print_html_header();
    
    print " "x0, "<form action=\"$ENV{'SCRIPT_NAME'}\" method=\"get\">\n";
    print " "x4, "<input type=\"hidden\" name=\"id\" value=\"$$params{'id'}\"/>\n";
    print " "x4, "<input type=\"hidden\" name=\"page\" value=\"save\"/>\n";
    
    print " "x4, "<table class=\"edit_alarm\">\n";
    
    print " "x4, "<tr>\n";
    print " "x8, "<th><label for=\"name\">Alarm Name</label></th>\n";
    print " "x8, "<td><input type=\"text\" name=\"name\" id=\"name\" value=\"$$alarm{'name'}\"/></td>\n";
    print " "x4, "</tr>";
    
    print " "x4, "<tr>\n";
    print " "x8, "<th>When</th>\n";
    print " "x8, "<td>\n";
    print " "x12,print_select_option("daily",     "Daily",      $$alarm{'when'}, 'when');
    print " "x12,print_select_option("weekend",   "Weekends",   $$alarm{'when'}, 'when');
    print " "x12,print_select_option("weekday",   "Weekdays",   $$alarm{'when'}, 'when');
    print " "x12,print_select_option("sunday",    "Sundays",    $$alarm{'when'}, 'when');
    print " "x12,print_select_option("monday",    "Mondays",    $$alarm{'when'}, 'when');
    print " "x12,print_select_option("tuesday",   "Tuesdays",   $$alarm{'when'}, 'when');
    print " "x12,print_select_option("wednesday", "Wednesdays", $$alarm{'when'}, 'when');
    print " "x12,print_select_option("thursday",  "Thursdays",  $$alarm{'when'}, 'when');
    print " "x12,print_select_option("friady",    "Fridays",    $$alarm{'when'}, 'when');
    print " "x12,print_select_option("saturday",  "Saturdays",  $$alarm{'when'}, 'when');
    print " "x12,print_select_option("once",      "Once on <input type=\"text\" name=\"date\" id=\"date\" size=\"7\" value=\"" .  print_date($$alarm{'time'}) . "\"/>",       $$alarm{'when'}, 'when');
    print " "x8, "</td>\n";
    print " "x4, "</tr>\n";
    
    print " "x4, "<tr>\n";
    print " "x8, "<th><label for=\"time\">Time</label></th>\n";
    print " "x8, "<td><input type=\"text\" name=\"time\" size=\"7\" id=\"time\" value=\"" . print_time($$alarm{'time'}) . "\"/></td>\n";
    print " "x4, "</tr>\n";

    print " "x4, "<tr>\n";
    print " "x8, "<th><label for=\"duration\">Duration</label></th>\n";
    print " "x8, "<td><input type=\"text\" name=\"duration\" id=\"duration\" value=\"$$alarm{'duration'}\"/></td>\n";
    print " "x4, "</tr>\n";

    print " "x4, "<tr>\n";
    print " "x8, "<th><label for=\"action\">Alarm</label></th>\n";
    print " "x8, "<td>\n";
    print " "x12,print_select_option('beep', "Play sound", $$alarm{'type'}, 'type');
    print " "x12,print_select_option('audio', "Play music", $$alarm{'type'}, 'type');
    print " "x12,print_select_option('none', "Do nothing", $$alarm{'type'}, 'type');
    print " "x8, "</td>\n";
    print " "x4, "</tr>\n";

    print " "x4, "<tr>\n";
    print " "x8, "<th>Sound</th>\n";
    print " "x8, "<td>\n";
    print " "x12,print_select_option('Beep', 'Beep', $$alarm{'arg'}, 'arg');
    print " "x12,print_select_option('Bugle', 'Bugle', $$alarm{'arg'}, 'arg');
    print " "x12,print_select_option('Klaxon', 'Klaxon', $$alarm{'arg'}, 'arg');
    print " "x8, "</td>\n";
    print " "x4, "</tr>\n";

    print " "x4, "<tr>\n";
    print " "x8, "<th><label for=\"audio\">Audio</label></th>\n";
    print " "x8, "<td>\n";
    print " "x12,"<input type=\"text\" name=\"audio\" size=\"30\" id=\"audio\" value=\"$$alarm{'arg'}\"/>\n";
    print " "x8, "</td>\n";
    print " "x4, "</tr>\n";

    print " "x4, "<tr>\n";
    print " "x8, "<th><label for=\"param\">Audio Param</label></th>\n";
    print " "x8, "<td>\n";
    print " "x12,"<input type=\"text\" name=\"param\" size=\"30\" id=\"param\" value=\"$$alarm{'param'}\"/>\n";
    print " "x8, "</td>\n";
    print " "x4, "</tr>\n";

    print " "x4, "<tr>\n";
    print " "x8, "<th><label for=\"snooze\">Snooze</label></th>\n";
    print " "x8, "<td>\n";
    print " "x12,"<input size=\"5\" type=\"text\" name=\"snooze\" id=\"snooze\" value=\"$$alarm{'snooze'}\"/>\n";
    print " "x8, "</td>\n";
    print " "x4, "</tr>\n";

    print " "x4, "<tr>\n";
    print " "x8, "<th><label for=\"backup\">Backup Alarm</label></th>\n";
    print " "x8, "<td>\n";
    print " "x12,"<input type=\"checkbox\" name=\"backup\" id=\"backup\" value=\"1\"", ($$alarm{'backup'}?" checked":""), "/> ",
                 "<label for=\"backup\">Enabled</label>\n";
    print " "x12," after <input type=\"text\" name=\"backupDelay\" id=\"backupDelay\" value=\"$$alarm{'backupDelay'}\" size=\"5\"/> ",
                 "<label for=\"backupDelay\">minutes</label>\n";
    print " "x8, "</td>\n";
    print " "x4, "</tr>\n";

    print " "x4, "<tr>\n";
    print " "x8, "<th>After alarm</th>\n";
    print " "x8, "<td>\n";
    print " "x12, print_check_option('Return to previous screen', 'return',
($$alarm{'action'} eq 'none') && ($$alarm{'action_param'} eq ''),
                  'action');
    print " "x12, print_check_option('Nightmode On', 'nightmode_on',
($$alarm{'action'} eq 'nightmode') && ($$alarm{'action_param'} eq 'on'),
                  'action');
    print " "x12, print_check_option('Nightmode Off', 'nightmode_off',
($$alarm{'action'} eq 'nightmode') && ($$alarm{'action_param'} eq 'off'),
                  'action');
    print " "x12, print_check_option('Power Off', 'power_off',
($$alarm{'action'} eq 'power') && ($$alarm{'action_param'} eq 'off'),
                  'action');
    print " "x8, "</td>\n";
    print " "x4, "</tr>\n";

    print " "x4, "<tr>\n";
    print " "x8, "<th><label for=\"enabled\">Enable alarm</label></th>\n";
    print " "x8, "<td>\n";
    print " "x12,"<input type=\"checkbox\" name=\"enabled\" id=\"enabled\"", $$alarm{'enabled'}?" checked":"", "/>\n";
    print " "x8, "</td>\n";
    print " "x4, "</tr>\n";

    print " "x4, "<tr>\n";
    print " "x8, "<th></th\n";
    print " "x8, "<td>\n";
    print " "x12,"<input type=\"submit\" name=\"save\" value=\"Update\"/>\n";
    print " "x8, "</td>\n";
    print " "x4, "</tr>\n";

    print " "x4, "<tr>\n";
    print " "x8, "<th></th\n";
    print " "x8, "<td>\n";
    print " "x12,"<input type=\"submit\" name=\"delete\" value=\"Delete\"/>\n";
    print " "x8, "</td>\n";
    print " "x4, "</tr>\n";

    print " "x4, "</table>\n";
    
    print " "x0, "</form>\n";

    print_html_footer();
} 



sub save_page {
    my ($params, $alarms, $alarm_file) = @_;
    my $alarm = {};

    # If the user wants to delete the alarm, splice it out of the alarms
    # array and redirect.
    if(defined($$params{'delete'})) {
        if(defined($$params{'id'}) && int($$params{'id'}) ne '') {
            if($$params{'id'} == 0) {
                $alarm = $$alarms[0]->{'properties'};
                $$alarm{'name'}     = "";
                $$alarm{'enabled'}  = 0;
            }
            else {
                splice(@$alarms, $$params{'id'}, 1);
            }
            save_alarm_file($alarms, $alarm_file);
        }
        redirect_to_this_page();
        return;
    }

    # If we don't have an ID, create a new alarm.  Otherwise, pull the
    # current alarm out of the list of all alarms and begin editing it.
    elsif(!defined($$params{'id'}) || $$params{'id'} eq '') {
        print STDERR "Creating new alarm...\n";
        push(@$alarms, {
                name        => 'alarm',
                properties  => $alarm,
        });
    }

    # Otherwise, grab the alarm from the array so we can update it.
    else {
        $alarm = $$alarms[$$params{'id'}]->{'properties'};
    }



    if(defined $$params{'name'}) {
        $$alarm{'name'} = $$params{'name'};
    }

    if(defined $$params{'when'}) {
        $$alarm{'when'} = $$params{'when'};
    }

    # Do our best to figure out the time.
    if(defined($$params{'time'})) {
        my ($hour, $minute, $ampm) = $$params{'time'} =~
                /(\d+)\s*:\s*(\d+)\s*(\w+)/;
        if($hour==12) {
            $hour = 0;
        }
        if((lc $ampm) eq 'pm') {
            $hour += 12;
        }
        $$alarm{'time'} = ($hour*60)+$minute;
    }

    # Now, if the "when" is "Once", do our best to figure out the time.
    if($$alarm{'when'} eq 'once' && defined($$params{'date'})) {
        my ($month, $day, $year) = $$params{'date'} =~
            /(\d+)\/(\d+)\/(\d+)/;

        # Because we don't have the POSIX or Time modules, we can't use
        # mktime.  So we shell out to the busybox `date' command instead.
        my $date_cmd = sprintf("date -d \"%s\" %02s%02s0000%02s",
                                $month, $day, $year);
        my $seconds_since_epoch = `$date_cmd`;
        $$alarm{'time'} += ($seconds_since_epoch/60);
    }

    if(defined($$params{'duration'})) {
        if($$alarm{'duration'} eq "") {
            $$alarm{'duration'} = 0;
        }
        $$alarm{'duration'} = int($$params{'duration'});
    }

    if(defined($$params{'snooze'}) && int($$params{'snooze'}) > 0) {
        if($$alarm{'snooze'} eq "") {
            $$alarm{'snooze'} = 0;
        }
        $$alarm{'snooze'} = int($$params{'snooze'});
    }

    if(defined($$params{'alarm'})) {
        $$alarm{'alarm'} = $$params{'alarm'};

        if($$params{'alarm'} eq 'beep') {
            $$alarm{'arg'}   = $$params{'arg'};
            $$alarm{'param'} = "";
        }
        elsif($$params{'alarm'} eq 'audio') {
            $$alarm{'arg'}   = $$params{'audio'};
            $$alarm{'param'} = $$params{'param'};
        }
        else {
            $$alarm{'alarm'} = "none";
            $$alarm{'arg'}   = "";
            $$alarm{'param'} = "";
        }
    }

    if(defined($$params{'backup'})) {
        $$alarm{'backup'} = 1;
        # Set the backupDelay to 5 minutes (the default).  If the user
        # specified a valid value, we'll set it below.
        $$alarm{'backupDelay'} = 5;
    }
    else {
        $$alarm{'backup'} = 0;
    }

    if(defined($$params{'backupDelay'}) && int($$params{'backupDelay'})<=0) {
        $$alarm{'backupDelay'} = int($$params{'backupDelay'});
    }

    if(defined($$params{'action'})) {
        if($$params{'action'} eq 'return') {
            $$alarm{'action'}       = "none";
            $$alarm{'action_param'} = "";
        }
        elsif($$params{'action'} eq 'nightmode_on') {
            $$alarm{'action'}       = "nightmode";
            $$alarm{'action_param'} = "on";
        }
        elsif($$params{'action'} eq 'nightmode_off') {
            $$alarm{'action'}       = "nightmode";
            $$alarm{'action_param'} = "off";
        }
        elsif($$params{'action'} eq 'power_off') {
            $$alarm{'action'}       = "power";
            $$alarm{'action_param'} = "off";
        }
    }

    if($$params{'enabled'}) {
        $$alarm{'enabled'} = 1;
    }
    else {
        $$alarm{'enabled'} = 0;
    }

    print STDERR "Validating alarm.  ID: $$params{'id'}\n";
    if(validate_alarm($alarm)) {
        save_alarm_file($alarms, $alarm_file);
        redirect_to_this_page();
    }
    else {
        print_http_header();
        print_html_header();
        print "An error occurred.  Unable to save alarms.\n";
        print_html_footer();
    }
}


sub download_alarm {
    my ($params, $alarms, $alarm_file) = @_;
    print "Content-Type: application/octet-stream\n";
    print "Content-Disposition: attachment; filename=alarms\n";
    print "Content-Length: " . (-s "/psp/alarms") . "\n";
    print "\n";
    open(my $fh, '<', "/psp/alarms") or die("Couldn't open alarm file: $!\n");
    print while(<$fh>);
    close($fh);
    return 0;
}

sub upload_alarm {
    my ($params, $alarms, $alarm_file) = @_;
    if(defined $$params{'alarms'}) {
        open(my $fh, '>', "/psp/alarms")
            or die("Couldn't open alarm file: $!\n");
        print $fh $$params{'alarms'};
        close($fh);
        redirect_to_this_page();
    }
    else {
        print_http_header();
        print_html_header();
        print "<form class=\"upload_form\" method=\"post\" action=\"$ENV{'SCRIPT_NAME'}\" enctype=\"multipart/form-data\">";
        print "<input type=\"hidden\" name=\"page\" value=\"upload\"/>";
        print "<div class=\"upload_file_widget\">Alarm file: <input type=\"file\" name=\"alarms\"/></div>";
        print "<div clas=\"upload_file_submit\"><input type=\"submit\" name=\"upload\" value=\"Upload\"/></div>\n";
        print_html_footer();
    }
}

sub view_page {
    my ($params, $alarms) = @_;
    print_http_header();
    print_html_header();
    
    print_table_header("Quick Alarm", "quick_alarms");
    print_alarm(shift(@$alarms));
    print_table_footer();

    print_table_header("Custom Alarms", "custom_alarms");
    for my $alarm(@$alarms) {
        print_alarm($alarm);
    }
    print_table_footer();
    print "<div class=\"new_alarm\"><a href=\"$ENV{'SCRIPT_NAME'}?page=edit\">New alarm</a></div>\n";

    print " "x0, "<div class=\"download_file\"><a href=\"$ENV{'SCRIPT_NAME'}?page=download\">Download alarm file</a></div>\n";
    print " "x0, "<div class=\"upload_file\"><a href=\"$ENV{'SCRIPT_NAME'}?page=upload\">Upload alarm file</a></div>\n";
    
    
    print_html_footer();
}




########### CGI PROCESSING ############


sub parse_cgi_response {
    my @pairs = split(/\&/, $ENV{'QUERY_STRING'});
    my $params = {};
    foreach my $pair(@pairs) {
        my ($key, $value) = split(/\=/, $pair, 2);
        $value =~ s/\+/ /g;
        $value =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        $$params{$key} = $value;
    }

    # Now read in POST variables, if they exist.
    if((uc $ENV{'REQUEST_METHOD'}) eq 'POST' 
        && $ENV{'CONTENT_TYPE'} =~ /multipart\/form-data/) {
        my ($boundary) = $ENV{'CONTENT_TYPE'} =~ /boundary=([a-zA-Z0-9\-]+)/;

        # Convert the multipart data into variables.  Do this by reading in
        # CONTENT_LENGTH bytes, and if we hit a boundary, switch to the
        # next variable.
        my $bytes = 0;

        # This contains information about the currently-processing
        # variable.
        my $variable = {
            header  => 1,
        };
        while($bytes<$ENV{'CONTENT_LENGTH'}) {
            my $line = <>;
            last if(!defined $line);
            $bytes += length($line);
            $line =~ s/[\r\n]+$//g;

            print STDERR "Read line: [$line]\n";

            # If we hit a boundary, reset 
            if($line eq ("--" . $boundary) || $line eq ("--" . $boundary . "--")) {
                print STDERR "Hit boundary\n";
                if(defined($$variable{'name'})) {
                    $$params{$$variable{'name'}} = $$variable{'value'};
                }
                $variable = {
                    header  => 1,
                };
                next;
            }

            if($$variable{'header'}) {
                # If we get a blank line, it's the end of the header.
                if($line  eq "") {
                    $$variable{'header'} = 0;
                }
                if($line =~ /^content-disposition/i) {
                    my (undef, $data) = split(/: /, $line, 2);
                    my @pairs = split("; ", $data);
                    print STDERR "Working on: $data\n";
                    foreach my $pair(@pairs) {
                        print STDERR "Working on pair: $pair\n";
                        if($pair =~ /=/) {
                            my ($key, $value) = split('=', $pair, 2);
                            $value =~ s/^"//g;
                            $value =~ s/"$//g;
                            $$variable{$key} = $value;
                        }
                        else {
                            $$variable{$pair} = 1;
                        }
                    }
                }
            }
            else {
                $$variable{'value'} .= $line . "\n";
            }
        }
        while(my ($key, $value) = each %$params) {
            chomp $$params{$key};
        }
    }

#    print STDERR "Printing environment variables:\n";
#    while(my ($key, $value) = each %ENV) {
#        print STDERR "    $key: $value\n";
#    }
#
#    print STDERR "Printing CGI variables:\n";
#    while(my ($key, $value) = each %$params) {
#        print STDERR "    $key: $value\n";
#    }

    return $params;
}

sub redirect_to_this_page {
    print "Location: $ENV{'SCRIPT_NAME'}\n";
    print "Refresh: 0; url=$ENV{'SCRIPT_NAME'}\n";
    print "Content-type: text/html\n";
    print "\n";
    print "Redirect to <a href=\"$ENV{'SCRIPT_NAME'}\">here</a>\n";
}



########### HTML PRINTING ############

sub print_http_header {
    print "Content-Type: text/html\n\n";
}

sub print_html_header {
#        <style type="text/css" media="screen">
#            \@import "alarms-style.sh";
#        </style>
    print <<END_OF_HEADER;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<html>
    <head>
        <title>Chumby Alarms</title>
        <link rel="stylesheet" href="alarms-style.sh" type="text/css"></link>
    </head>
<body>
END_OF_HEADER
}

sub print_html_footer {
    print "</body>\n</html>\n";
}


sub print_table_header {
    my ($title, $class)=@_;
    print <<END_OF_HEADER;
<table class=\"$class\">
    <caption>$title</caption>
    <thead>
    <tr>
        <th>Alarm name</th>
        <th>Time</th>
        <th>Audio</th>
        <th>Duration</th>
        <th>Backup alarm</th>
        <th>Alarm/snooze screen</th>
        <th>Snooze</th>
        <th>After alarm</th>
        <th>Enabled?</th>
        <th></th>
    </tr>
    </thead>
END_OF_HEADER
}

sub print_table_footer {
    print "</table>\n";
}

sub print_alarm {
    my ($alarm_object) = @_;
    my $alarm = $$alarm_object{'properties'};
    print " "x4, "<tr>\n";
    print " "x8, "<td>$$alarm{'name'}</td>\n";
    print " "x8, "<td>", print_when($alarm), "</td>\n";
    print " "x8, "<td>$$alarm{'param_description'}</td>\n";
    print " "x8, "<td>$$alarm{'duration'} minutes</td>\n";
    print " "x8, "<td>", print_backup_alarm($alarm), "</td>\n";
    print " "x8, "<td>", !$$alarm{'auto_dismiss'}?'On':'Off', "</td>\n";
    print " "x8, "<td>$$alarm{'snooze'} minutes</td>\n";
    print " "x8, "<td>$$alarm{'action'} $$alarm{'action_param'}</td>\n";
    print " "x8, "<td>", $$alarm{'enabled'}?'On':'Off', "</td>\n";
    print " "x8, "<td><a href=\"$ENV{'SCRIPT_NAME'}?page=edit&amp;id=$$alarm_object{'id'}\">Edit</a></td>\n";
    print " "x4, "<tr>\n";
}



sub print_backup_alarm {
    my ($alarm) = @_;
    if($$alarm{'backup'}) {
        return "After ", $$alarm{'backupDelay'}, " minutes";
    }
    return "Off";
}


# XXX This should look at the locale information.
# Ideally we'd be able to use the POSIX module, but this is miniperl.
sub print_when {
    my ($alarm) = @_;
    my ($alarm_time) = ($$alarm{'time'});
    my $is_gmt = ($$alarm{'when'} eq "once");
    
    
    if($is_gmt) {
        my @fields = localtime($alarm_time*60);
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = @fields;
        my $ampm = 'am';
        if($hour>12) {
            $ampm = 'pm';
            $hour -= 12;
        }
        elsif($hour==12) {
            $ampm = 'pm';
        }
        if($hour==0) {
            $hour = 12;
        }
        $year+=1900;
        $mon++;
        return sprintf('Once on %d/%d/%d at %d:%02d %s', $mon, $mday, $year,
                                                         $hour, $min, $ampm);
    }
    else {
        my $when = $$alarm{'when'};
        $when =~ s/\b(\w)/uc($1)/eg;
        # We need to multiply the alarm time by 60, as it measures the number
        # of minutes since midnight, not the number of seconds.
        my @fields = gmtime($alarm_time*60);
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = @fields;

        my $ampm = 'am';
        if($hour>12) {
            $ampm = 'pm';
            $hour -= 12;
        }
        elsif($hour==12) {
            $ampm = 'pm';
        }
        if($hour==0) {
            $hour = 12;
        }

        return sprintf('%s at %d:%02d %s', $when, $hour, $min, $ampm);
    }
}
sub print_date {
    my ($alarm_time) = @_;
    my @fields = localtime($alarm_time*60);
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = @fields;
    my $ampm = 'am';
    if($hour>12) {
        $ampm = 'pm';
        $hour -= 12;
    }
    elsif($hour==12) {
        $ampm = 'pm';
    }
    if($hour==0) {
        $hour = 12;
    }
    $year+=1900;
    $mon++;
    return sprintf('%d/%d/%d', $mon, $mday, $year);
}
sub print_time {
    my ($alarm_time) = @_;
    my @fields;

    # Decide whether to take gmtime or localtime.
    # gmtime is used for repeating alarms, and is time since midnight.
    # localtime is used for absolute alarms.
    # Since the repeating alarms are seconds-since-midnight, they'll always
    # be less than 60min*24hour hours (or so, modulo leap-seconds.)
    if($alarm_time<60*24+5) {
        @fields = gmtime($alarm_time*60);
    }
    else {
        @fields = localtime($alarm_time*60);
    }

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = @fields;
    my $ampm = 'am';
    if($hour>12) {
        $ampm = 'pm';
        $hour -= 12;
    }
    elsif($hour==12) {
        $ampm = 'pm';
    }
    if($hour==0) {
        $hour = 12;
    }
    $year+=1900;
    $mon++;
    return sprintf('%d:%02d %s', $hour, $min, $ampm);
}
                                                                   

sub print_select_option {
    my ($id, $label, $checked, $name) = @_;
    return  "<div><input type=\"radio\" value=\"$id\" name=\"$name\" id=\"$id\""
          . (($checked eq $id)?" checked":"") . "/>"
          . " <label for=\"$id\">$label</label></div>\n";
}
sub print_check_option {
    my ($label, $id, $checked, $name) = @_;
    return  "<div><input type=\"radio\" value=\"$id\" name=\"$name\" id=\"$id\""
          . (($checked)?" checked":"") . "/>"
          . " <label for=\"$id\">$label</label></div>\n";
}


########### ALARM FILE MANIPULATION ############

sub read_alarm_file {
    my ($file) = @_;
    
    # If the file doesn't exist, return an empty alarm list.
    if( ! -e $file ) {
        return [];
    }
    
    
    # Slurp the alarm file.
    my $text;
    {
        local( $/, *FH ) ;
        open( FH, $file ) or die("Unable to open alarm file: $!");
        $text = <FH>
    }
    my $alarms = BDXML::parse($text);
    
    # Ensure the file has a root tag that we recognize.
    if( !defined($alarms) || $$alarms{'name'} ne "alarms" ) {
        warn("Root <alarms> tag not found\n");
        return;
    }
    
    my $i=0;
    $alarms = $$alarms{'children'};
    for my $alarm(@$alarms) {
        $$alarm{'id'} = $i++;
    }
    
    return $alarms;
}

sub validate_alarm {
    my ($alarm) = @_;

    if(!defined($$alarm{'name'})) {
        $$alarm{'name'} = "";
    }
    if($$alarm{'name'} =~ /[<>&]/) {
        die("Invalid characters in alarm name\n");
    }

    if(!defined $$alarm{'type'}) {
        $$alarm{'type'} = "beep";
        $$alarm{'arg'}  = 'Beep';
    }

    if((!defined($$alarm{'duration'})) || $$alarm{'duration'} <= 0) {
        $$alarm{'duration'} = 1;
    }

    if(!defined($$alarm{'snooze'}) || $$alarm{'snooze'} <= 0) {
        $$alarm{'snooze'} = 9;
    }

    if(!defined($$alarm{'action'}) || $$alarm{'action'} eq '') {
        $$alarm{'action'} = 'none';
    }

    if(!defined($$alarm{'when'})) {
        $$alarm{'when'} = 'daily';
    }

    if(!defined($$alarm{'backup'}) || $$alarm{'backup'}<=0 ) {
        $$alarm{'backup'} = 0;
        $$alarm{'backupDelay'} = 5;
    }
    else {
        if(!defined($$alarm{'backupDelay'})
         || int($$alarm{'backupDelay'})<=0) {
            $$alarm{'backupDelay'} = 5;
        }
    }

    if(!defined($$alarm{'param_description'})) {
        if($$alarm{'type'} eq "beep") {
            $$alarm{'param_description'} = "Play &quot;" . $$alarm{'arg'} .
                "&quot;";
        }
        elsif($$alarm{'type'} eq 'none') {
            $$alarm{'param_description'} = "none";
        }
        else {
            $$alarm{'param_description'} = $$alarm{'type'};
        }
    }

    $$alarm{'auto_dismiss'} = 0;

    return 1;
}

sub save_alarm_file {
    my ($alarms, $file) = @_;

    open(my $fh, '>', $file) || die("Unable to open alarm file for writing: $!\n");
    print $fh BDXML::unparse({
            name        => 'alarms',
            children    => $alarms,
        });
    close($fh);

    # Force flashplayer to reload the alarm file.
    open($fh, '>', '/tmp/flashplayer.event')
        or die("Couldn't open FP event file: $!\n");
    print $fh "<event type=\"AlarmPlayer\" value=\"reload\" comment=\"/psp/alarms\"/>\n";
    close($fh);

    # Issue the "Read flashplayer.event" command.  Redirect to /dev/null to
    # ignore the flashplayer's greeting banner.
    system("chumbyflashplayer.x -F1 > /dev/null 2> /dev/null");
}

