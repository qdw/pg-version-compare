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
        'Module::Build' => '0.34',
        'TAP::Harness'  => '3.13',
        'Test::More'    => '0.17',
        'Test::XML'     => '0.08',
    },
    requires           => {
        'perl'                              => 5.010,
        'Catalyst::Runtime'                 => '5.80011',
        'Catalyst::Plugin::ConfigLoader'    => '0.27',
        'Catalyst::Plugin::Static::Simple'  => '0.22',
        'Catalyst::Action::RenderView'      => '0.11',
        'Catalyst::Devel'                   => '1.2',
        'Catalyst::Model::DBI'              => '0.20',
        'Catalyst::Plugin::StackTrace'      => '0.10',
        'Catalyst::View::Template::Declare' => '0.04',
        'DBD::Pg'                           => '2.15.1',
        'Exception::Class::DBI'             => '1.00',
        'Test::Pod::Coverage'               => '1.08',
        'Test::XML'                         => '0.08',
        'YAML::Syck'                        => '1.07',
        'XML::XPath'                        => '1.13',
      },
);

$build->create_build_script;
