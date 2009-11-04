package PGX::VersionCompare::Controller::Root;

use strict;
use warnings;
use feature ':5.10';
use utf8;

use parent 'Catalyst::Controller';

=head1 Name

PGX::VersionCompare::Controller::Root - Root Controller for PGX::VersionCompare

=head1 Description

Root controller for the PGX version comparison application.

=cut

# Sets the actions in this controller to be registered with no prefix so they
# function identically to actions created in PGX::VersionCompare.
__PACKAGE__->config->{namespace} = '';

=head1 Methods

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my $conn = $c->conn;
    $c->stash( title => 'Welcome' );

    # Either of these will work, but because the template has the same name as
    # this action, we don't have to.
    # $c->stash(template => 'index');
    # $c->view('TD')->render('index');
}

=head2 default

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' ); #FIXME: use something more friendly?
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

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
