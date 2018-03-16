#!/usr/bin/perl -w
my $update_file;
my @potential_files = (
        "/mnt/usb/update.fw",
        "/mnt/usb/update.tgz",
        "/mnt/usb/update.zip",
        "/mnt/usb/$ENV{'CONFIGNAME'}-update.fw",
        "/mnt/usb/$ENV{'CONFIGNAME'}-update.tgz",
        "/mnt/usb/$ENV{'CONFIGNAME'}-update.zip",
);

for my $test_file(@potential_files) {
    if(-e $test_file) {
        $update_file = $test_file;
        last;
    }
}

if(!defined($update_file)) {
    # Write an error message to the screen
    print STDERR "Update file not found";
    system("imgtool --mode=draw /bitmap/" . $ENV{'VIDEO_RES'} .  "/update_unsuccessful.bin" . get_brand() . ".jpg");
    exit(1);
}


# Daemonize.  Fork off, and have the parent exit.
# This will prevent the flash player from killing us when it exits.
defined(my $pid = fork) or die("Can't fork: $!");
exit if $pid;


chdir('/');
system("imgtool --mode=draw /bitmap/" . $ENV{'VIDEO_RES'} .  "/updating_software.bin" . get_brand() . ".jpg");
system("switch_fb.sh 0");
sleep(1);
system("/usr/chumby/scripts/stop_control_panel > /tmp/st.out 2> /tmp/st.err");
sleep(1);

# Write the "update_prepared" file so that the update will get completed
# when we go to reboot.
system("echo '$update_file' > /psp/update_prepared");


# Run the update.
exec("ORIGIN=USB /usr/chumby/scripts/update_launch.sh $update_file "
            . "> /tmp/up.out 2> /tmp/up.err");


sub get_brand {
    my $brand = "";
    open(my $f, '<', "/proc/cmdline");
    my $cmdline = <$f>;
    close($f);

    for(split(/ /, $cmdline)) {
        chomp;
        my ($arg, $val);
        if(/=/) {
            ($arg, $val) = $_ =~ /^([^=]+)=(.+)$/;
        }
        else {
            $arg = $_;
            $val = "";
        }
        next unless $arg eq "logo.brand";
        $brand = $val;
    }
    if($brand eq "chumby") {
        $brand = "";
    }
    elsif($brand ne "") {
        $brand = ".$brand";
    }
    return $brand;
}
