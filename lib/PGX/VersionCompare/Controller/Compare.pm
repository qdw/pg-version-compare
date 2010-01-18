package PGX::VersionCompare::Controller::Compare;

use strict;
use warnings;
use feature ':5.10';
use utf8;
use parent 'Catalyst::Controller';

use PGX::VersionCompare::Helpers;
use aliased 'PGX::VersionCompare::Helpers' => 'H';
use List::Util qw( first );

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

=head2 handle_form

handle_form - this is the method that the form submits to
(XHTML:  <form ... action="/handle_form"...>)

It takes the major and minor version fields in the form and concatenates them
to get a URI like /compare/8.0.0/8.1.1 .  It also tacks on the search
expression, if there is any: /compare/8.1.0/8.1.1?q=Hiroshi .  Then it
redirects to that URI, which triggers the compare action.

In this way, we get to use the compare subroutine for all requests, whether
they come from form submission or from someone entering a URL directly.

=cut
sub handle_form :Path('/handle_form') {
    my ($self, $c) = @_;
    $c->stash(title => 'Compare');

    my $v1 = $c->req->params->{'major_1'} . '.' . $c->req->params->{'minor_1'};
    my $v2 = $c->req->params->{'major_1'} . '.' . $c->req->params->{'minor_2'};
    my $uri = "/compare/$v1/$v2";
    if ($c->req->params->{q}) {
        $uri .= "/?q=" . $c->req->params->{q};
    }

    $c->res->redirect($uri); # Don't use uri_for; it mangles the '?' char #FIXME:  Is this RFC-compliant?
    $c->detach();
}

=head2 compare

If no input was given, just show the query form (template 'compare').

If input was given, show that same form with sticky values, plus the result
of the query (template 'compare_result').  The query result is passed between
this controller action and the view template via sth's in the stash.  This
method prepares and executes the query, and returns the sth's ready
for fetching.

=cut
sub compare :Path('/compare') {
    my ($self, $c, $v1, $v2) = @_;
    my $q = first {defined $_} $c->req->params->{'q'}, '';
    my $conn = $c->conn;
    $c->stash(known_versions_ref => $conn->run(fixup => sub {
        H->get_known_versions_ref($conn);
    }));

    $c->stash(title => 'Compare');

    if (!defined $v1 && !defined $v2) {
        # No versions given.  That means we present the query section only.
        $c->stash('template', 'compare');
    }
    elsif (defined $v1 && defined $v2) {
        # Parse out major and minor, so we can call the stored procedures;
        # stash     major and minor, so the view can populate sticky form fields
        $c->stash(q => $q);
        my ($major_1, $minor_1) = H->parse_version($v1); # for sticky <select>s
        my ($major_2, $minor_2) = H->parse_version($v2); # for sticky <select>s
        $c->stash(major_1 => $major_1);
        $c->stash(major_2 => $major_2);
        $c->stash(minor_1 => $minor_1);
        $c->stash(minor_2 => $minor_2);

        # Two versions given.  That means we present the same form with
        # "sticky" values, and then, below it, show the result of the search.
        $c->stash->{fixes_sth} = $conn->run(fixup => sub {
            my $sth = shift->prepare(q{SELECT * FROM get_fixes(?, ?, ?, ?)});
            $sth->execute( $major_1, $minor_1, $minor_2, $q);
            return $sth;
        });

        $c->stash->{upgrade_warnings_sth} = $conn->run(fixup => sub {
            my $sth = shift->prepare(q{SELECT * FROM get_upgrade_warnings(?, ?, ?)});
            $sth->execute( $major_1, $minor_1, $minor_2);
            return $sth;
        });
        
        $c->stash('template', 'compare_result');
    }
    else {
        $c->stash(error =>
            'In order to compare versions, you must provide two version'
            . ' numbers.  You provided only one.'
        );
        $c->stash('template', 'compare');
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
