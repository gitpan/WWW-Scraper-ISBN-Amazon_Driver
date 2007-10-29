#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 21;

###########################################################

	use WWW::Scraper::ISBN;
	my $scraper = WWW::Scraper::ISBN->new();
	isa_ok($scraper,'WWW::Scraper::ISBN');

	$scraper->drivers("AmazonUK");
	my $isbn = "0201795264";
	my $record = $scraper->search($isbn);

	SKIP: {
		skip($record->error . "\n",10)	unless($record->found);

		is($record->found,1);
		is($record->found_in,'AmazonUK');

		my $book = $record->book;
		is($book->{'isbn'},         '0201795264');
		is($book->{'publisher'},    'Addison Wesley');
		like($book->{'pubdate'},    qr/2004$/);     # this date fluctuates throughout Mar/Apr 2004!
		like($book->{'title'},      qr!Perl Medic!);
		like($book->{'author'},     qr!Peter.*Scott!);
		like($book->{'image_link'}, qr!http://www.amazon.co.uk/gp/product/images!);
		like($book->{'thumb_link'}, qr!http://[-\w]+.images-amazon.com/images/[-\w/.]+\.jpg!);
		like($book->{'book_link'},  qr!^http://www.amazon.co.uk/(Perl-Medic|s/ref=nb_ss_w_h_/.*?field-keywords=0201795264)!);
	}

	$isbn = "0672320673";
	$record = $scraper->search($isbn);

	SKIP: {
		skip($record->error . "\n",10)	unless($record->found);

		is($record->found,1);
		is($record->found_in,'AmazonUK');

		my $book = $record->book;
		is($book->{'isbn'},         '0672320673');
		is($book->{'author'},       'Clinton Pierce');
		like($book->{'publisher'},  qr/^Sams/);     # publisher name changes!
		like($book->{'pubdate'},    qr/2001$/);     # this dates fluctuates throughout Jul 2001!
		like($book->{'title'},      qr!Perl Developer\'s Dictionary!);
		like($book->{'image_link'}, qr!http://www.amazon.co.uk/gp/product/images!);
		like($book->{'thumb_link'}, qr!http://[-\w]+.images-amazon.com/images/[-\w/.]+\.jpg!);
		like($book->{'book_link'},  qr!^http://www.amazon.co.uk/(Perl-Developers-Dictionary|s/ref=nb_ss_w_h_/.*?field-keywords=0672320673)!);
	}

###########################################################
