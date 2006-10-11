package WWW::Scraper::ISBN::AmazonUS_Driver;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = '0.06';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::AmazonUS_Driver - Search driver for the (US) Amazon online
catalog.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the (US) Amazon online catalog.

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

use constant	AMAZON	=> 'http://www.amazon.com/';
use constant	SEARCH	=> 'http://www.amazon.com/';

#--------------------------------------------------------------------------

###########################################################################
#Interface Functions                                                      #
###########################################################################

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

The book_link, thumb_link and image_link refer back to the Amazon (US) website. 

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $mechanize = WWW::Mechanize->new();
	$mechanize->get( SEARCH );
	return	unless($mechanize->success());

	# Amazon have a couple of templates for the front page.
	my @forms = $mechanize->forms;
	my ($index,$input) = (0,0);
	foreach my $form (@forms) {
		$index++;
		$input = $index	if($form->find_input('field-keywords'));
	}

	my $content = $mechanize->content();
	my ($keyword) = ($content =~ /<option value="(index=stripbooks.*?)">Books/);
	$mechanize->form_number($input);
	$mechanize->set_fields( 'field-keywords' => $isbn, 'url' => $keyword );
	$mechanize->submit();

	return	unless($mechanize->success());

	# The Book page
	my $template = <<END;
<meta name="description" content="[% content %]"[% ... %]
<div class="buying">[% ... %]
<div style=[% ... %]
registerImage("original_image", "[% thumb_link %]", "<a href="+'"'+"[% image_link %]"+[% ... %]
<b class="h1">Product Details</b><br />[% ... %]
<li><b>Publisher:</b>[% published %]</li>
END

	my $extract = Template::Extract->new;
    my $data = $extract->extract($template, $mechanize->content());

	return $self->handler("Could not extract data from amazon.com result page.")
		unless(defined $data);

	# trim top and tail
	foreach (keys %$data) { $data->{$_} =~ s/^\s+//;$data->{$_} =~ s/\s+$//; }

	($data->{title},$data->{author}) = 
		($data->{content} =~ /(?:Amazon.com: Books: )?\s*(.*?)(?:\s+by|,)\s+(.*)/);
	($data->{publisher},$data->{pubdate}) = 
		($data->{published} =~ /\s*(.*?)(?:;.*?)?\s+\((.*?)\)/);

	my $bk = {
		'isbn'			=> $isbn,
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

=back

=head1 REQUIRES

Requires the following modules be installed:

=over 4

=item L<WWW::Scraper::ISBN::Driver>

=item L<WWW::Mechanize>

=item L<Template::Extract>

=back

=head1 SEE ALSO

=over 4

=item L<WWW::Scraper::ISBN>

=item L<WWW::Scraper::ISBN::Record>

=item L<WWW::Scraper::ISBN::Driver>

=back

=head1 AUTHOR

  Barbie, E<lt>barbie@cpan.orgE<gt>
  Miss Barbell Productions, L<http://www.missbarbell.co.uk/>

=head1 COPYRIGHT

  Copyright (C) 2004-2005 Barbie for Miss Barbell Productions
  All Rights Reserved.

  This module is free software; you can redistribute it and/or 
  modify it under the same terms as Perl itself.

=cut

