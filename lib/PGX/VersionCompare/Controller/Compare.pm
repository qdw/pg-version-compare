package PGX::VersionCompare::Controller::Compare;

use strict;
use warnings;
use feature ':5.10';

use parent 'Catalyst::Controller';

=head1 Name

PGX::VersionCompare::Controller::Compare - for comparing PostgreSQL versions

=head1 Description

Catalyst controller for comparing PostgreSQL versions.

=cut

# Sets the actions in this controller to be registered with no prefix so they
# function identically to actions created in PGX::VersionCompare.
__PACKAGE__->config->{namespace} = '';

=head1 Methods

=head2 version

Controller to compare two PostgreSQL versions (that is, find the changes
between them).  Only a stub so far.

=cut

# :Regex:  match one version compose of S.M.m (Super.Major.minor) digits,
# followed by a slash, followed by another version of the same format.
#
# Match versions liberally.  So far, major versions (e.g. 8.1, 8.4)
# have always had one digit before the decimal place and one digit after.
# However, let's assume a future version might have more than one digit
# in either place (e.g. 10.1 or 8.11).
#
# In any case, if someone enters an invalid version number, the database
# will catch it.
#
#:Regex('^(\d+)[.](\d+)[.](\d+)/(\d+)[.](\d+)[.](\d+)') {
# e.g.      8   .   1   .  10  /  8   .   4   .   1       (minus spaces)
sub version :Path('/compare') {
    my ( $self, $c, $v1, $v2 ) = @_;
    my $dbh = $c->model('DBI')->dbh;
    $c->stash(
        title => 'pg-version-compare: Track Changes between PostgreSQL Versions'
    );

    $c->stash(v1 => $v1);
    $c->stash(v2 => $v2);
}

1;

__END__

=head1 Authors

=over

=item * Josh Berkus <josh.berkus@pgexperts.com>

=item * David E. Wheeler <david.wheeler@pgexperts.com>

=item * Quinn Weaver <quinn.weaver@pgexperts.com>

=back

=head1 Copyright

Copyright (c) 2009 PostgreSQL Experts, Inc. All Rights Reserved.

=cut
