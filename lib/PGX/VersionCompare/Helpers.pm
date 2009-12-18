package PGX::VersionCompare::Helpers;

use warnings;
use strict;
use feature ':5.10';
use utf8;

use Exception::Class(
    'PGX::VersionCompare::MalformedVersion' => {
        fields => ['version'],
    },
);

=head1 Name

PGX::VersionCompare::Helpers - various helper functions used by the controller

=head1 Synopsis

use PGX::VersionCompare::Helpers;

# or, if that package name is too long for you to type, do something like
use aliased 'PGX::VersionCompare::Helpers' => 'H';

my ($major_version, $minor_version) = H->parse_version($version);

my $major_to_minors = H->get_known_versions_ref();
my @major_versions = keys %$major_to_minors;
my $minor_versions_arrayref = $major_to_minors->{$major_version};

=head1 Diagnostics

parse_version() may throw a PGX::VersionCompare::MalformedVersion.

get_known_versions_ref() may throw Exception::Class::DBI exceptions.

=cut

=head2 parse_version

Given a version string like 8.4.1, parse it into major (8.4) and minor (1)
version numbers.

Return an array like ('8.4, 1')

=cut
sub parse_version {
    my ($class, $version) = @_;
    if ($version =~ m{ ( \d+ [.] \d+ ) [.] (\d+) }smx) {
        return $1, $2; # ($major, $minor)
    }
    else {
        throw PGX::VersionCompare::MalformedVersion(version => $version);
    }
}

=head2 get_known_versions_ref

Return a hashref mapping major versions to minor versions, like this:

{
    '8.3' => [
                     0,
                     1,
                     2,
                     3,
                     4,
                     5,
                     6,
                     7
     ],
     '8.2' => [
                     0,
                     1,
                     2,
                     3,
                     4,
                     5,
                     6,
                     7,
                     8,
                     9,
                     10,
                     11,
                     12,
                     13
     ],
     #...
}

=cut

sub get_known_versions_ref {
    my ($class, $conn) = @_;

    my $dbh = $conn->dbh();
    my @major_versions = @{ $dbh->selectcol_arrayref(<<'    END_MAJOR_SELECT') };
        SELECT * FROM major_versions();
    END_MAJOR_SELECT

    my %retval;
    for my $major_version (@major_versions) {
        my @minor_versions = @{ $dbh->selectcol_arrayref(<<"        END_MINOR_SELECT")};
            SELECT * FROM minor_versions('$major_version');
        END_MINOR_SELECT
        $retval{$major_version} = \@minor_versions;
    }

    return \%retval;
}

1;
