#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';
use utf8;

use Carp;

use Test::More tests => 68;
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

# Test /compare (no params)
{
    my $tx = test_sanity('http://localhost:3000/compare', 'Compare');

    my $form = q(//form[@id='query']);
    $tx->is("count($form)", 1, q(only 1 form with id 'query'));
    $tx->is("$form/p[1]", 'Fixes from', q('Fixes from' paragraph));
    $tx->is("$form/p[2]", 'to',         q('to' paragraph));
    $tx->is("count($form/select)", 4, '4 select boxes:');
    $tx->is("$form/select[1]/\@name", 'major_1', '1st has id major_1');
    $tx->is("$form/select[2]/\@name", 'minor_1', '2nd has id minor_1');
    $tx->is("$form/select[3]/\@name", 'major_2', '3rd has id major_2');
    $tx->is("$form/select[4]/\@name", 'minor_2', '4th has id minor_2');
    $tx->ok("$form/select/option", 'select boxes are populated with options');
    $tx->is(
        "count($form/span[\@class='dot'])",
        2,
        '2 spans for the dots between version numbers'
    );

    my $q = $form . q{/div[@id='q']};
    $tx->is("count($q)", 1, 'form has 1 div with id q (for the search expr)');
    $tx->is("$q/p", 'matching', q('matching' paragraph));

    my $textbox = "$q/input[\@type='text']";
    $tx->is("count($textbox)", 1, '1 textbox (for the search expr)');
    $tx->ok($textbox . q{[@name='q']}, q(textbox has name="q"));

    my $submit = "$form/button[\@type='submit']";
    $tx->is("count($submit)", 1, '1 submit button');
    $tx->is($submit, 'Show', q(submit button is named 'Show'));
}
