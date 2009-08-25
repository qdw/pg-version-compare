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

=head1 NAME

PGX::VersionCompare::Model::DBI - DBI Model Class

=head1 SYNOPSIS

See L<PGX::VersionCompare>

=head1 DESCRIPTION

DBI Model Class.

=head1 AUTHOR

David E. Wheeler

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
