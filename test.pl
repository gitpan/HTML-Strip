# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 17 };
use HTML::Strip;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

my $hs = new HTML::Strip;

ok( $hs->parse( 'test' ), 'test' );
$hs->eof;

ok( $hs->parse( '<em>test</em>' ), 'test' );
$hs->eof;

ok( $hs->parse( 'foo<br>bar' ), 'foo bar' );
$hs->eof;

ok( $hs->parse( '<p align="center">test</p>' ), 'test' );
$hs->eof;

ok( $hs->parse( '<p align="center>test</p>' ), '' );
$hs->eof;

ok( $hs->parse( '<foo>bar' ), 'bar' );
ok( $hs->parse( '</foo>baz' ), ' baz' );
$hs->eof;

ok( $hs->parse( '<!-- <p>foo</p> bar -->baz' ), 'baz' );
$hs->eof;

ok( $hs->parse( '<img src="foo.gif" alt="a > b">bar' ), 'bar' );
$hs->eof;

ok( $hs->parse( '<script>if (a<b && a>c)</script>bar' ), 'bar' );
$hs->eof;

ok( $hs->parse( '<# just data #>bar' ), 'bar' );
$hs->eof;

#ok( $hs->parse( '<![INCLUDE CDATA [ >>>>>>>>>>>> ]]>bar' ), 'bar' );
#$hs->eof;

ok( $hs->parse( '<script>foo</script>bar' ), 'bar' );
$hs->eof;

my $html_entities_p = eval 'require HTML::Entities' ? '' : 'HTML::Entities not available';
skip( $html_entities_p, $hs->parse( '&#060;foo&#062;' ), '<foo>' );
$hs->eof;
skip( $html_entities_p, $hs->parse( '&lt;foo&gt;' ), '<foo>' );
$hs->eof;
$hs->set_decode_entities(0);
skip( $html_entities_p, $hs->parse( '&#060;foo&#062;' ), '&#060;foo&#062;' );
$hs->eof;
skip( $html_entities_p, $hs->parse( '&lt;foo&gt;' ), '&lt;foo&gt;' );
$hs->eof;


my $hs2 = new HTML::Strip;
$hs2->set_striptags( [ 'foo' ] );

ok( $hs2->parse( '<script>foo</script>bar' ), 'foo bar' );
$hs2->eof;

ok( $hs2->parse( '<foo>foo</foo>bar' ), 'bar' );
$hs2->eof;

ok( $hs->parse( '<script>foo</script>bar' ), 'bar' );
$hs->eof;

my @striptags = qw(baz quux);
$hs->set_striptags( @striptags );

ok( $hs->parse( '<baz>fumble</baz>bar<quux>foo</quux>' ), 'bar' );
$hs->eof;

ok( $hs->parse( '<baz>fumble<quux/>foo</baz>bar' ), 'bar' );
$hs->eof;

ok( $hs->parse( '<foo> </foo> <bar> baz </bar>' ), '   baz ' );
$hs->eof;
