#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 45;
use WWW::Scraper::ISBN;

###########################################################

my $DRIVER          = 'AmazonUK';
my $CHECK_DOMAIN    = 'www.google.com';

my %tests = (
    '0201795264' => [
        [ 'is',     'isbn',         '9780201795264' ],
        [ 'is',     'isbn10',       '0201795264'    ],
        [ 'is',     'isbn13',       '9780201795264' ],
        [ 'is',     'ean13',        '9780201795264' ],
        [ 'like',   'title',        qr!Perl Medic!  ],
        [ 'like',   'author',       qr!Peter.*Scott!],
        [ 'is',     'publisher',    'Addison Wesley'],
        [ 'like',   'pubdate',      qr/2004$/       ],  # this date fluctuates throughout Mar/Apr 2004!
        [ 'is',     'binding',      'Paperback'     ],
        [ 'is',     'pages',        336             ],
        [ 'is',     'width',        175             ],
        [ 'is',     'height',       229             ],
        [ 'is',     'weight',       undef           ],
        [ 'like',   'image_link',   qr!http://www.amazon.co.uk/gp/product/images!               ],
        [ 'like',   'thumb_link',   qr!http://[-\w]+.images-amazon.com/images/[-\w/.]+\.jpg!    ],
        [ 'like',   'description',  qr|This book is about taking over Perl code| ],
        [ 'like',   'book_link',    qr!^http://www.amazon.co.uk/(Perl-Medic|.*?field-keywords=(0201795264|9780201795264))! ]
    ],
    '9780672320675' => [
        [ 'is',     'isbn',         '9780672320675'             ],
        [ 'is',     'isbn10',       '0672320673'                ],
        [ 'is',     'isbn13',       '9780672320675'             ],
        [ 'is',     'ean13',        '9780672320675'             ],
        [ 'is',     'author',       'Clinton Pierce'            ],
        [ 'like',   'title',        qr!Perl Developer.*?Dictionary! ],
        [ 'like',   'publisher',    qr/^Sams/                   ],  # publisher name changes!
        [ 'like',   'pubdate',      qr/2001$/                   ],  # this dates fluctuates throughout Jul 2001!
        [ 'is',     'binding',      'Paperback'                 ],
        [ 'is',     'pages',        640                         ],
        [ 'is',     'width',        188                         ],
        [ 'is',     'height',       231                         ],
        [ 'is',     'weight',       undef                       ],
        [ 'like',   'image_link',   qr!http://www.amazon.co.uk/gp/product/images!               ],
        [ 'like',   'thumb_link',   qr!http://[-\w]+.images-amazon.com/images/[-\w/.]+\.jpg!    ],
        [ 'like',   'description',  qr|Perl Developer's Dictionary is a complete|                            ],
        [ 'like',   'book_link',    qr!^http://www.amazon.co.uk/(Perl-Developers-Dictionary|.*?field-keywords=(0672320673|9780672320675))! ]
    ],

    '9781408307557' => [
        [ 'is',     'pages',        48                          ],
        [ 'is',     'width',        130                         ],
        [ 'is',     'height',       200                         ],
        [ 'is',     'weight',       undef                       ],
    ],
);

my $tests = 0;
for my $isbn (keys %tests) { $tests += scalar( @{ $tests{$isbn} } ) + 2 }


###########################################################

my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

SKIP: {
	skip "Can't see a network connection", $tests+1   if(pingtest($CHECK_DOMAIN));

	$scraper->drivers($DRIVER);

    for my $isbn (keys %tests) {
        my $record = $scraper->search($isbn);
        my $error  = $record->error || '';

        SKIP: {
            skip "Website unavailable", scalar(@{ $tests{$isbn} }) + 2   
                if($error =~ /website appears to be unavailable/);

            unless($record->found) {
                diag($record->error);
            }

            is($record->found,1);
            is($record->found_in,$DRIVER);

            my $book = $record->book;
            for my $test (@{ $tests{$isbn} }) {
                if($test->[0] eq 'ok')          { ok(       $book->{$test->[1]},             ".. '$test->[1]' found [$isbn]"); } 
                elsif($test->[0] eq 'is')       { is(       $book->{$test->[1]}, $test->[2], ".. '$test->[1]' found [$isbn]"); } 
                elsif($test->[0] eq 'isnt')     { isnt(     $book->{$test->[1]}, $test->[2], ".. '$test->[1]' found [$isbn]"); } 
                elsif($test->[0] eq 'like')     { like(     $book->{$test->[1]}, $test->[2], ".. '$test->[1]' found [$isbn]"); } 
                elsif($test->[0] eq 'unlike')   { unlike(   $book->{$test->[1]}, $test->[2], ".. '$test->[1]' found [$isbn]"); }

            }

            #use Data::Dumper;
            #diag("book=[".Dumper($book)."]");
        }
    }
}

###########################################################

# crude, but it'll hopefully do ;)
sub pingtest {
    my $domain = shift or return 0;
    my $cmd =   $^O =~ /solaris/i                           ? "ping -s $domain 56 1" :
                $^O =~ /dos|os2|mswin32|netware|cygwin/i    ? "ping -n 1 $domain "
                                                            : "ping -c 1 $domain >/dev/null 2>&1";

    system($cmd);
    my $retcode = $? >> 8;
    # ping returns 1 if unable to connect
    return $retcode;
}
