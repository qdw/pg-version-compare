package PGX::Build;

use strict;
use warnings;
use feature ':5.10';
use utf8;

use base 'Module::Build';

=head1 Name

PGX::Build - Build and test PGX database applications.

=head1 Synopsis

In F<Build.PL>:

  use strict;
  use lib 'lib';
  use PGX::Build;

  PGX::Build->new(
      module_name => 'MyApp',
  )->create_build_script;

=head1 Description

This module subclasses L<Module::Build|Module::Build> to provide added
functionality for installing and testing PGX database applications. The added
functionality includes database maintenance.

=cut

##############################################################################

=head1 Class Interface

=head2 Properties

PGX::Build defines these properties in addition to those specified by
L<Module::Build|Module::Build>. Note that these may be specified either in
F<Build.PL> or on the command-line.

=head3 context

  perl Build.PL --context test

Specifies the context in which the build will run. The context associates the
build with a configuration file, and therefore must be named for one of the
configuration files in F<conf>. For example, to build in the "dev" context,
there must be a F<conf/dev.yml> file. Defaults to "test".

=head3 psql

  perl Build.PL --psql /usr/local/pgsql/bin/pgsql

Specifies the location of the C<psql> command-line client. Defaults to "psql",
which should work if a program with that name is somewhere in your path.

=head3 drop_db

  ./Build db --drop_db 1

Tells the L</"db"> action to drop the database and build a new one. When this
property is set to a false value (the default), an exsting database for the
current context will not be dropped, but it will be brought up-to-date.

=cut

__PACKAGE__->add_property( context   => 'test' );
__PACKAGE__->add_property( cx_config => undef  );
__PACKAGE__->add_property( psql      => 'psql' );
__PACKAGE__->add_property( drop_db   => 0      );
__PACKAGE__->add_property( psql_test => 0      );

##############################################################################

=head2 Actions

=head3 test

=begin comment

=head3 ACTION_test

=end comment

Overrides the default implementation to ensure that tests are only run in the
"test" context, to make sure that the database is up-to-date, and to set
things up for pgTAP tests. The pgTAP test functions must be installed in the
"tap" schema. It also sets an environment variable to get Catalyst to be
quiet.

=cut

sub ACTION_test {
    my $self = shift;
    die qq{ERROR: Tests can only be run in the "test" context\n}
        . "Try `./Build test --context test`\n"
        unless $self->context eq 'test';

    # Make sure the database is up-to-date.
    $self->depends_on('code');

    # Set things up for pgTAP tests.
    my $config = $self->read_cx_config;
    my ( $db, $cmd ) = $self->db_cmd( $config->{dbi} );
    push @{ $cmd }, '--dbname' => $db;
    $self->psql_test( $cmd );
    local $ENV{PGOPTIONS} = '--search_path=tap,public';

    # Tell Catalyst to STFU and use the right config.
    local $ENV{CATALYST_DEBUG}  = 0;
    local $ENV{CATALYST_CONFIG} = $self->cx_config;

    # Make it so.
    $self->SUPER::ACTION_test(@_);
}

=begin comment

=head3 run_tap_harness

Override to properly `exit 1` on failure, until a new version comes out with
this patch: L<http://rt.cpan.org/Public/Bug/Display.html?id=49080>

=end comment

=cut

sub run_tap_harness {
    my $ret = shift->SUPER::run_tap_harness(@_);
    exit 1 if $ret->{failed};
    return $ret;
}

##############################################################################

=head3 config_data

=begin comment

=head3 ACTION_config_data

=end comment

Overrides the default implementation to completely change its behavior. :-)
Rather than creating a whole new configuration file in Module::Build's weird
way, this action now simply opens the application file (that returned by
C<dist_version_from> and replaces all instances of "conf/dev.yml" with the
configuration file for the current context. This means that an installed app
is effectively configured for the proper context at intallation time.

=cut

sub ACTION_config_data {
    my $self = shift;

    my $file = File::Spec->catfile( split qr{/}, $self->dist_version_from);
    my $blib = File::Spec->catfile( $self->blib, $file );

    # Die if there is no file
    die qq{ERROR: "$blib" seems to be missing!\n} unless -e $blib;

    # Just return if the default is correct.
    return $self if $self->context eq 'dev';

    # Figure out where we're going to install this beast.
    $file       .= '.new';
    my $new     = File::Spec->catfile( $self->blib, $file );
    my $config  = $self->cx_config;
    my $default = quotemeta File::Spec->catfile( qw( conf dev.yml) );

    # Update the file.
    open my $orig, '<', $blib or die qq{Cannot open "$blib": $!\n};
    open my $temp, '>', $new or die qq{Cannot open "$new": $!\n};
    while (<$orig>) {
        s/$default/$config/g;
        print $temp $_;
    }
    close $orig;
    close $temp;

    # Make the switch.
    rename $new, $blib or die "Cannot rename '$blib' to '$new': $!\n";
    return $self;
}

##############################################################################

=head3 db

=begin comment

=head3 ACTION_db

=end comment

This action creates or updates the database for the current context. If
C<drop_db> is set to a true value, the database will be dropped and created
anew. Otherwise, if the database already exists, it will be brought up-to-date
from the files in the F<sql> directory.

Those files are expected to all be SQL scripts. They must all start with a
number followed by a dash. The number indicates the order in which the scripts
should be run. For exampe, you might have SQL files like so:

  sql/001-types.sql
  sql/002-tables.sql
  sql/003-triggers.sql
  sql/004-functions.sql
  sql/005-indexes.sql

The SQL files will be run in order to build or update the database.
PGX::Build will track the current schema update number corresponding to
the last run SQL script in the C<metadata> table in the database.

If any of the scripts has an error, PGX::Build will immediately exit with
the relevant error. To prevent half-way applied updates, the SQL scripts
should use transactions as appropriate.

=cut

sub ACTION_db {
    my $self = shift;

    # Get the database configuration information.
    my $config = $self->read_cx_config;

    my ( $db, $cmd ) = $self->db_cmd( $config->{dbi} );

    # Does the database exist?
    my $db_exists = $self->drop_db ? 1 : $self->_probe(
        @$cmd,
        '-d' => 'template1',
        '-c' => qq{
            SELECT 1
              FROM pg_catalog.pg_database
             WHERE datname = '$db';
        },
    );

    if ( $db_exists ) {
        # Drop the existing database?
        if ( $self->drop_db ) {
            $self->log_info(qq{Dropping the "$db" database\n});
            $self->do_system(
                @$cmd,
                '-d' => 'template1',
                '-c' => qq{DROP DATABASE IF EXISTS "$db"}
            ) or die;
        } else {
            # Just run the upgrades and be done with it.
            push @$cmd, '-d' => $db;
            $self->upgrade_db( $db, $cmd );
            return;
        }
    }

    # Now create the database and run all of the SQL files.
    $self->log_info(qq{Creating the "$db" database\n});
    $self->do_system(
        @$cmd,
        '-d' => 'template1',
        '-c' => qq{CREATE DATABASE "$db"}
    ) or die;
    push @$cmd, '-d' => $db;

    # Add the metadata table and run all of the schema scripts.
    $self->create_meta_table( $cmd );
    $self->upgrade_db( $db, $cmd );
}

##############################################################################

=head2 Instance Methods

=head3 tap_harness_args

  my $tap_harness_args = $build->tap_harness_args;

This method overrides the default value to provide support for pgTAP tests,
using the database connection information in the current context's
configuration file.

=cut

# Make sure htat we can just run SQL tests.
sub tap_harness_args {
    my $self = shift;
    return {
        exec => sub {
            my ( $harness, $test_file ) = @_;
            # Let Perl tests run.
            return undef if $test_file =~ /[.]t$/;
            return [ @{ $self->psql_test }, '-f', $test_file ]
                if $test_file =~ /[.]s$/;
        },
    };
}

##############################################################################

=begin private

=head3 cx_config

Stores the current context's configuration file. Private for now.

=end private

=cut

sub cx_config {
    my $self = shift;
    return $self->{properties}{cx_config} if $self->{properties}{cx_config};
    return $self->{properties}{cx_config} = File::Spec->catfile(
        'conf',
        $self->context . '.yml',
    );
}

##############################################################################

=head3 read_cx_config

  my $config = $build->read_cx_config;

Uses L<YAML::Syck|YAML::Syck> to read and return the contents of the current
context's configuration file.

=cut

sub read_cx_config {
    my $self = shift;
    my $cfile = $self->cx_config;
    die qq{Cannot read configuration file "$cfile" because it does not exist\n}
        unless -f $cfile;
    require YAML::Syck;
    YAML::Syck::LoadFile($cfile);
}

=begin private

=head3 db_cmd

  my ($db_name, $db_cmd) = $build->db_cmd;

Uses the current context's configuration to determine all of the options to
run C<psql> both for testing (pgTAP) and for building the database. Returns
the name of the database and an array ref representing the C<psql> command and
all of its options, suitable for passing to C<system>. The The database name
is not included in the command; simply append it to the command to have the
command connect to that database:

  push $db_cmd, '--dbname', $db_name;

It is not included so as to enable connecting to another database (e.g.,
template1) to create the database.

=cut

sub db_cmd {
    my ($self, $dconf) = @_;
    ( my $dsn = $dconf->{dsn} ) =~ s/^dbi:[^:]+://i;
    my %dsn = map { split /=/ } split /;/, $dsn;

    # Set up the PostgreSQL command.
    my @cmd = (
        $self->psql,
        '--username' => $dconf->{user},
        '--quiet',
        '--no-psqlrc',
        '--no-align',
        '--tuples-only',
        '--set' => 'ON_ERROR_ROLLBACK=1',
        '--set' => 'ON_ERROR_STOP=1',
    );
    push @cmd, '--host' => $dsn{host} if $dsn{host};
    push @cmd, '--port' => $dsn{port} if $dsn{port};
    return $dsn{dbname}, \@cmd
}

##############################################################################

=head3 create_meta_table

  my ($db_name, $db_cmd ) = $build->db_cmd;
  $build->create_meta_table( $db_cmd );

Creates the C<metadata> table, which PGX::Build uses to track the current
schema version (corresponding to update numbers on the SQL scripts in F<sql>
and other application metadata. If the table already exists, it will be
dropped and recreated. One row is initially inserted, setting the
"schema_version" to 0.

=cut

sub create_meta_table {
    my ($self, $cmd) = @_;
    my $quiet = $self->quiet;
    $self->quiet(1) unless $quiet;
    $self->do_system(@$cmd, '-c', qq{
        SET client_min_messages=warning;
        DROP TABLE IF EXISTS metadata;
        CREATE TABLE metadata (
            label TEXT PRIMARY KEY,
            value INT  NOT NULL DEFAULT 0,
            note  TEXT NOT NULL
        );
        INSERT INTO metadata VALUES ( 'schema_version', 0, '' );
    }) or die;
    $self->quiet(0) unless $quiet;
}

##############################################################################

=head3 upgrade_db

  my ($db_name, $db_cmd ) = $build->db_cmd;
  push $db_cmd, '--dbname', $db_name;
  $self->upgrade_db( $db_name, $db_cmd );

Upgrades the database using all of the schema files in the F<sql> directory,
applying each in numeric order, setting the schema version upon the success of
each, and exiting upon any error.

=cut

sub upgrade_db {
    my ($self, $db, $cmd) = @_;

    $self->log_info(qq{Updating the "$db" database\n});

    # Get the current version number of the schema.
    my $curr_version = $self->_probe(
        @$cmd,
        '-c' => qq{SELECT value FROM metadata WHERE label = 'schema_version'},
    );

    my $quiet = $self->quiet;
    # Apply all relevant upgrade files.
    for my $sql (sort grep { -f } glob 'sql/[0-9]*-*.sql' ) {
        # Compare upgrade version numbers.
        ( my $new_version = $sql ) =~ s{^sql[/\\](\d+)-.+}{$1};
        next unless $new_version > $curr_version;

        # Apply the version.
        $self->do_system( @$cmd, '-f' => $sql ) or die;
        $self->quiet(1) unless $quiet;
        $self->do_system( @$cmd, '-c' => qq{
            UPDATE metadata
               SET value = $new_version
             WHERE label = 'schema_version'
        }) or die;
        $self->quiet(0) unless $quiet;
    }
}

sub _probe {
    my $self = shift;
    my $ret = $self->_backticks(@_);
    chomp $ret;
    return $ret;
}

1;

__END__

=head1 Author

David E. Wheeler <david.wheeler@pgexperts.com>

=head1 Copyright

This library is Copyright (c) 2008 Kineticode, Inc. and 2009 PostgreSQL
Experts, Inc. All rights reserved.

