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

sub getprofile {
    
    my $self = shift;
    my $dbh = $self->app->dbh;

    my $query = '
    SELECT DISTINCT PIProfiles.piID, PIProfiles.PIName, PIProfiles.PIOrganisation, PIProfiles.PIImageSrc
    FROM PIProfiles
    ORDER BY PIProfiles.piID';

    my $sth = $dbh->prepare($query);
    $sth->execute();

    my $query2 = '
    SELECT DISTINCT PIProfiles.piID, PIProfiles.PIName,  PIProfiles.PIOrganisation, PIProfiles.PIPosition, PIProfiles.PIProfile, PIProfiles.PIWebsite, PIProfiles.PIImageSrc
    FROM PIProfiles
    ORDER BY PIProfiles.piID';

    my $sth2 = $dbh->prepare($query2);
    $sth2->execute();
    
    $self->stash(
        part_profile_info => $sth->fetchall_arrayref,
        full_profile_info => $sth2->fetchall_arrayref

    );

    $self->render('/project/profile');
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