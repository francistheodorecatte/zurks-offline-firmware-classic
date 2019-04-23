#!/usr/bin/perl
# Extract mp4 url from a youtube watch page

$|=0;

main();

sub main()
{
  if ($ARGV[0] eq "")
  {
  	die( "No youtube ID specified" );
  }
  #printf "Processing youtube ID %s\n", $ARGV[0];
  # Process <script type="text/javascript"> elements within <head> looking for swfArgs
  # This is pretty simplistic and assumes Youtube is not going to change their html style
  my $ytid = $ARGV[0];
  open( PAGE, "wget -O - \"http://www.youtube.com/watch?v=$ytid\" 2> /dev/null |" ) or die( "Could not open wget: $!" );
  my $head_state = 0;
  my $javascript_state = 0;
  my $url_found = 0;
  while (<PAGE>)
  {
  	if ($_ =~ /.*<head[^>]*\>/)
	{
		$head_state = 1;
	}
	elsif ($head_state == 1 && $_ =~ /.*<\/head>/)
	{
		$head_state = 2;
	}
	if ($head_state == 1)
	{
		if ($_ =~ /.*<script type="text\/javascript">/)
		{
			$javascript_state = 1;
		}
		elsif ($javascript_state == 1 && $_ =~ /.*<\/script>/)
		{
			$javascript_state = 0;
		}
		if ($javascript_state == 1)
		{
			if ($_ =~ /.*swfArgs *= *([^;]+);/)
		  	{
  				my $swfArgs = $1;
  				if ($swfArgs =~ /"t": *"([^"]+)"/)
  				{
  					my $t = $1;
			  		printf( "http://www.youtube.com/get_video?fmt=18&video_id=%s&t=%s\n", $ytid, $t );
			  		$url_found++;
			  	}
			  	else
			  	{
			  		die( "Found swfArgs=$swfArgs but no t element???" );
			  	}
		  	}
		}
  	}
  }
  close( PAGE );
  ($url_found > 0) or die( "Failed to build url" );
}

