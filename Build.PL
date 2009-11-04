use strict;
use warnings;
use lib 'lib';
use PGX::Build;

my $build = PGX::Build->new(
    module_name        => 'PGX::VersionCompare',
    license            => 'restrictive',
    test_file_exts     => [qw(.t .s)],
    configure_requires => { 'Module::Build' => '0.34'  },
    build_requires     => {
        'Module::Build'    => '0.34',
        'TAP::Harness'     => '3.13',
        'Test::More'       => '0.17',
        'Test::More::UTF8' => '0.02',
        'Test::XML'        => '0.08',
        'Test::XPath'      => '0.10',
    },
    requires           => {
        'aliased'                           => '0.30',
        'perl'                              => 5.010,
        'Catalyst::Action::RenderView'      => '0.11',
        'Catalyst::Devel'                   => '1.2',
        'Catalyst::Plugin::ConfigLoader'    => '0.27',
        'Catalyst::Plugin::StackTrace'      => '0.10',
        'Catalyst::Plugin::Static::Simple'  => '0.22',
        'Catalyst::Plugin::Unicode'         => '0.91',
        'Catalyst::Runtime'                 => '5.80011',
        'Catalyst::View::Template::Declare' => '0.04',
        'DBD::Pg'                           => '2.15.1',
        'DBIx::Connector'                   => '0.30',
        'Exception::Class'                  => '1.29',
        'Exception::Class::DBI'             => '1.00',
        'List::Util'                        => '1.21',
        'YAML::Syck'                        => '1.07',
      },
);

$build->create_build_script;
