package WWW::Scraper::ISBN::AmazonUK_Driver;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = '0.24';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::AmazonUK_Driver - Search driver for Amazon.co.uk

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the (UK) Amazon online catalog.

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

my $AMA_SEARCH = 'http://www.amazon.co.uk/s/ref=nb_sb_noss?url=search-alias=us-stripbooks-tree&field-keywords=%s';
my $AMA_URL = 'http://www.amazon.co.uk/[^/]+/dp/[\dX]+/ref=sr_1_1.*?sr=1-1';
my $IN2MM = 25.4;       # number of inches in a millimetre (mm)
my $OZ2G = 28.3495231;  # number of grams in an ounce (oz)

#--------------------------------------------------------------------------

###########################################################################
# Public Interface

=head1 METHODS

=over 4

=item C<search()>

Creates a query string, then passes the appropriate form fields to the 
Amazon (UK) server.

The returned page should be the correct catalog page for that ISBN. If not the
function returns zero and allows the next driver in the chain to have a go. If
a valid page is returned, the following fields are returned via the book hash:

  isbn          (now returns isbn13)
  isbn10        
  isbn13
  ean13         (industry name)
  author
  title
  book_link
  thumb_link
  image_link
  pubdate
  publisher
  binding       (if known)
  pages         (if known)
  weight        (if known) (in grammes)
  width         (if known) (in millimetres)
  height        (if known) (in millimetres)

The book_link, thumb_link and image_link refer back to the Amazon (UK) website.

=back

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $mech = WWW::Mechanize->new();
    $mech->agent_alias( 'Linux Mozilla' );

    my $search = sprintf $AMA_SEARCH, $isbn;

	eval { $mech->get( $search ) };
    return $self->handler("Amazon UK website appears to be unavailable.")
	    if($@ || !$mech->success() || !$mech->content());

	my $content = $mech->content();
    my ($link) = $content =~ m!($AMA_URL)!s;
	return $self->handler("Failed to find that book on Amazon UK website.")
	    unless($link);

	eval { $mech->get( $link ) };
    return $self->handler("Amazon UK website appears to be unavailable.")
	    if($@ || !$mech->success() || !$mech->content());

	# The Book page
    my $html = $mech->content;
    my $data = {};

#print STDERR "\n# html=[$html]\n";

    ($data->{binding},$data->{pages})   = $html =~ m!<li><b>(Paperback|Hardcover):</b>\s*([\d.]+)\s*pages</li>!si;
    ($data->{weight})                   = $html =~ m!<li><b>Shipping Weight:</b>\s*([\d.]+)\s*ounces</li>!si;
    ($data->{height},$data->{width})    = $html =~ m!<li><b>\s*Product Dimensions:\s*</b>\s*([\d.]+) x ([\d.]+) x ([\d.]+) cm\s*</li>!si;
    ($data->{published})                = $html =~ m!<li><b>Publisher:</b>\s*(.*?)</li>!si;
    ($data->{isbn10})                   = $html =~ m!<li><b>ISBN-10:</b>\s*(.*?)</li>!si;
    ($data->{isbn13})                   = $html =~ m!<li><b>ISBN-13:</b>\s*(.*?)</li>!si;
    ($data->{content})                  = $html =~ m!<meta name="description" content="([^"]+)"!si;
    ($data->{description})              = $html =~ m!<h3 class="productDescriptionSource">Product Description</h3>\s*<div class="productDescriptionWrapper">\s*<P>([^<]+)!si;  

    $data->{content} =~ s/Amazon\.co\.uk.*?://i;
    $data->{content} =~ s/: Books.*//i;
	($data->{title},$data->{author}) = ($data->{content} =~ /\s*(.*?)(?:\s+by|,|:)\s+([^:]+)\s*$/)  unless($data->{author});

	($data->{thumb_link},$data->{image_link})  
                                        = $html =~ m!registerImage\("original_image",\s*"([^"]+)",\s*"<a href="\+'"'\+"([^"]+)"\+!;

    ($data->{publisher},$data->{pubdate}) = ($data->{published} =~ /\s*(.*?)(?:;.*?)?\s+\((.*?)\)/) if($data->{published});
    $data->{isbn10}  =~ s/[^\dX]+//g    if($data->{isbn10});
    $data->{isbn13}  =~ s/\D+//g        if($data->{isbn13});
	$data->{pubdate} =~ s/^.*?\(//      if($data->{pubdate});

    $data->{width}  = int($data->{width} * 10)  if($data->{width});
    $data->{height} = int($data->{height} * 10) if($data->{height});

	return $self->handler("Could not extract data from Amazon UK result page.")
		unless(defined $data->{isbn13});

    # trim top and tail
	foreach (keys %$data) { next unless(defined $data->{$_});$data->{$_} =~ s/^\s+//;$data->{$_} =~ s/\s+$//; }

	my $bk = {
		'ean13'		    => $data->{isbn13},
		'isbn13'		=> $data->{isbn13},
		'isbn10'		=> $data->{isbn10},
		'isbn'			=> $data->{isbn13},
		'author'		=> $data->{author},
		'title'			=> $data->{title},
		'image_link'	=> $data->{image_link},
		'thumb_link'	=> $data->{thumb_link},
		'publisher'		=> $data->{publisher},
		'pubdate'		=> $data->{pubdate},
		'book_link'		=> $mech->uri(),
		'content'		=> $data->{content},
		'binding'	    => $data->{binding},
		'pages'		    => $data->{pages},
		'weight'		=> $data->{weight},
		'width'		    => $data->{width},
		'height'		=> $data->{height},
		'description'	=> $data->{description}
	};
	$self->book($bk);
	$self->found(1);
	return $self->book;
}

q{currently reading: Nation by Terry Pratchett};

__END__

=head1 REQUIRES

Requires the following modules be installed:

L<WWW::Scraper::ISBN::Driver>,
L<WWW::Mechanize>,

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
