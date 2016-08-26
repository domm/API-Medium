package API::Medium;
use Moose;
use HTTP::Tiny;
use Log::Any qw($log);
use JSON::MaybeXS;
use Module::Runtime 'use_module';

# ABSTRACT: Talk with medium.com using their REST API

our $VERSION = '0.900';

has 'server' => (
    isa=>'Str',
    is=>'ro',
    default=>'https://api.medium.com/v1',
);

has 'access_token' => (
    isa=>'Str',
    is=>'rw',
    required=>1,
);

has 'refresh_token' => (
    isa=>'Str',
    is=>'ro',
);

has '_client' => (
    isa=>'HTTP::Tiny',
    is=>'ro',
    lazy_build=>1,
);

sub _build__client {
    my $self = shift;

    return HTTP::Tiny->new(
        agent => join('/',__PACKAGE__,$VERSION),
        default_headers=>{
            'Authorization'=>'Bearer '.$self->access_token,
            'Accept'=>'application/json',
            'Content-Type'=>'application/json',
        }
    );
}

sub get_current_user {
    my $self = shift;

    my $res = $self->request('GET', 'me');

    return use_module('API::Medium::Data::User')->new($res->{data});
}

sub create_post {
    my ($self, $user, $post) = @_;

    my $res = $self->request('POST', $user->create_post_endpoint, $post);
    use Data::Dumper; $Data::Dumper::Maxdepth=3;$Data::Dumper::Sortkeys=1;warn Data::Dumper::Dumper $res;


}

sub request {
    my ($self, $method, $endpoint, $data) = @_;

    my $url = join('/',$self->server, $endpoint);

    my $res;
    if ($data) {
        $res = $self->_client->request($method, $url, {
                content=>encode_json($data)});
    }
    else {
        $res = $self->_client->request($method, $url);
    }
    if ($res->{success} ) {
        return decode_json($res->{content});
    }
    else {
        $log->errorf("Could not talk to medium: %i %s",$res->{status},$res->{reason});
        use Data::Dumper; $Data::Dumper::Maxdepth=3;$Data::Dumper::Sortkeys=1;warn Data::Dumper::Dumper $res;

        die join(' ',$res->{status}, $res->{reason});
    }
}


__PACKAGE__->meta->make_immutable;
1;
__END__

=pod

get an Integration tokens

api docs

https://github.com/Medium/medium-api-docs

=head2 Authentication
args
=head3 OAuth2 Login

Not implemented yet, mostly because medium only support the "web server" flow and I'm using C<API::Medium> for an installed application.

=head3 Self-issuecreate_postd access token / Integration token

Go to your L<settings|https://medium.com/me/settings>, scroll down to "Integration tokens", and either create a new one, or pick the one you want to use.

=head2 Methods

https://api.medium.com/v1

=head3 get_current_user

Getting the authenticated user’s details
/me

=head3 publications

Listing the user’s publications
/users/{{userId}}/publications

=head3 contributors

Fetching contributors for a publication
/publications/{{publicationId}}/contributors

=head3 create_post

Creating a post
/users/{{authorId}}/posts

=head3 create_publication_post

Creating a post under a publication
/publications/{{publicationId}}/posts



=head2 TODO

=over

=item * OAuth2 Login

=item * Get a new access_token from refresh_token

=back


=cut
