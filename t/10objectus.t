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

	print STDERR $record->error . "\n"	unless($record->found);

	is($record->found,1);
	is($record->found_in,'AmazonUS');

	my $book = $record->book;
	is($book->{'isbn'},'0201795264');
	is($book->{'title'},'Perl Medic: Transforming Legacy Code');
	is($book->{'author'},'Peter Scott');
	is($book->{'image_link'},'http://images.amazon.com/images/P/0201795264.01.LZZZZZZZ.jpg');
	is($book->{'thumb_link'},'http://images.amazon.com/images/P/0201795264.01._PE30_PI_SCMZZZZZZZ_.jpg');
	is($book->{'publisher'},'Addison-Wesley Professional');
	is($book->{'pubdate'},'March 1, 2004');
	like($book->{'book_link'},qr!^http://www.amazon.com/exec/obidos/ASIN/!);

	$isbn = "0672320673";
	$record = $scraper->search($isbn);

	print STDERR $record->error . "\n"	unless($record->found);

	is($record->found,1);
	is($record->found_in,'AmazonUS');

	$book = $record->book;
	is($book->{'isbn'},'0672320673');
	is($book->{'title'},q|Perl Developer's Dictionary|);
	is($book->{'author'},'Clinton Pierce');
	is($book->{'image_link'},'http://images.amazon.com/images/P/0672320673.01.LZZZZZZZ.jpg');
	is($book->{'thumb_link'},'http://images.amazon.com/images/P/0672320673.01._PE7_PI_SCMZZZZZZZ_.jpg');
	is($book->{'publisher'},'Sams');
	is($book->{'pubdate'},'July 18, 2001');
	like($book->{'book_link'},qr!^http://www.amazon.com/exec/obidos/ASIN/!);

###########################################################

