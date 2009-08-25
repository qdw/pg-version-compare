package PGX::VersionCompare::Model::DBI;

use strict;
use parent 'Catalyst::Model::DBI';
use Exception::Class::DBI;

__PACKAGE__->config(
    options       => {
        PrintError  => 0,
        RaiseError  => 0,
        HandleError => Exception::Class::DBI->handler,
        AutoCommit  => 1,
    },
);

1;

=head1 Name

PGX::VersionCompare::Model::DBI - DBI Model Class

=head1 Synopsis

See L<PGX::VersionCompare>

=head1 Description

DBI Model Class.

=head1 Authors

=over

=item * Josh Berkus <josh.berkus@pgexperts.com>

=item * David E. Wheeler <david.wheeler@pgexperts.com>

=item * Quinn Weaver <quinn.weaver@pgexperts.com>

=back

=head1 Copyright

Copyright (c) 2009 PostgreSQL Experts, Inc. All Rights Reserved.

=cut
