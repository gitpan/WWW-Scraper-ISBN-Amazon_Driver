#!/usr/bin/perl -w
use strict;

#########################

use Test::More tests => 2;

eval "use WWW::Scraper::ISBN::AmazonUS_Driver";
is($@,'');
eval "use WWW::Scraper::ISBN::AmazonUK_Driver";
is($@,'');

#########################

