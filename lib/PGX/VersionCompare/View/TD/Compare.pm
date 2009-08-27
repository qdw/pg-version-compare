package PGX::VersionCompare::View::TD::Compare;

use strict;
use warnings;
use feature ':5.10';

use Template::Declare::Tags;

=head1 Name

PGX::VersionCompare::View::TD::Compare - templates for the pages that let you
compare (changes across) PostgreSQL versions

=head1 Description

This module contains the Template::Declare templates used by
PGX::VersionCompare, specifically for the business logic of comparison.

=head1 Templates

=head2 compare

=cut

template 'compare/versions' => sub {
    my ($self, $c) = @_;
#     wrap {
#         h1 { 'Compare template' };
#     } $c;
    wrap { 'woot!' };
};

1;

=head1 Authors

=over

=item * Josh Berkus <josh.berkus@pgexperts.com>

=item * David E. Wheeler <david.wheeler@pgexperts.com>

=item * Quinn Weaver <quinn.weaver@pgexperts.com>

=back

=head1 Copyright

Copyright (c) 2009 PostgreSQL Experts, Inc. All Rights Reserved.

=cut
