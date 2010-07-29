#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 37;

###########################################################

use WWW::Scraper::ISBN;
my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

SKIP: {
	skip "Can't see a network connection", 36   if(pingtest());

    $scraper->drivers("AmazonUK");

    # search with an ISBN 10 value

	my $isbn = "0201795264";
	my $record = $scraper->search($isbn);

    unless($record->found) {
		diag($record->error);
    } else {
		is($record->found,1);
		is($record->found_in,'AmazonUK');

		my $book = $record->book;
		is($book->{'isbn'},         '0201795264'    ,'.. isbn found');
		is($book->{'isbn10'},       '0201795264'    ,'.. isbn10 found');
		is($book->{'isbn13'},       '9780201795264' ,'.. isbn13 found');
		is($book->{'ean13'},        '9780201795264' ,'.. ean13 found');
		is($book->{'publisher'},    'Addison Wesley','.. publisher found');
		like($book->{'pubdate'},    qr/2004$/       ,'.. pudate found');    # this date fluctuates throughout Mar/Apr 2004!
		like($book->{'title'},      qr!Perl Medic!  ,'.. title found');
		like($book->{'author'},     qr!Peter.*Scott!,'.. author found');
		like($book->{'image_link'}, qr!http://www.amazon.co.uk/gp/product/images!);
		like($book->{'thumb_link'}, qr!http://[-\w]+.images-amazon.com/images/[-\w/.]+\.jpg!);
		like($book->{'book_link'},  qr!^http://www.amazon.co.uk/(Perl-Medic|.*?field-keywords=(0201795264|9780201795264))!);
		is($book->{'binding'},      'Paperback'     ,'.. binding found');
		is($book->{'pages'},        336             ,'.. pages found');
		is($book->{'width'},        175             ,'.. width found');
		is($book->{'height'},       229             ,'.. height found');
		is($book->{'weight'},       undef           ,'.. weight found');

        #use Data::Dumper;
        #diag("book=[".Dumper($book)."]");
	}

    # search with an ISBN 13 value

	$isbn = "9780672320675";
	$record = $scraper->search($isbn);

    unless($record->found) {
		diag($record->error);
    } else {
		is($record->found,1);
		is($record->found_in,'AmazonUK');

		my $book = $record->book;
		is($book->{'isbn'},         '0672320673'    ,'.. isbn found');
		is($book->{'isbn10'},       '0672320673'    ,'.. isbn10 found');
		is($book->{'isbn13'},       '9780672320675' ,'.. isbn13 found');
		is($book->{'ean13'},        '9780672320675' ,'.. ean13 found');
		is($book->{'author'},       'Clinton Pierce','.. author found');
		like($book->{'publisher'},  qr/^Sams/       ,'.. publisher found'); # publisher name changes!
		like($book->{'pubdate'},    qr/2001$/       ,'.. pudate found');    # this dates fluctuates throughout Jul 2001!
		like($book->{'title'},      qr!Perl Developer.*?Dictionary! ,'.. title found');
		like($book->{'image_link'}, qr!http://www.amazon.co.uk/gp/product/images!);
		like($book->{'thumb_link'}, qr!http://[-\w]+.images-amazon.com/images/[-\w/.]+\.jpg!);
		like($book->{'book_link'},  qr!^http://www.amazon.co.uk/(Perl-Developers-Dictionary|.*?field-keywords=(0672320673|9780672320675))!);
		is($book->{'binding'},      'Paperback'     ,'.. binding found');
		is($book->{'pages'},        640             ,'.. pages found');
		is($book->{'width'},        188             ,'.. width found');
		is($book->{'height'},       231             ,'.. height found');
		is($book->{'weight'},       undef           ,'.. weight found');

        #use Data::Dumper;
        #diag("book=[".Dumper($book)."]");
    }
}

###########################################################

# crude, but it'll hopefully do ;)
sub pingtest {
  system("ping -q -c 1 www.google.com >/dev/null 2>&1");
  my $retcode = $? >> 8;
  # ping returns 1 if unable to connect
  return $retcode;
}
