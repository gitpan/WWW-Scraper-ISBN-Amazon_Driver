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

	print STDERR $record->error . "\n"	unless($record->found);

	is($record->found,1);
	is($record->found_in,'AmazonUK');

	my $book = $record->book;
	is($book->{'isbn'},'0201795264');
	is($book->{'title'},'Perl Medic: Maintaining Inherited Code');
	is($book->{'author'},'Peter Scott');
	is($book->{'image_link'},'http://images-eu.amazon.com/images/P/0201795264.02.LZZZZZZZ.jpg');
	is($book->{'thumb_link'},'http://images-eu.amazon.com/images/P/0201795264.02._PE30_SCMZZZZZZZ_.jpg');
	is($book->{'publisher'},'Addison Wesley');
	is($book->{'pubdate'},'April 2004');
	like($book->{'book_link'},qr!^http://www.amazon.co.uk/exec/obidos/ASIN/!);

	$isbn = "0672320673";
	$record = $scraper->search($isbn);

	print STDERR $record->error . "\n"	unless($record->found);

	is($record->found,1);
	is($record->found_in,'AmazonUK');

	$book = $record->book;
	is($book->{'isbn'},'0672320673');
	is($book->{'title'},q|Perl Developer's Dictionary|);
	is($book->{'author'},'Clinton Pierce');
	is($book->{'image_link'},'http://images-eu.amazon.com/images/P/0672320673.02.LZZZZZZZ.jpg');
	is($book->{'thumb_link'},'http://images-eu.amazon.com/images/P/0672320673.02.MZZZZZZZ.jpg');
	is($book->{'publisher'},'Sams');
	is($book->{'pubdate'},'July 1, 2001');
	like($book->{'book_link'},qr!^http://www.amazon.co.uk/exec/obidos/ASIN/!);

###########################################################

