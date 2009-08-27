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

=head2 compare

=cut


# :Regex:  match one version compose of S.M.m (Super.Major.minor) digits,
# followed by a slash, followed by another version of the same format.
#
# Match versions liberally; assume that future major versions of
# PostgreSQL may have more digits (both before and after the decimal place)
# than have been seen so far.  After all, if someone enters an invalid
# version number, the database will catch it.
sub versions :Regex('c') {
#:Regex('^(\d+)[.](\d+)[.](\d+)/(\d+)[.](\d+)[.](\d+)') {
    my ( $self, $c ) = @_;
    my $dbh = $c->model('DBI')->dbh;
    $c->stash(
        title => 'pg-version-compare: Track Changes between PostgreSQL Versions'
    );

    #my ($major_1, $minor_1) = qw(8.1 1)

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
