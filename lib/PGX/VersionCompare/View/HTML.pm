package PGX::VersionCompare::View::HTML;

use strict;
use warnings;
use parent 'Catalyst::View::TD';

# Unless auto_alias is false, Catalyst::View::TD will automatically load all
# modules below the PGX::VersionCompare::Templates::HTML namespace and alias their
# templates into PGX::VersionCompare::Templates::HTML. It's simplest to create your
# template classes there. See the Template::Declare documentation for a
# complete description of its init() parameters, all of which are supported
# here.

__PACKAGE__->config(
    # dispatch_to     => [qw(PGX::VersionCompare::Templates::HTML)],
    # auto_alias      => 1,
    # strict          => 1,
    # postprocessor   => sub { ... },
    # around_template => sub { ... },
);

=head1 Name

PGX::VersionCompare::View::HTML - HTML Views for PGX::VersionCompare

=head1 Synopsis

In a module under the PGX::VersionCompare::Templates::HTML namespace:

  package PGX::VersionCompare::Templates::HTML;

  use strict;
  use warnings;
  use feature ':5.10';
  use utf8;
  use Template::Declare::Tags;

  template index => sub {
      my ($self, $args) = @_;
      html {
          head { title { $args->{title} } };
          body {
              h1 { 'Welcome!' };
          };
      };
  };

  1;

In a controller:

  sub index :Path :Args(0) {
      my ( $self, $c ) = @_;
      $c->view('HTML')->template('index');
      $c->detach('View::HTML');
  }

=head1 Description

This module sets up the Template::Declare templates for PGX::VersionCompare.
All of the templates should go into modules under the
L<PGX::VersionCompare::Templates::HTML|PGX::VersionCompare::Templates::HTML>
namespace.

=head1 Authors

=over

=item * Josh Berkus <josh.berkus@pgexperts.com>

=item * David E. Wheeler <david.wheeler@pgexperts.com>

=item * Quinn Weaver <quinn.weaver@pgexperts.com>

=back

=head1 Copyright

Copyright (c) 2009 PostgreSQL Experts, Inc. All Rights Reserved.

=cut

1;
