#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';
use utf8;

use Test::More tests => 52;
#use Test::More 'no_plan';
use Test::More::UTF8;
use Test::XML;
use Test::XPath;

BEGIN {
    use_ok 'PGX::VersionCompare';
    use_ok 'Catalyst::Test' => 'PGX::VersionCompare';
}

# Test the home page.
ok my $res = request('http://localhost:3000/'), 'Request home page';
ok $res->is_success, 'Request should have succeeded';
is_well_formed_xml $res->content, 'The HTML should be well-formed';
my $tx = Test::XPath->new( xml => $res->content, is_html => 1 );
test_basics($tx, 'Welcome');

# Test /compare
ok $res = request('http://localhost:3000/compare'), 'Request compare page';
ok $res->is_success, 'Request should have succeeded';
is_well_formed_xml $res->content, 'The HTML should be well-formed';
$tx = Test::XPath->new( xml => $res->content, is_html => 1 );
test_basics($tx, 'Compare');

# Call this function for every request to make sure that they all
# have the same basic structure.
sub test_basics {
    my ($tx, $title) = @_;

    # Some basic sanity-checking.
    $tx->is( 'count(/html)',      1, 'Should have 1 html element' );
    $tx->is( 'count(/html/head)', 1, 'Should have 1 head element' );
    $tx->is( 'count(/html/body)', 1, 'Should have 1 body element' );

    # Check the head element.
    $tx->is(
        '/html/head/meta[@http-equiv="Content-Type"]/@content',
        'text/html; charset=UTF-8',
        'Should have the content-type set in a meta header',
    );

    $tx->is(
        '/html/head/title',
        "PostgreSQL Experts’ PGVersionCompare (TEST): $title",
        'Title should be corect'
    );
    $tx->is(
        '/html/head/link[@type="text/css"][@rel="stylesheet"]/@href',
        '/ui/css/screen.css',
        'Should load the CSS',
    );

    # Test the body.
    $tx->is('count(/html/body/*)', 2, 'Should have two elements below body' );

    # Test the header section (logo, etc.).
    $tx->ok( '/html/body/div[@id="ccn"]', sub {
        shift->ok('./div[@id="con"]', sub {
            $_->is('count(./*)', 2, 'Should have 2 elements below "con"');

            # Check the logo.
            $_->is(
                './img[@id="lgo"]/@src',
                '/ui/img/logo.png',
                'Should have logo'
            );
            $_->is(
                './img[@id="lgo"]/@alt',
                'PostgreSQL Experts, Inc.',
                'It should have an alt attribute'
            );

            # Check the content.
            $_->ok('./div[@id="cnt"]', 'Should have "cnt" div below "con"');

        }, 'Should have "con" div below "ccn"' );
    }, 'Should have "ccn" div');


    # Check the footer section.
    $tx->ok('/html/body/div[@id="ft"]', sub {
        $_->is('count(./*)', 1, 'It should have one sub-element' );
        $_->ok('./div[@id="ftr"]', sub {
            $_->is('count(./*)', 5, 'It should have five sub-elements');
            $_->is(
                './span[1]',
                '© 2009 PostgreSQL Experts Inc.',
                'First should be copyright',
            );
            # XXX Update URL when it's finalized
            $_->is(
                './span[2]/a[@href="#"]',
                'Privacy Policy',
                'Second should be privacy',
            );
            # XXX Update URL when it's finalized
            $_->is(
                './span[3]/a[@href="#"]',
                'Terms of Use',
                'Third should be terms',
            );
            $_->is(
                './span[4]/a[@href="mailto:sales@pgexperts.com"]',
                'sales@pgexperts.com',
                'Fourth should be the sales address',
            );
            $_->is(
                './span[5]',
                '+1 888 PG-EXPRT (743-9778)',
                'Fifth should be phone',
            );
        }, 'That subelement should be div id "ftr"');
    }, 'Should have "ft" div');
}
