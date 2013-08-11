#!/usr/bin/perl

use strict;
use warnings;
use 5.006;

use ExtUtils::MakeMaker;

WriteMakefile(
    AUTHOR              => 'Barbie <barbie@cpan.org>',
    NAME                => 'WWW::Scraper::ISBN::Amazon_Driver',
    VERSION_FROM        => 'lib/WWW/Scraper/ISBN/AmazonUS_Driver.pm',
    ABSTRACT            => 'Search drivers for the Amazon online catalog',
    NO_META             => 1,
    PREREQ_PM           => {

        # prereqs
        'JSON'                          => '0',
        'WWW::Scraper::ISBN'            => '0.25',
        'WWW::Scraper::ISBN::Driver'    => '0.18',
        'WWW::Mechanize'                => '1.60',

        # build/test prereqs
        'Test::More'                    => '0.70',
        'IO::File'                      => '0'

    }
);
