#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';
use utf8;

use Test::More tests => 11;
#use Test::More 'no_plan';

BEGIN {
    use_ok 'PGX::VersionCompare';
}

ok my $conn = PGX::VersionCompare->new->conn, 'Get connection';
isa_ok $conn, 'DBIx::Connector';
ok my $dbh = $conn->dbh, 'Make sure we can connect';
isa_ok $dbh, 'DBI::db', 'The handle';

# What are we connected to, and how?
is $dbh->{Username}, 'postgres', 'Should be connected as "postgres"';
is $dbh->{Name}, 'dbname=version_compare_test',
    'Should be connected to "version_compare_test"';
ok !$dbh->{PrintError}, 'PrintError should be disabled';
ok !$dbh->{RaiseError}, 'RaiseError should be disabled';
ok $dbh->{AutoCommit}, 'AutoCommit should be enabled';
isa_ok $dbh->{HandleError}, 'CODE', 'There should be an error handler';
