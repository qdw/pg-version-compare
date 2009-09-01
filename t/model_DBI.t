#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';
use utf8;

use Test::More tests => 13;
#use Test::More 'no_plan';

BEGIN {
    use_ok 'PGX::VersionCompare';
    use_ok 'PGX::VersionCompare::Model::DBI';
}

ok my $dbi = PGX::VersionCompare->model('DBI'), 'Get model';
isa_ok $dbi, 'PGX::VersionCompare::Model::DBI';
isa_ok $dbi, 'Catalyst::Model::DBI';

# Make sure we can connect.
ok $dbi->connect, 'Connect';
isa_ok my $dbh = $dbi->dbh, 'DBI::db', 'Should be able to get a dbh';

# What are we connected to, and how?
is $dbh->{Username}, 'postgres', 'Should be connected as "postgres"';
is $dbh->{Name}, 'dbname=version_compare_test',
    'Should be connected to "version_compare_test"';
ok !$dbh->{PrintError}, 'PrintError should be disabled';
ok !$dbh->{RaiseError}, 'RaiseError should be disabled';
ok $dbh->{AutoCommit}, 'AutoCommit should be enabled';
isa_ok $dbh->{HandleError}, 'CODE', 'There should be an error handler';
