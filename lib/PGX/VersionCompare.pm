package PGX::VersionCompare;

use strict;
use warnings;
use feature ':5.10';

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use parent qw/Catalyst/;
use Catalyst (
    '-Debug',
    'ConfigLoader',
    'Static::Simple',
    'StackTrace',
    '-Log=warn,fatal,error',
);

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in pgx_versioncompare.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name         => 'PGX::VersionCompare',
    default_view => 'TD'
);

# Start the application
__PACKAGE__->setup();

1;

=begin comment

Fake-out Module::Build. Delete if it ever changes to support =head1 headers
other than all uppercase.

=head1 NAME

PGX::VersionCompare - PostgreSQL version comparison

=end comment

=head1 Name

PGX::VersionCompare - PostgreSQL version comparison

=head1 Synopsis

    script/pgx_versioncompare_server.pl

=head1 Description

This application allows users to compare changes between releases of
PostgreSQL in order to lear what fixes were introduced and what upgrade issues
there might be to go from one version to another.

=head1 Authors

=over

=item * Josh Berkus <josh.berkus@pgexperts.com>

=item * David E. Wheeler <david.wheeler@pgexperts.com>

=item * Quinn Weaver <quinn.weaver@pgexperts.com>

=back

=head1 Copyright

Copyright (c) 2009 PostgreSQL Experts, Inc. All Rights Reserved.

=cut
