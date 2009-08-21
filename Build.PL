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
        'Test::More'    => '0.17',
        'TAP::Harness'  => '3.13',
    },
    requires           => {
        'Catalyst::Runtime'                 => '5.80008',
        'Catalyst::Plugin::ConfigLoader'    => 0,
        'Catalyst::Plugin::Static::Simple'  => 0,
        'Catalyst::Action::RenderView'      => 0,
        'Catalyst::Devel'                   => 0,
        'Catalyst::Model::DBI'              => 0,
        'Catalyst::Plugin::StackTrace'      => 0,
        'Catalyst::View::Template::Declare' => '0.03',
        'DBD::Pg'                           => 0,
      },
);

$build->create_build_script;
