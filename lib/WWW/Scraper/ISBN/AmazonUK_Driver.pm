package WWW::Scraper::ISBN::AmazonUK_Driver;

use strict;
use warnings;

use vars qw($VERSION @ISA);
$VERSION = '0.01';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::AmazonUK_Driver - Search driver for the (UK) Amazon online
catalog.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the (UK) Amazon online catalog.

=cut

### CHANGES ###############################################################
#   0.01   15/04/2004   Initial Release
###########################################################################

#--------------------------------------------------------------------------

###########################################################################
#Library Modules                                                          #
###########################################################################

use WWW::Scraper::ISBN::Driver;
use WWW::Mechanize;
use Template::Extract;

###########################################################################
#Constants                                                                #
###########################################################################

use constant	AMAZON	=> 'http://www.amazon.co.uk/';
use constant	SEARCH	=> 'http://www.amazon.co.uk/';

#--------------------------------------------------------------------------

###########################################################################
#Inheritence		                                                      #
###########################################################################

@ISA = qw(WWW::Scraper::ISBN::Driver);

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
	return undef	unless($mechanize->success());

	$mechanize->form_number(1);
	$mechanize->set_fields( 'field-keywords' => $isbn, 'url' => 'index=books-uk' );
	$mechanize->submit();

	return undef	unless($mechanize->success());

	# The Book page
	my $template = <<END;
<META name="description" content="[% title %], [% author %], [% ... %]">[% ... %]
<form method=POST action=http://www.amazon.co.uk/exec/obidos/handle-buy-box=[% ... %]>
<a href="[% image_link %]"><img src="[% thumb_link %]" [% ... %]
pages
([% pubdate %])
<li>
<b>Publisher:</b> [% publisher %]
<li>
<b>ISBN:</b>[% isbn %]</li>
END

	my $extract = Template::Extract->new;
    my $data = $extract->extract($template, $mechanize->content());

	unless(defined $data) {
		print "Error extracting data from Amazon.co.uk result page.\n"	if $self->verbosity;
		$self->error("Could not extract data from Amazon.co.uk result page.\n");
		$self->found(0);
		return 0;
	}

	# trim top and tail
	foreach (keys %$data) { $data->{$_} =~ s/^\s+//;$data->{$_} =~ s/\s+$//; }
	$data->{pubdate} =~ s/^.*?\(//;

	my $bk = {
		'isbn'			=> $data->{isbn},
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

  Copyright (C) 2002-2004 Barbie for Miss Barbell Productions
  All Rights Reserved.

  This module is free software; you can redistribute it and/or 
  modify it under the same terms as Perl itself.

=cut

