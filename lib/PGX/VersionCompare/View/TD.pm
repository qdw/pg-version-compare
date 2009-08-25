package PGX::VersionCompare::View::TD;
use strict;
use warnings;
use parent 'Catalyst::View::Template::Declare';

1;

=head1 Name

PGX::VersionCompare::View::TD - Template::Declare Views for PGX::VersionCompare

=head1 Synopsis

In a module under the PGX::VersionCompare::View::TD namespace:

  package PGX::VersionCompare::View::TD::Root;

  use strict;
  use warnings;
  use feature ':5.10';
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

In a controller:

  sub index :Path :Args(0) {
      my ( $self, $c ) = @_;
      $c->view('TD')->template('index');
      $c->detach('View::TD');
  }

=head1 Description

This module sets up the Template::Declare templates for PGX::VersionCompare.
All of the templates should go into modules under the
PGX::VersionCompare::View::TD namespace.

=head1 Authors

=over

=item * Josh Berkus <josh.berkus@pgexperts.com>

=item * David E. Wheeler <david.wheeler@pgexperts.com>

=item * Quinn Weaver <quinn.weaver@pgexperts.com>

=back

=head1 Copyright

Copyright (c) 2009 PostgreSQL Experts, Inc. All Rights Reserved.

=cut

