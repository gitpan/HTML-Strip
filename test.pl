# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 15 };
use HTML::Strip;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

my $hs = new HTML::Strip;

ok( $hs->parse( '<em>test</em>' ) eq 'test ' );

ok( $hs->parse( 'test' ) eq 'test' );

ok( $hs->parse( '<p align="center">test</p>' ) eq ' test ' );

ok( $hs->parse( '<p align="center>test</p>' ) eq '' );

ok( $hs->parse( 'foo' ) eq '' );

$hs->eof;

ok( $hs->parse( 'foo' ) eq 'foo' );

ok( $hs->parse( '<!-- <p>foo</p> bar -->baz' ) eq ' baz' );

ok( $hs->parse( '<script>foo</script>bar' ) eq ' bar' );

my $hs2 = new HTML::Strip;
$hs2->set_striptags( [ 'foo' ] );

ok( $hs2->parse( '<script>foo</script>bar' ) eq 'foo bar' );

ok( $hs2->parse( '<foo>foo</foo>bar' ) eq ' bar' );

ok( $hs->parse( '<script>foo</script>bar' ) eq ' bar' );

my @striptags = qw(baz quux);
$hs->set_striptags( @striptags );

ok( $hs->parse( '<baz>fumble</baz>bar<quux>foo</quux>' ) eq ' bar ' );

ok( $hs->parse( '<baz>fumble<quux/>foo</baz>bar' ) eq 'bar' );

ok( $hs->parse( '<foo> </foo> <bar> baz </bar>' ) eq '    baz ' );
