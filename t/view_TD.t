#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';
use utf8;

#use Test::More tests => 6;
use Test::More 'no_plan';
use Test::More::UTF8;
use Test::XML;
use Test::XPath;

BEGIN {
    use_ok 'PGX::VersionCompare';
    use_ok 'Catalyst::Test' => 'PGX::VersionCompare';
}

ok my $res = request('http://localhost:3000/'), 'Request home page';
ok $res->is_success, 'Request should have succeeded';

is_well_formed_xml $res->content, 'The HTML should be well-formed';

my $tx = Test::XPath->new( xml => $res->content, is_html => 1 );
$tx->is(
    '/html/head/title',
    'PostgreSQL Experts’ PGVersionCompare (TEST): Welcome',
    'Title should be corect'
);
