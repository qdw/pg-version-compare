#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Catalyst::Test 'PGX::VersionCompare';
use Data::Dumper;
use Test::Exception;
use Test::More tests => 27;

sub stash_var_ok {
    my ($c, $stash_var_name, $expected_type, $expected_value) = @_;

    # Fake things up so that we can have a SCALAR pseudo-type as $expected_type.
    if ($expected_type eq 'SCALAR') {
        ok(
            !ref $c->stash->{$stash_var_name},
            "stash var '$stash_var_name' isa SCALAR"
        );
    }
    # Handle all other $expected_types using isa_ok.
    else {
        isa_ok(
            $c->stash->{$stash_var_name},
            $expected_type,
            qq(stash var '$stash_var_name')
        );
    }

    if (defined $expected_value) {
        is_deeply(
            $c->stash->{$stash_var_name},
            $expected_value,
            "stash var '$stash_var_name' has expected value"
        );
    }
}

################################################################################
# Test the index page
#     URI /
#     action PGX::VersionCompare::Controller::Root->index
{
    my $uri = '/';
    diag "testing $uri" if 0;
    my ($res, $c) = ctx_request($uri);
    is($c->stash->{title}, 'Welcome', 'title set properly');
}

################################################################################
# Test the compare page, via parameters in a URI
#     URI /compare/8.0.0/8.0.3/?q=Avoid
#     action PGX::VersionCompare::Controller::Compare->compare
{
    my $uri = '/compare/8.0.0/8.0.3/?q=Avoid';
    diag "testing $uri" if 0;
    my ($res, $c) = ctx_request($uri);

    my $expected = {
        '8.3' => [
            0,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
        ],
        '8.2' => [
            0,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
        ],
        '8.0' => [
            0,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            15,
            16,
            17,
            18,
            19,
            20,
            21,
            22,
        ],
        '8.1' => [
            0,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            15,
            16,
            17,
            18,
        ],
        '8.4' => [
            0,
            1,
        ],
        '8.5' => [
            0
        ]
    };

    my $SCALAR = '';

    diag(Data::Dumper->Dump(
        [$c->stash],
        ['stash']))
      if 0;

    diag(Data::Dumper->Dump(
        [$c->{known_versions_ref}],
        ['known_versions_ref']))
      if 0;
    stash_var_ok($c, 'known_versions_ref',   'HASH',   $expected);
    stash_var_ok($c, 'q',                    'SCALAR', 'Avoid');
    stash_var_ok($c, 'major_1',              'SCALAR', '8.0');
    stash_var_ok($c, 'major_2',              'SCALAR', '8.0');
    stash_var_ok($c, 'minor_1',              'SCALAR', 0);
    stash_var_ok($c, 'minor_2',              'SCALAR', 3);
    stash_var_ok($c, 'fixes_sth',            'DBI::st');
    stash_var_ok($c, 'upgrade_warnings_sth', 'DBI::st');

    stash_var_ok($c, 'template',           'SCALAR', 'compare_result');
}

################################################################################
# Test the compare page's behavior when no parameters are passed
#     URI /compare
#     action PGX::VersionCompare::Controller::Compare->compare
{
    my $uri = '/compare';
    diag "testing $uri" if 0;
    my ($res, $c) = ctx_request($uri);

    is(
        $c->stash->{template},
        'compare',
        q(no input, so template is just 'compare', not 'compare_result')
    );

     map { ok(!exists $c->stash->{$_}, "no $_ in stash") }
         qw( major_1 major_2 minor_1 minor_2 q fixes_sth);
}

################################################################################
# Test the compare page's behavior when only one version number is passed
# (should yield an error message)
#     URI /compare/8.0.0
#     action PGX::VersionCompare::Controller::Compare->compare
{
    my $uri = '/compare/8.0.0';
    diag "testing $uri" if 0;
    my ($res, $c) = ctx_request($uri);

    is(
        $c->stash->{template},
        'compare',
        q(no input, so template is just 'compare', not 'compare_result')
    );

    stash_var_ok($c, 'error', 'SCALAR', 'In order to compare versions, you must provide two version numbers.  You provided only one.');
}
