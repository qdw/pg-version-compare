package PGX::VersionCompare::Controller::Compare;

use strict;
use warnings;
use feature ':5.10';
use parent 'Catalyst::Controller';

use PGX::VersionCompare::Helpers;
use aliased 'PGX::VersionCompare::Helpers' => 'H';



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

Controller to compare two PostgreSQL versions (that is, find the fixes
between them).

=cut

# sub path_handler :Path('/compare') {
#     my ($self, $c) = @_;
#     my $v1 = $c->req->params->{major} . '.' . $c->req->params{minor_1};
#     my $v2 = $c->req->params->{major} . '.' . $c->req->params{minor_2};
#     $c->stash(
#         title => 'pg-version-compare: Track Changes between PostgreSQL Versions'
#     );

#     my $uri = "/version/$v1/$v2";
#     if (defined (my $search_expr = $c->req->params{search_expr})) {
#         $uri .= "?q=$search_expr";
#     }
#     $c->res->redirect($c->uri_for($uri));
#     $c->detach();
# }

sub version :Path('/version') {
    my ($self, $c, $v1, $v2) = @_;
    my $search_expr = $c->request->params->{search_expr};

    $c->stash(
        title => 'pg-version-compare: Track Changes between PostgreSQL Versions'
    );
    
    my $dbh = $c->model('DBI')->dbh;
    $c->stash(dbh => $dbh);
    $c->stash(known_versions_ref => H->get_known_versions_ref($dbh));

    # Parse out major and minor, so we can call the stored procedures;
    # also, stash them so the view can populate sticky form fields.
    $c->stash(search_expr => $search_expr);
    my ($major_1, $minor_1) = H->parse_version($v1); # for sticky <select>s
    my ($major_2, $minor_2) = H->parse_version($v2); # for sticky <select>s
    $c->stash(major_1 => $major_1);
    $c->stash(major_2 => $major_2);
    $c->stash(minor_1 => $minor_1);
    $c->stash(minor_2 => $minor_2);
    
    $c->stash(
        title => 'pg-version-compare: Track Changes between PostgreSQL Versions'
    );

    if (!defined $v1 && !defined $v2) {
        # No versions given.  That means we present the query section only.
        $c->stash(template => 'query');
        return;
    }
    elsif (defined $v1 && defined $v2) {
        # Two versions given.  That means we present the same form with
        # "sticky" values, and then, below it, show the result of the search.

        my $fixes_sth = $dbh->prepare(<<"END_CHANGES");
SELECT * FROM get_fixes('$major_1', $minor_1, $minor_2, '$search_expr');
END_CHANGES
        $fixes_sth->execute();
        $c->stash->{fixes_sth} = $fixes_sth;        

        $c->stash(template => 'result');
        return;
    }
    else {
        $c->error(<<'END_ERR');
In order to compare versions, you must provide two version numbers.  You provided only one.
END_ERR
        $c->stash(template => 'query');
        return;
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
