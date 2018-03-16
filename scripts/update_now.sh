#!/usr/bin/perl
#
# update_now.sh - Calls prepare_ota_update.sh to download the update file,
#                 then installs the update by calling update_launch.sh.
#
# Sean Cross
# (c) Copyright Chumby Industries 2006-2009
# All rights reserved
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

$ENV{'PATH'} .= ":/usr/chumby/scripts";

# Daemonize.  Fork off, and have the parent exit.
# This will prevent the flash player from killing us when it exits.
defined(my $pid = fork) or fail("Could not fork: $!");
exit if $pid;
chdir('/');


system("/usr/chumby/scripts/stop_control_panel > /tmp/st.out 2> /tmp/st.err");
system("switch_fb.sh 0");
system("imgtool --mode=draw /bitmap/" . $ENV{'VIDEO_RES'} . "/downloading_software.bin" . get_brand() . ".jpg");



# Ensure /mnt/storage is mounted
if(system("mount | grep -q /mnt/storage")) {
    if(system("mkdir -p /mnt/storage && mount -text3 /mnt/storage")) {
        fail("Unable to mount /mnt/storage.\n"
           . "Please restore to factory defaults and try again.\n");
    }
}


# Remove this file, if it exists.  It points to where the update file will
# live, and we want to re-create it as part of the update process.
system("rm -f /psp/update_prepared");
system("rm -f /tmp/update.log");


# Call check_update.sh, which will create /psp/UPDATE1 and /psp/UPDATE1_MD5
system("check_update.sh >> /tmp/update.log");


# Download the update.  This will put the path of the file in
# /psp/update_prepared.
system("prepare_ota_update.sh >> /tmp/update.log");


# If the file doesn't exist, then the update didn't complete successfully.
if(! -e "/psp/update_prepared") {
    print STDERR 
        "prepare_ota_update.sh didn't create the file /psp/update_prepared";
    fail("No update was found");
    exit(1);
}



# Grab the file we're using to update and do the update.
open(my $f, '<', "/psp/update_prepared")
    or fail("Unable to open /psp/update_prepared: $!");
my $update_file = <$f>;
chomp $update_file;
close($f);

if(! -e $update_file) {
    fail("Could not find the update file $update_file");
}


sleep(1);
system("ORIGIN=OTA /usr/chumby/scripts/update_launch.sh $update_file "
            . "> /tmp/up.out 2> /tmp/up.err");


while(1) {
    sleep(10);
}



sub fail {
    my ($msg) = @_;
	system("imgtool --mode=draw /bitmap/" . $ENV{'VIDEO_RES'} .  "/update_unsuccessful.bin" . get_brand() . ".jpg");
    system("echo '$msg' >> /tmp/update.log'");
    system("fbwrite '\n\n$msg'");
    die($msg);
}

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

