use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'PGX::VersionCompare' }
BEGIN { use_ok 'PGX::VersionCompare::Controller::Compare' }

ok( request('/compare')->is_success, 'Request should succeed' );


