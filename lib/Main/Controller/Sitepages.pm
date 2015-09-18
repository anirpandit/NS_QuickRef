# Controller
package Main::Controller::Sitepages;
use Mojo::Base 'Mojolicious::Controller';

# Action
sub gohome {
    
    my $self = shift;
    $self->render('/home');
}

sub getabout {
    
    my $self = shift;
    $self->render('/project/about');
}

sub getboard {
    
    my $self = shift;
    $self->render('/project/board');
}

sub getconsortium {
    
    my $self = shift;
    $self->render('/project/consortium');
}

sub getcontact {
    
    my $self = shift;
    $self->render('/contact');
}

1;