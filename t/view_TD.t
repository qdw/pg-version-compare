#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';
use utf8;

use Test::More tests => 5;
#use Test::More 'no_plan';
use Test::XML;
#use Test::XML::XPath;

BEGIN {
    use_ok 'PGX::VersionCompare';
    use_ok 'Catalyst::Test' => 'PGX::VersionCompare';
}

ok my $res = request('http://localhost:3000/'), 'Request home page';
ok $res->is_success, 'Request should have succeeded';

is_well_formed_xml $res->content, 'The HTML should be well-formed';

# Add a bunch more tests here to make sure that our HTML is what we expect it
# to be.
#is_xpath $res->content, '/html/head/title', 'whatever';
