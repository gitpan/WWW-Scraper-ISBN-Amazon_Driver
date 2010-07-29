package WWW::Scraper::ISBN::AmazonUS_Driver;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = '0.16';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::AmazonUS_Driver - Search driver for Amazon.com

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the (US) Amazon online catalog.

=cut

#--------------------------------------------------------------------------

###########################################################################
# Inheritence

use base qw(WWW::Scraper::ISBN::Driver);

###########################################################################
# Modules

use WWW::Mechanize;

###########################################################################
# Variables

my $AMA_SEARCH = 'http://www.amazon.com/s/ref=nb_sb_noss?url=search-alias=us-stripbooks-tree&field-keywords=%s';
my $AMA_URL = 'http://www.amazon.com/[^/]+/dp/[\dX]+/ref=sr_1_1.*?sr=1-1';
my $IN2MM = 25.4;       # number of inches in a millimetre (mm)
my $OZ2G = 28.3495231;  # number of grams in an ounce (oz)

#--------------------------------------------------------------------------

###########################################################################
# Public Interface

=head1 METHODS

=over 4

=item C<search()>

Creates a query string, then passes the appropriate form fields to the Amazon
(US) server.

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
  binding   (if known)
  pages     (if known)
  weight    (if known) (in grammes)
  width     (if known) (in millimetres)
  height    (if known) (in millimetres)

The book_link, thumb_link and image_link refer back to the Amazon (US) website.

=back

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $mechanize = WWW::Mechanize->new();
    $mechanize->agent_alias( 'Linux Mozilla' );

    my $search = sprintf $AMA_SEARCH, $isbn;

    $mechanize->get( $search );
    return $self->handler("Amazon US website appears to be unavailable.")
	    unless($mechanize->success());

	my $content = $mechanize->content();
    my ($link) = $content =~ m!($AMA_URL)!s;
	return $self->handler("Failed to find that book on Amazon US website.")
	    unless($link);

    $mechanize->get( $link );
	return $self->handler("Failed to find that book on Amazon US website.")
	    unless($mechanize->success());

	# The Book page
    my $html = $mechanize->content;
    my $data = {};

    #print STDERR "\n#$html";

    # Note: as the page changes, the older matches are now retained in the
    # event that these are ever reused.
	($data->{title},$data->{author})    = $html =~ /<meta name="description" content="(?:Amazon.com:)?\s*(.*?).\d+.:\s+([^:]+): Books/;
	($data->{title},$data->{author})    = $html =~ /<meta name="description" content="(?:Amazon.com: Books: )?\s*(.*?)(?:\s+by|,)\s+(.*)/       unless($data->{author});
	($data->{title},$data->{author})    = $html =~ /<meta name="description" content="(?:Amazon.com:)?\s*(.*?)(?:\s+by|,|:)\s+([^:]+): Books/   unless($data->{author});
    ($data->{binding},$data->{pages})   = $html =~ m!<li><b>(Paperback|Hardcover):</b>\s*([\d.]+)\s*pages</li>!s;
    ($data->{weight})                   = $html =~ m!<li><b>Shipping Weight:</b>\s*([\d.]+)\s*ounces</li>!s;
    ($data->{height},$data->{width})    = $html =~ m!<li><b>\s*Product Dimensions:\s*</b>\s*([\d.]+) x ([\d.]+) x ([\d.]+) inches\s*</li>!s;
    ($data->{published})                = $html =~ m!<li><b>Publisher:</b>\s*(.*?)</li>!s;
    ($data->{isbn10})                   = $html =~ m!<li><b>ISBN-10:</b>\s*(.*?)</li>!s;
    ($data->{isbn13})                   = $html =~ m!<li><b>ISBN-13:</b>\s*(.*?)</li>!s;
    ($data->{content})                  = $html =~ m!<meta name="description" content="([^"]+)"!s;

	($data->{thumb_link},$data->{image_link})  
                                        = $html =~ m!registerImage\("original_image",\s*"([^"]+)",\s*"<a href="\+'"'\+"([^"]+)"\+!;

    ($data->{publisher},$data->{pubdate}) = ($data->{published} =~ /\s*(.*?)(?:;.*?)?\s+\((.*?)\)/);
    $data->{isbn10} =~ s/[^\dX]+//g;
    $data->{isbn13} =~ s/\D+//g;

    $data->{weight} = int($data->{weight} * $OZ2G)  if($data->{weight});
    $data->{width}  = int($data->{width} * $IN2MM)  if($data->{width});
    $data->{height} = int($data->{height} * $IN2MM) if($data->{height});

	# trim top and tail
	foreach (keys %$data) { next unless(defined $data->{$_});$data->{$_} =~ s/^\s+//;$data->{$_} =~ s/\s+$//; }

	return $self->handler("Could not extract data from Amazon US result page.")
		unless(defined $data->{isbn13});

	my $bk = {
		'ean13'		    => $data->{isbn13},
		'isbn13'		=> $data->{isbn13},
		'isbn10'		=> $data->{isbn10},
		'isbn'			=> $data->{isbn10},
		'author'		=> $data->{author},
		'title'			=> $data->{title},
		'image_link'	=> $data->{image_link},
		'thumb_link'	=> $data->{thumb_link},
		'publisher'		=> $data->{publisher},
		'pubdate'		=> $data->{pubdate},
		'book_link'		=> $mechanize->uri(),
		'content'		=> $data->{content},
		'binding'	    => $data->{binding},
		'pages'		    => $data->{pages},
		'weight'		=> $data->{weight},
		'width'		    => $data->{width},
		'height'		=> $data->{height}
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

=head1 BUGS, PATCHES & FIXES

There are no known bugs at the time of this release. However, if you spot a
bug or are experiencing difficulties that are not explained within the POD
documentation, please send an email to barbie@cpan.org or submit a bug to the
RT system (http://rt.cpan.org/Public/Dist/Display.html?Name=WWW-Scraper-ISBN-Amazon_Driver).
However, it would help greatly if you are able to pinpoint problems or even
supply a patch.

Fixes are dependant upon their severity and my availablity. Should a fix not
be forthcoming, please feel free to (politely) remind me.

=head1 AUTHOR

  Barbie, <barbie@cpan.org>
  for Miss Barbell Productions <http://www.missbarbell.co.uk>.

=head1 COPYRIGHT & LICENSE

  Copyright (C) 2004-2010 Barbie for Miss Barbell Productions

  This module is free software; you can redistribute it and/or
  modify it under the Artistic Licence v2.

=cut
