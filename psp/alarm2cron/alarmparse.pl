#!/usr/bin/perl

# Script to parse alarms file and create appropriate cron entries

open ($fh,"/psp/alarms") or die "Failed to open alarms file";
read ($fh, $alarms, 20480);
close ($fh);

%daysofw = ("monday",1,"tuesday",2,"wednesday",3,"thursday",4,"friday",5,"saturday",6,"sunday",7);

@alarmlines=split("<alarm ",$alarms);
$alarm_index=-2;
foreach (@alarmlines){
    $alarm_index++; 
    /name=\"([^"]*)\" .* enabled=\"(\d+)" time=\"(\d+)\" when=\"(.+)\"/;
    $name=$1;
    $enabled=$2;
    $altime=$3;
    $when=$4;
    next if (!$enabled);
    if ($when eq "once") {
        ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                localtime($altime*60);
        print "$min $hour $mday ",$mon+1," * /psp/alarm2cron/execute.sh $alarm_index \"$name\" # alarm2cron\n";
    }
    else {
        $wdays="";
        $wdays="1-5" if ($when eq "weekday");
        $wdays="6,0" if ($when eq "weekend");
        $wdays="\*" if ($when eq "daily");
        $wdays=$daysofw{$when} if ($wdays eq "");
        next if ($wdays eq "");
        
        $min=$altime%60;
        $hour=int($altime/60);
        print "$min $hour * * $wdays /psp/alarm2cron/execute.sh $alarm_index \"$name\" # alarm2cron\n";
    }
        
}