#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';
use utf8;

use Carp;

use Test::More tests => 181;
#use Test::More 'no_plan';
use Test::More::UTF8;
use Test::XML;
use Test::XPath;

BEGIN {
    use_ok 'PGX::VersionCompare';
    use_ok 'Catalyst::Test' => 'PGX::VersionCompare';
}

# Call this function for every request to make sure that they all
# have the same basic structure.
sub test_basic_content {
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
        'Title should be correct'
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

    return $tx;
}

sub test_sanity {
    my ($uri, $expected_title) = @_;
    ok my $res = request($uri), "************* Request $uri";
    ok $res->is_success, 'Request should have succeeded';
    is_well_formed_xml $res->content, 'The HTML should be well-formed';
    my $tx = Test::XPath->new( xml => $res->content, is_html => 1 );
    test_basic_content($tx, $expected_title);
    return $tx;
}

# Test the home page.
{
    my $tx = test_sanity('http://localhost:3000/', 'Welcome');
}

sub test_basics_of_compare {
    my ($tx) = @_;

    # Hmn, can't do //form[@id="query" AND @action="/handle_form]
    # --guess this module's XPath support is incomplete?
    $tx->ok('//form[@action="/handle_form"]', 'form action is /handle_form');
    $tx->ok('//form[@id="query"]', sub {

        $_->is('count(.)',    1,   q(only 1 form with id 'query')  );
        $_->is('count(./*)',  10,  'form has 10 sub-elements'      );

        $_->is('./p[1]', 'Fixes from', q('Fixes from' paragraph));
        $_->is('./p[2]', 'to',         q('to' paragraph));

        $_->is('count(./select)', 4, '4 select boxes:');
        $_->is('./select[1]/@name', 'major_1', 'box 1 has name major_1');
        $_->is('./select[2]/@name', 'minor_1', 'box 2 has name minor_1');
        $_->is('./select[3]/@name', 'major_2', 'box 3 has name major_2');
        $_->is('./select[4]/@name', 'minor_2', 'box 4 has name minor_2');
        for my $i (1 .. 4) {
            $_->ok("./select[$i]/option", "box $i is populated with option(s)");
        }

        $_->is(
            'count(./span[@class="dot"])',
            2,
            '2 spans (somewhere) for the dots between version numbers'
        );

        $_->ok('./div[@id="q"]', sub {
            $_->is('./p', 'matching', q('matching' paragraph));
            $_->ok('./input[@type="text"]', 'textbox');
            $_->ok('./input[@name="q"]',
                q[input with name 'q' (for the search expression)]
            );
        }, q[form contains div with id 'q' (for the search expression, etc.)]);

        $_->is('./button[@type="submit"]', 'Show', 'submit button reads Show');

    }, 'form');
}

# Test the compare page (with no params passed)
{
    my $tx = test_sanity('http://localhost:3000/compare', 'Compare');
    test_basics_of_compare($tx);
}

# Test the compare page (via parameters in a URI)
{
    my $tx = test_sanity(
        'http://localhost:3000/compare/8.0.0/8.0.3/?q=Avoid',
        'Compare'
    );
    test_basics_of_compare($tx);
    $tx->ok( '//div[@id="result"]', sub {
        $_->ok('./div[@id="fixes"]', sub {
            $_->ok('./table[@class="fixes"]', sub {
                $_->is('./tr[1]/th[1]', 'Fix', 'th 1: Fix');
                $_->is('./tr[1]/th[2]', 'Introduced in', 'th 2: Introduced in');
                $_->is('count(.//td)', 8, '8 tds (== 4 rows)');

                $_->is(
                    './tr[2]/td[1]',
                    'Avoid SHGetSpecialFolderPath() on Windows',
                    q(row 1: 'Fix' content is ok)
                );
                $_->is(
                    './tr[2]/td[2]',
                    '8.0.1',
                    q(row 1: 'Introduced in' content is ok)
                );

                $_->is(
                    './tr[3]/td[1]',
                    'Avoid buffer overrun when plpgsql cursor declaration has too', #FIXME:  Looks truncated.  This is how it appears in the database, but is it right--that is, is it really what appeared in the CHANGELOG?
                    q(row 2: 'Fix' content is ok)
                );
                $_->is(
                    './tr[3]/td[2]',
                    '8.0.1',
                    q(row 2: 'Introduced in' content is ok)
                );

                $_->is(
                    './tr[4]/td[1]',
                    'New cache management algorithm 2Q replaces ARC (Tom) This was done to avoid a pending US patent on ARC . The 2Q code might be a few percentage points slower than ARC for some work loads. A better cache management algorithm will appear in 8.1.',
                    q(row 3: 'Fix' content is ok)
                );
                $_->is(
                    './tr[4]/td[2]',
                    '8.0.2',
                    q(row 3: 'Introduced in' content is ok)
                );

                $_->is(
                    './tr[5]/td[1]',
                    'Change contrib/tsearch2 to avoid unsafe use of', #FIXME:  Looks truncated (looks the same in the database)
                    q(row 4: 'Fix' content is ok)
                );
                $_->is(
                    './tr[5]/td[2]',
                    '8.0.3',
                    q(row 4: 'Introduced in' content is ok)
                );
            }, 'fixes table:');
        }, 'found "fixes" div:');
    }, '************* Finished basic compare test; found "result" div');

    TODO: {
        local $TODO = 'need to write tests that test form field stickiness';
        ok(0, 'form fields are sticky');
    }
}

# Test the compare page's behavior when only one version number is passed
# (should yield an error message)
{
    my $tx = test_sanity(
        'http://localhost:3000/compare/8.0.0',
        'Compare'
    );
    test_basics_of_compare($tx);
    $tx->is(
        '//p[@class="error"]',
        'In order to compare versions, you must provide two version numbers.  You provided only one.',
        'pass only one version, get the expected error message'
    );
}

# ok(0, 'need to write view and controller tests for the two-param (no search) case');
