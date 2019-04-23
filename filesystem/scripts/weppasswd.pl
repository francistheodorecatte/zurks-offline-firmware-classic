#!/usr/bin/perl
# ken@chumby.com


my $script_root = $ENV{CHUMBY_SCRIPTS} || '/usr/chumby/scripts';
my $bin_root = $ENV{CHUMBY_BINS} || '/usr/bin';

main();

sub main
{
    my $wepPassword = "";
        
    if( $ARGV[0] eq "-f" )
    {
        if( @ARGV != 2 )
        {
            syntax();
        }
        else
        {
            open( F, "<$ARGV[1]" ) || die( "Unable to open: $!" );
            $wepPassword = <F>;
            close( F );
            chomp( $wepPassword );
        }
    }
    else
    {
        if( @ARGV != 1 )
        {
            syntax();
        }
        else
        {
            $wepPassword = $ARGV[0];
        }
    }
    
    my $wep128bit = gen128bitWEP( $wepPassword );

    genAppleKey( $wepPassword );

    print "$wep128bit\n";
    
    gen64bitWEP( $wepPassword );
}

sub genAppleKey
{
    my ( $wepPassword ) = @_;

    my $escString = shellEscape( $wepPassword );
    print `$bin_root/wepkeygen $escString 1`;
    print `$bin_root/wepkeygen $escString 0`;
}

sub gen64bitWEP
{
    my ( $wepPassword ) = @_;
    
    my $escString    = shellEscape( $wepPassword );
    print `$bin_root/64bitwep $escString`;
}

sub gen128bitWEP
{
    my ( $wepPassword ) = @_;
    
    my $paddedString = substr( padTo64bytes( $wepPassword ), 0, 64 );
    my $escString    = shellEscape( $paddedString );
    my $md5sum       = `echo -n $escString |md5sum`;
    $md5sum =~ tr/a-f/A-F/;
    return substr( $md5sum, 0, 26 );
}

sub padTo64bytes()
{
    my ( $val ) = @_;

    my $ret = "";
    my $rep = 1 + ( 64 / length( $val ) );
    for ( my $x = 0; $x < $rep; $x++ )
    {
        $ret = $ret . $val;
    }

    return substr( $ret, 0, 64 );
}

sub shellEscape
{
    my ( $string ) = @_;

    $string = join( '\\', split( //, $string ) );

    return "\\$string";
}

sub syntax
{
    printf( "$0 [ password | -f filename ]\n" );
    exit();
}
