package API::Medium::Data::User;
use Moose;

# ABSTRACT: A User

has [qw(id username)] => (
    is=>'ro',
    isa=>'Str',
    required=>1
);

has [qw(name url imageUrl)] => (
    is=>'ro',
    isa=>'Str',
);

sub create_post_endpoint {
    my $self = shift;
    return 'users/'.$self->id.'/posts';
}

__PACKAGE__->meta->make_immutable;
1;
