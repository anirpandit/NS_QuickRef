package Main::Controller::Login;
use Mojo::Base 'Mojolicious::Controller';

sub login {
    my $self = shift;
    
    my $user = $self->param('username') || '';
    my $pass = $self->param('password') || '';
    return $self->render unless $self->users->check($user, $pass);
    
    $self->session(user => $user);
    $self->flash(message => 'Thanks for logging in.');
    $self->redirect_to('datamgmt');
}

sub logged_in {
    my $self = shift;
    return 1 if $self->session('user');
    $self->redirect_to('login');
    return undef;
}

sub logout {
    my $self = shift;
    $self->session(expires => 1);
    $self->redirect_to('home');
}

sub datamgmt {
    my $self = shift;
    $self->render('/login/datamgmt');
}

1;