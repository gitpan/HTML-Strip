package HTML::Strip;

use 5.006;
use warnings;
use strict;

require Exporter;
require DynaLoader;

our @ISA = qw(Exporter DynaLoader);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use HTML::Strip ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
                                   strip_html
                                  ) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
                );

our $VERSION = '0.03';

bootstrap HTML::Strip $VERSION;

# Preloaded methods go here.

my @default_striptags = qw( title
                            style
                            script
                            applet );

sub new {
  my $class = shift;
  my $obj = create();
  $obj->set_striptags( \@default_striptags );
  bless $obj, $class;
}

sub parse {
  my ($self, $text) = @_;
  return $self->strip_html( $text );
}

sub eof {
  my $self = shift;
  $self->reset();
}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

HTML::Strip - Perl extension for stripping HTML markup from text.

=head1 SYNOPSIS

  use HTML::Strip;

  my $hs = HTML::Strip->new();

  $hs->parse( $html );
  $hs->eof;

=head1 DESCRIPTION

This module simply strips HTML-like markup from text in a very quick
and brutal manner.
It's written in XS, so is vastly more efficient than using regexes to
accomplish the same task.

It does I<not> do any syntax checking (if you want that, use
L<HTML::Parser>), instead it merely applies the following rules:

=over 4

=item 1

Anything that looks like a tag, or group of tags will be replaced with
a single space character. Tags are considered to be anything that
starts with a 'E<lt>' and ends with a 'E<gt>', with the caveats that:

=over 4

=item a

A 'E<gt>' character can appear within quotes within the tag without
ending it. Quotes are considered to start with either a ' or a "
character, and end with a matching character I<not> preceeded by an
even number or escaping slashes (i.e. '\"' does not end the quote but
'\\\\"' does.

=item b

If the tag starts with an exclamation mark, it is assumed to be a
declaration or a comment. 'E<gt>' characters do not end the tag if
they appear within pairs of double dashes (e.g. '<!-- <a
href="old.htm">old page</a> -->").

=back

=item 2

Anything the appears within so-called 'strip tags' is stripped as
well. By default, these tags are 'title', 'script', 'style' and
'applet'.

=back

HTML::Strip maintains state between calls, so you can parse a document
in chunks should you wish. If one chunk ends half-way through a tag,
it will remember this, and expect the next call to parse to start with
the remains of said tag.
If this is not going to be the case, be sure to call $hs->eof()
between calls to $hs->parse.

=head2 METHODS

=item new()

Constructor. Takes no arguments.

=item parse()

Takes a string as an argument, returns it stripped of HTML.

=item eof()

Resets the current state information, ready to parse a new block of HTML.

=item set_striptags()

Takes a reference to an array of strings, which replace the current
set of strip tags.

=head2 LIMITATIONS

=over 4

=item Whitespace

Despite only outputting one space character per group of tags,
HTML::Strip can often output more than desired; such as with the
following HTML:

 <h1> HTML::Strip </h1> <p> <em> <strong> fast, and brutal </strong> </em> </p>

Which gives the following output: " HTML::Strip         Fast and brutal      "

Thus, you will probably want to post-filter the output of HTML::Strip
to remove excess whitespace.

=item HTML Entities

HTML::Strip attempt no decoding of HTML entities. Use the
imaginatively-named L<HTML::Entities> (specifically, the
decode_entities() method) for this purpose.

=head2 EXPORT

None by default.

=head1 AUTHOR

Alex Bowley E<lt>kilinrax@cpan.orgE<gt>

=head1 SEE ALSO

L<perl>, L<HTML::Parser>, L<HTML::Entities>

=cut
