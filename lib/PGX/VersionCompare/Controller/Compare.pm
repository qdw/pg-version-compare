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

sub version :Path('/compare') {
    my ( $self, $c, $v1, $v2 ) = @_;
    my $search_term = $c->request->param('search_for_substring'); # may be undef
    my $dbh = $c->model('DBI')->dbh;
    $c->stash(v1 => $v1);
    $c->stash(v2 => $v2);
    $c->stash(search_for_substring => $search_term);

    $c->stash(
        title => 'pg-version-compare: Track Changes between PostgreSQL Versions'
    );

    if (!defined $v1 && !defined $v2) {
        # No input given.  That means we present the query section only.
        #$c->view('TD')->render('query');
    }
    elsif (defined $v1 && defined $v2) {
        # Two versions given.  That means we present the same query section
        # with those values filled in ("sticky"-style), and then, below it,
        # show the changes between those versions.
        #$c->view('TD')->render('response');
    }
    else {
        $c->error(<<'END_ERR');
In order to compare versions, you must provide two version numbers.  You provided only one.
END_ERR
    }
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
