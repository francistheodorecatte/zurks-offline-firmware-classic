package BDXML;
# The brain-dead XML parser.
# Kids, don't try this at home.
#
# This is an XML parser that poorly parses XML.  Its primary virtue, and
# the reason why we're using it, is that it is written entirely in Perl,
# and uses no external modules.
#
# Its primary source of brain-deadness, aside from its inefficiency, stems
# from the fact that it will completely choke if you try to parse something
# like:
#  <foo> This is <bar/> some <baz/> xml </foo>
# It supports a node with a value, OR a node with children.  Not both.

{
    my @chars;

    sub init_string {
        my ($string) = @_;
#        print STDERR "Initializing braindead XML parser with string [$string]\n";
        @chars = split(//, $string);
    }

    sub get_char {
        if( !@chars ) {
            return undef;
        }
        return shift @chars;
    }
    sub unget_char {
        unshift(@chars, $_[0]);
    }
}

# Parses the string passed in, and then returns a complex Perl data
# structure representing the data.
#
# Returns a hashref with the following keys:
#   - children      arrayref of nodes, structured just like this one
#   - properties    hashref containing the tag's properties
#   - name          scalar representing this node's name
#   - value         scalar representing this node's value
#   - children_hash hashref of nodes.  May prove useful.
sub parse {
    my ($string) = @_;

    # Allow users to call BDXML->parse() or BDXML::parse().
    if( defined($string) && $string eq 'BDXML' ) {
        (undef, $string) = @_;
    }

    # If a string is provided, use that to parse the string.
    if( defined $string ) {
        init_string($string);
    }

    # TODO:
    # * Interpret CDATA strings
    # * Handle &html; entities.

    # Valid values for state:
    # 0 - no state (default)
    # 1 - Beginning to read in a tag.
    # 2 - Reading in a <? ... ?> tag.
    # 3 - Tag inside a " string.
    # 4 - Tag inside a ' string.
    # 5 - About to close childless tag.  Current character should be ">".
    # 6 - About to close tag.
    # 7 - End of opening tag reached, switch to processing children.
    # 8 - end of childless tag reached, switch to no state.
    # 9 - Reading in a tag, but done with the tag name, so onto properties.
    # 10- Read in a property name, now waiting for the property value.
    my $state = 0;

    my $currentTag      = "";
    my $currentString   = "";
    my $currentProperty = undef;
    my $properties      = {};
    my $children        = [];
    my $name            = undef;
    my $value           = undef;

    my $tag = {};

    my $c;
    while( defined($c = get_char()) ) {
#        print STDERR "C: $c  State: $state  currentString: $currentString  name: ";
#        print STDERR ($name?$name:"(undef)");
#        print STDERR "\n";

        # Handle quotes in the property tag.
        if( (($c eq '"') && ($state == 3)) 
         || (($c eq "'") && ($state == 4)) ) {
            $state = 9;
            $$properties{$currentProperty} = $currentString;
            $currentProperty            = undef;
            $currentString              = "";
            next;
        }


        # Handle the <?xml version="1.0" encoding="UTF-8"?> greeting.
        if( $c eq '?' && $state == 1 ) {
            $state = 2;
            next;
        }
        if( $c eq '?' && $state == 2 ) {
            my $d = get_char();
            if( $d ne '>' ) {
                die("I thought I was looking at an XML header, "
                  . "but I was wrong.  Malformed XML.");
            }
            $state = 0;
            next;
        }
                

        # Handle the opening of the tag.
        if( $c eq '<' ) {
            if( $state != 0 ) {
                die("Invalid XML stream");
            }

            # XXX This is a hack, but seems to work with most XML we deal
            # with.
            if( length($currentString) > 0 ) {
                $value = $currentString;
                $currentString = "";
            }

            # If name is defined, then we've already hit the opening and
            # closing for the current tag, so recurse down.
            if( defined $name ) {

                # But make sure this isn't a closing tag.
                my $peek = get_char();
                unget_char($peek);
                if( $peek ne '/' ) {
#                    print STDERR "Recursing downwards\n";
                    unget_char($c);
                    my $child = parse();
                    push(@$children, $child);
                    $state = 0;
#                    print STDERR "Returned.  Looping...\n";
                    next;
                }
            }

            # Otherwise, this is the first character we examine.
            $state = 1;
            $currentString = "";
            next;
        }

        # Potentially an indication of a close-tag.
        # Ignore states where we're currently in a quote (state 3 or 4).
        if( $c eq '/' && $state != 0 && $state != 3 && $state != 4 ) {
            if( $state == 1 || $state == 9 ) {
                $state = 5;
                next;
            }
            die("Found '/' character where it wasn't expected");
        }

        if( $c eq '>' ) {
            # This indicates a successful close of the childless tag.
            if( $state == 5 ) {
                $state = 8;
                last;
            }

            if( $state == 6 ) {
                if( $currentString ne $name ) {
                    die("Tags aren't properly nexted.  Closed tag "
                      . "$currentString while processing tag $name");
                }

                # We've gathered all information about the current tag.
                # Switch to a mode wherein the tag's properties are
                # assigned.
                $state = 7;
                last;
            }

            if( $state == 1 ) {
                $name = $currentString;
            }

            # Now that the tag has been read in, switch to default mode.
            $state = 0;
            $currentString = "";
            next;
        }

        if( $state == 1 && $c =~ /\s/ ) {
            $state         = 9;
            $name          = $currentString;
            $currentString = "";
            next;
        }

        if( $state == 9 ) {
            if( $c =~ /\S/ ) {
                if( $c eq '=' ) {
                    $currentProperty = $currentString;
                    $currentString   = "";
                    $state           = 10;
                    next;
                }

                $currentString .= $c;
            }
            next;
        }

        if( $state == 10 ) {
            if( $c eq '"' ) {
                $state = 3;
                next;
            }
            if( $c eq "'" ) {
                $state = 4;
                next;
            }
            if( $c =~ /\S/ ) {
                die("Unexpected character $c found while looking for ' or \"");
            }
        }

        $currentString .= $c;
    }


    # Upon exiting the loop, the state ought to be 7 or 8, indicating the
    # tag was successfully processed and needs to be examined now.
    # If, however, the state was 0, then nothing happened.
    if( $state == 0 ) {
        return;
    }
    elsif( $state != 7 && $state != 8 ) {
        die("Did not expect to exit loop in state $state");
    }

    $$tag{'name'}           = $name;
    $$tag{'properties'}     = $properties;
    $$tag{'children'}       = $children;
    $$tag{'value'}          = $value;
    $$tag{'children_hash'}  = {};

    # Copy the children into the children_hash array.
    foreach my $child(@$children) {
        $$tag{'children_hash'}->{$$child{'name'}} = $child;
    }

    # State 8 indicates childless tag.
#    if( $state == 8 ) {
#        $$tag{'children'} = undef;
#    }


#    print STDERR "Returning tag: ", YAML::Dump($tag);
    return $tag;
}


# Turns a BDXML structure into an XML string.
sub unparse {
    my ($node) = @_;
    my $str = "<" . $$node{'name'};
    if(defined($$node{'properties'})) {
        while( my ($key, $value) = each %{$$node{'properties'}} ) {
            $str .= " $key=\"$value\"";
        }
    }
    if(defined($$node{'value'})) {
        $str .= ">" . $$node{'value'} . "</" . $$node{'name'} . ">";
    }
    elsif(defined($$node{'children'}) && @{$$node{'children'}}) {
        $str .= ">";
        for my $child(@{$$node{'children'}}) {
            $str .= unparse($child);
        }
        $str .= "</" . $$node{'name'} . ">";
    }
    else {
        $str .= " />";
    }
    $str .= "\n";
    return $str;
}



sub test {
    my $data;

    $data = parse("");
    $data = parse("String");
    $data = parse("<test>string</test>");
    $data = parse("<test/>");
    $data = parse("<test/>\n");
    $data = parse("\n<test/>\n");
    $data = parse("<test/><test/><test/>");
    $data = parse("<test/>\n<test/>");
    $data = parse("<test1/><test2></test2>");
    
    $data = parse("<foo value=\"bar\"></foo>");

    $data = parse("<foo value=\"baz\"><quux/></foo>");

    $data = parse("<bba tt=\"qqq\"><zz yy=\"sss\"/></bba>");
}




1;
