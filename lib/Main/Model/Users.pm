package Main::Model::Users;

use strict;
use warnings;

my $USERS = {
    joseph      => 'spid3y',
    anir    => 'batman'
};

sub new { bless {}, shift }

sub check {
    my ($self, $user, $pass) = @_;
    
    # Success
    return 1 if $USERS->{$user} && $USERS->{$user} eq $pass;
    
    # Fail
    return undef;
}

1;