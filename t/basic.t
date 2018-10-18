#!/usr/bin/perl
use Test::More;
use Test::Exception;
use lib 'lib';

use_ok( 'API::Medium' );

my $api = API::Medium->new({ access_token => 'your_token' });

throws_ok { $api->create_post }
qr/missing required user id/, 'caught missing user id';

throws_ok { $api->create_post(1234) }
qr/missing required post/, 'caught missing post';

throws_ok { $api->create_post(1234, 'abcd') }
qr/post has to be hashref/, 'caught invalid post';

done_testing();
