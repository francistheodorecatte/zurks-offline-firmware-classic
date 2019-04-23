#!/usr/bin/perl

use Net::UPnP::ControlPoint;
use Net::UPnP::AV::MediaServer;
use IO::Socket;


{
package UPnPWebServer;
 
use HTTP::Server::Simple::CGI;
use base qw(HTTP::Server::Simple::CGI);
 
my $upnp = Net::UPnP::ControlPoint->new();
my @dev_list = ();
my %dispatch = (
    '/scan' => \&scan_devices,
    '/devices' => \&get_devices,
    '/browse' => \&browse
 );

sub handle_request {
     my ($self, $cgi) = @_;
   
     my $path = $cgi->path_info();
     my $handler = $dispatch{$path};
 
     if (ref($handler) eq "CODE") {
         print "HTTP/1.0 200 OK\r\n";
         $handler->($cgi);
         
     } else {
         print "HTTP/1.0 404 Not found\r\n";
         print $cgi->header,
               $cgi->start_html('Not found'),
               $cgi->h1('Not found'),
               $cgi->end_html;
     }
 }


sub scan_devices{
   my $cgi = shift;
   
   @dev_list = ();
   while (@dev_list <= 0 || $retry_cnt > 5) {
      @dev_list = $upnp->search(st =>'upnp:rootdevice', mx => 3);
      $retry_cnt++;
   } 
   get_devices($cgi);
}

sub ini_scan_devices{
   
   @dev_list = ();
   while (@dev_list <= 0 || $retry_cnt > 5) {
      @dev_list = $upnp->search(st =>'upnp:rootdevice', mx => 3);
      $retry_cnt++;
   } 
}

sub get_devices {
   my $cgi = shift;
   
   my $jcallback = $cgi->param("jsoncallback");
   
   print $cgi->header(-type => "application/json", -charset => "utf-8");
   print  $jcallback . '({"devices":[';
   foreach $dev (@dev_list){
      my $device_type = $dev->getdevicetype();
      if ($device_type ne 'urn:schemas-upnp-org:device:MediaServer:1') {
         next;
      }
      my $name = $dev->getfriendlyname();
      unless ($dev->getservicebyname('urn:schemas-upnp-org:service:ContentDirectory:1')) {
         next;
      }
      my $udn = $dev->getudn();
      print  '{"id": "' . $udn . '","name": "'. $name .'"},';
   }
   print  "]})";
}

sub browse {
   my $cgi = shift;

   my $t_dev = $cgi->param("device");
   my $t_obj = $cgi->param("object");
   my $t_index = $cgi->param("index");
   my $t_count = $cgi->param("maxcount");
   my $jcallback = $cgi->param("jsoncallback");
   
   print $cgi->header(-type => "application/json", -charset => "utf-8");
   print  $jcallback . '({"items":[';

   if (scalar(@dev_list) == 0){
      scan_devices();
   }
   my $mediaServer = Net::UPnP::AV::MediaServer->new();
   my $i = 0;
   while ($t_dev ne $dev_list[$i]->getudn()){
      $i++;
      if ($i >= scalar(@dev_list)){
         print  "]})";
         return;
      }
   }
   $mediaServer->setdevice($dev_list[$i]);
   my @content_list = $mediaServer->getcontentlist(ObjectID => $t_obj,
                                                   Filter => "*",
                                                   StartingIndex => $t_index,
                                                   RequestedCount => $t_count,
                                                   SortCriteria => ""
                                                   );
   foreach my $content (@content_list) {
      if ($content->isitem()){
         my $url = $content->geturl();
         my $mtype = $content->getcontenttype();
         if ($mtype =~ /Audio|audio/){
            print  '{';
            print  '"type": "object",';
            print  '"id" : "' . $content->getid() . '",';
            print  '"title": "' . $content->gettitle() . '",';
            print  '"url": "' . $content->geturl() . '",';
            print  '"mime": "' . $mtype . '"';
            print  "},";
         }
      }
      elsif ($content->iscontainer()){
         print  '{';
         print  '"type": "container",';
         print  '"id" : "' . $content->getid() . '",';
         print  '"title": "' . $content->gettitle() . '"';
         print  "},";
      }
   }
   print  '],"index": "' . $t_index . '","device": "' . $t_dev . '","object": "' . $t_obj . '"})';
}
}

my $server = UPnPWebServer->new(9595);
$server->ini_scan_devices();
$server->background();

