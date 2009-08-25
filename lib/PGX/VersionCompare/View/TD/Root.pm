package PGX::VersionCompare::View::TD::Root;

use strict;
use warnings;
use Template::Declare::Tags;

template index => sub {
    my ($self, $c) = @_;
    html {
        head { title { $c->stash->{title} } };
        body {
            h1 { 'Welcome!' };
        };
    };
};

1;

=head1 Name

PGX::VersionCompare::View::TD::Root - Root TD templates

=head1 Description

This module contains the Template::Declare templates used by PGX::VersionCompare.

=head1 Authors

=over

=item * David E. Wheeler <david@pgexperts.com>

=back

=head1 Copyright

Copyright (c) 2009 PostgreSQL Experts, Inc. All Rights Reserved.

=cut

