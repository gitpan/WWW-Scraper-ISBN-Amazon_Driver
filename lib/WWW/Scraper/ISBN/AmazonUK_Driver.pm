package WWW::Scraper::ISBN::AmazonUK_Driver;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = '0.12';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::AmazonUK_Driver - Search driver for the (UK) Amazon online
catalog.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the (UK) Amazon online catalog.

=cut

#--------------------------------------------------------------------------

###########################################################################
#Inheritence		                                                      #
###########################################################################

use base qw(WWW::Scraper::ISBN::Driver);

###########################################################################
#Library Modules                                                          #
###########################################################################

use WWW::Mechanize;
use Template::Extract;

###########################################################################
#Constants                                                                #
###########################################################################

use constant	AMAZON	=> 'http://www.amazon.co.uk/';
use constant	SEARCH	=> 'http://www.amazon.co.uk/';

#--------------------------------------------------------------------------

###########################################################################
#Interface Functions                                                      #
###########################################################################

=head1 METHODS

=over 4

=item C<search()>

Creates a query string, then passes the appropriate form fields to the Amazon
(UK) server.

The returned page should be the correct catalog page for that ISBN. If not the
function returns zero and allows the next driver in the chain to have a go. If
a valid page is returned, the following fields are returned via the book hash:

  isbn
  author
  title
  book_link
  thumb_link
  image_link
  pubdate
  publisher

The book_link, thumb_link and image_link refer back to the Amazon (UK) website.

=back

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $mechanize = WWW::Mechanize->new();
	$mechanize->get( SEARCH );
    return $self->handler("Amazon UK website appears to be unavailable.")
	    unless($mechanize->success());

#print STDERR "\n# content1=[".$mechanize->content()."]\n";

    $mechanize->form_number(1);
	$mechanize->set_fields( 'field-keywords' => $isbn, 'url' => 'search-alias=stripbooks' );
	$mechanize->submit();

	return $self->handler("Failed to find that book on Amazon UK website.")
	    unless($mechanize->success());

	# The Book page
	my $template = <<END;
<title>Amazon.co.uk: [% content %]: Books</title>[% ... %]
registerImage("original_image", "[% thumb_link %]"[% ... %]
<a href="+'"'+"[% image_link %]"[% ... %]
Product details[% ... %]
<b>Publisher:</b> [% publisher %] ([% pubdate %])[% ... %]
<li><b>ISBN-10:</b> [% isbn10 %]</li>[% ... %]
<li><b>ISBN-13:</b> [% isbn13 %]</li>[% ... %]
END

#print STDERR "\n# content2=[".$mechanize->content()."]\n";

    my $extract = Template::Extract->new;
    my $data = $extract->extract($template, $mechanize->content());

	return $self->handler("Could not extract data from Amazon UK result page.")
		unless(defined $data);

	($data->{title},$data->{author}) = ($data->{content} =~ /\s*(.*?)(?:\s+by|,|:)\s+([^:]+)\s*$/)  unless($data->{author});

    # trim top and tail
	foreach (keys %$data) { $data->{$_} =~ s/^\s+//;$data->{$_} =~ s/\s+$//; }
	$data->{pubdate} =~ s/^.*?\(//;

	my $bk = {
		'isbn13'		=> $data->{isbn13},
		'isbn'			=> $data->{isbn10},
		'author'		=> $data->{author},
		'title'			=> $data->{title},
		'image_link'	=> $data->{image_link},
		'thumb_link'	=> $data->{thumb_link},
		'publisher'		=> $data->{publisher},
		'pubdate'		=> $data->{pubdate},
		'book_link'		=> $mechanize->uri()
	};
	$self->book($bk);
	$self->found(1);
	return $self->book;
}

1;
__END__

=head1 REQUIRES

Requires the following modules be installed:

L<WWW::Scraper::ISBN::Driver>,
L<WWW::Mechanize>,
L<Template::Extract>

=head1 SEE ALSO

L<WWW::Scraper::ISBN>,
L<WWW::Scraper::ISBN::Record>,
L<WWW::Scraper::ISBN::Driver>

=head1 AUTHOR

  Barbie, <barbie@cpan.org>
  for Miss Barbell Productions <http://www.missbarbell.co.uk>.

=head1 COPYRIGHT & LICENSE

  Copyright (C) 2004-2007 Barbie for Miss Barbell Productions

  This module is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.

The full text of the licenses can be found in the F<Artistic> file included
with this module, or in L<perlartistic> as part of Perl installation, in
the 5.8.1 release or later.

=cut
