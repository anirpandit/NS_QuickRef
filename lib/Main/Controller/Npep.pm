# Controller
package Main::Controller::Npep;
use Mojo::Base 'Mojolicious::Controller';

# Action
sub getnpep {
    
    my $self = shift;
    
    my $npep_new = $self->param('new');
    my $npep_del = $self->param('del');
    my $npep_edit = $self->param('edit');
    my $npep_update = $self->param('update');
    
    
    my $neuropeptideID = $self->param('neuropeptideID');
    my $NeuropeptideName = $self->param('NeuropeptideName');
    my $NeuropeptideDesc = $self->param('NeuropeptideDesc');

    my $NeuropeptideName_ed = $self->param('NeuropeptideName_ed');
    my $NeuropeptideDesc_ed = $self->param('NeuropeptideDesc_ed');
    
    my $message_to_page=0; my $sth2; my $npep_edit_array;
    
    my $dbh = $self->app->dbh;
    
    if(defined $npep_edit){
        my $query2 = '
        SELECT DISTINCT NeuropeptideInfo.neuropeptideID, NeuropeptideInfo.NeuropeptideName, NeuropeptideInfo.NeuropeptideDesc
        FROM NeuropeptideInfo
        WHERE NeuropeptideInfo.neuropeptideID = ? ';
        
        my $sth2 = $dbh->prepare($query2);
        $sth2->execute($neuropeptideID);
        
        $npep_edit_array = $sth2->fetchall_arrayref;
        
        $message_to_page = 3;
        
    }
    
    if(defined $npep_update){
        my $query3 = '
        UPDATE NeuropeptideInfo SET
        NeuropeptideInfo.NeuropeptideName = ?,
        NeuropeptideInfo.NeuropeptideDesc = ?
        WHERE NeuropeptideInfo.neuropeptideID = ? ';
        
        my $sth3 = $dbh->prepare($query3);
        $sth3->execute($NeuropeptideName_ed,$NeuropeptideDesc_ed,$neuropeptideID);
        
        $message_to_page = 4;
        
    }
    
    if(defined $npep_del){
        my $query3 = '
        DELETE FROM NeuropeptideInfo WHERE neuropeptideID = ? ';
        
        my $sth3 = $dbh->prepare($query3);
        $sth3->execute($neuropeptideID);
        
        $message_to_page = 2;
    }
    
    if(defined $npep_new){
        my $query4 = 'INSERT INTO NeuropeptideInfo (NeuropeptideName,NeuropeptideDesc) VALUES (?,?)';
        my $sth4 = $dbh->prepare($query4);
        $sth4->execute($NeuropeptideName,$NeuropeptideDesc);
        
        $message_to_page = 1;
    }
    
    my $query = '
    SELECT DISTINCT NeuropeptideInfo.neuropeptideID, NeuropeptideInfo.NeuropeptideName, NeuropeptideInfo.NeuropeptideDesc
    FROM NeuropeptideInfo' ;
    
    my $sth = $dbh->prepare($query);
    $sth->execute();
    
    $self->stash(
    npep_info => $sth->fetchall_arrayref,
    npep_edit_array => $npep_edit_array,
    message_to_page => $message_to_page
    );
    
    $self->render('/datamgmt/get_npep');
}
1;