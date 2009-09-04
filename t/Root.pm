#!/usr/bin/env perl

package Test::PGX::VersionCompare::Controller::Root;

use warnings;
use strict;

use Catalyst::Test 'PGX::VersionCompare';
use Data::Dumper;
use Test::Exception;

use Test::More tests => 1;

################################################################################
# Test the index action (URI /index)
{
    my ($res, $c) = ctx_request('/');
    is($c->stash->{title}, 'Welcome', 'title set properly');
}

1;
