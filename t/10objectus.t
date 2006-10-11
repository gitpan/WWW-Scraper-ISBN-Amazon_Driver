#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 21;

###########################################################

	use WWW::Scraper::ISBN;
	my $scraper = WWW::Scraper::ISBN->new();
	isa_ok($scraper,'WWW::Scraper::ISBN');

	$scraper->drivers("AmazonUS");
	my $isbn = "0201795264";
	my $record = $scraper->search($isbn);

	SKIP: {
		skip($record->error . "\n",10)	unless($record->found);

		is($record->found,1);
		is($record->found_in,'AmazonUS');

		my $book = $record->book;
		is($book->{'isbn'},'0201795264');
		like($book->{'title'},qr!Transforming Legacy Code!);
		is($book->{'author'},'Peter J. Scott');
		like($book->{'image_link'},qr!^http://www.amazon.com/gp/product/images!);
		like($book->{'thumb_link'},qr!amazon.com/images/P/\d+\.\d+\.\w+\.jpg!);
		is($book->{'publisher'},'Addison-Wesley Professional');
		is($book->{'pubdate'},'March 5, 2004');
		like($book->{'book_link'},qr!^http://www.amazon.com/Perl-Medic-Transforming-Legacy-Code/!);
	}

	$isbn = "0672320673";
	$record = $scraper->search($isbn);

	SKIP: {
		skip($record->error . "\n",10)	unless($record->found);

		is($record->found(),1);
		is($record->found_in(),'AmazonUS');

		my $book = $record->book;
		is($book->{'isbn'},'0672320673');
		like($book->{'title'},qr!Perl Developer\'s Dictionary!);
		is($book->{'author'},'Clinton Pierce');
		like($book->{'image_link'},qr!^http://www.amazon.com/gp/product/images!);
		like($book->{'thumb_link'},qr!amazon.com/images/P/\d+\.\d+\.\w+\.jpg!);
		is($book->{'publisher'},'Sams');
		is($book->{'pubdate'},'July 18, 2001');
		like($book->{'book_link'},qr!^http://www.amazon.com/Perl-Developers-Dictionary!);
	}

###########################################################

