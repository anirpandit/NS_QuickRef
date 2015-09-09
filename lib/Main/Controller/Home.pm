# Controller
package Main::Controller::Home;
use Mojo::Base 'Mojolicious::Controller';

# Action
sub gohome {
    
    my $self = shift;
    $self->render('home');
}

1;