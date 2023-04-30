use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Warnings;
use utf8;

BEGIN {
    use_ok 'API::Medium';
}

SKIP: {
    skip "Token not set, set the TOKEN environment var to the value of your Medium token " if !$ENV{TOKEN};
    my $m       = API::Medium->new( access_token => $ENV{TOKEN} );
    my $hash    = $m->get_current_user;
    my $user_id = $hash->{id};
    my %post    = (
        title         => 'Liverpool FC',
        contentFormat => 'html',
        content       => "<h1>Liverpool FC</h1><p>You'll never walk alone.</p>",
        canonicalUrl  => "http://jamietalbot.com/posts/liverpool-fc",
        tags          => [qw{football sport Liverpool}],
        publishStatus => 'draft',

    );
    my $url;
    lives_ok { $url = $m->create_post( $user_id, \%post ) } "Created post (you'll have to delete it manually)" . ( $url || '<no url>' );

}

done_testing();
