# Controller
package Main::Controller::Species;
use Mojo::Base 'Mojolicious::Controller';

# Action
sub getspecies {
    
    my $self = shift;
   
    my $species_new = $self->param('new');
    my $species_del = $self->param('del');
    my $species_edit = $self->param('edit');
    my $species_update = $self->param('update');
    
    
    my $speciesID = $self->param('speciesID');
    my $orderID = $self->param('orderID');
    my $SpeciesName = $self->param('SpeciesName');
    my $CommonName = $self->param('CommonName');
    my $Importance = $self->param('Importance');
    my $GenomeSequence = $self->param('GenomeSequence');
    my $GenomeDatabase = $self->param('GenomeDatabase');
    my $DatabaseURL = $self->param('DatabaseURL');

    my $orderID_ed = $self->param('orderID_ed');
    my $SpeciesName_ed = $self->param('SpeciesName_ed');
    my $CommonName_ed = $self->param('CommonName_ed');
    my $Importance_ed = $self->param('Importance_ed');
    my $GenomeSequence_ed = $self->param('GenomeSequence_ed');
    my $GenomeDatabase_ed = $self->param('GenomeDatabase_ed');
    my $DatabaseURL_ed = $self->param('DatabaseURL_ed');

    my $message_to_page=0; my $sth2; my $species_edit_array;
    
    my $dbh = $self->app->dbh;
    
    if(defined $species_edit){
        my $query2 = '
        SELECT DISTINCT SpeciesInfo.speciesID, SpeciesInfo.orderID, SpeciesInfo.SpeciesName, SpeciesInfo.CommonName, SpeciesInfo.Importance, SpeciesInfo.GenomeSequence, SpeciesInfo.GenomeDatabase, SpeciesInfo.DatabaseURL
        FROM SpeciesInfo
        WHERE SpeciesInfo.speciesID = ? ';
        
        my $sth2 = $dbh->prepare($query2);
        $sth2->execute($speciesID);
        
        $species_edit_array = $sth2->fetchall_arrayref;
        
        $message_to_page = 3;

    }
    
     if(defined $species_update){
        my $query3 = '
            UPDATE SpeciesInfo SET
            SpeciesInfo.orderID = ?,
            SpeciesInfo.SpeciesName = ?,
            SpeciesInfo.CommonName = ?,
            SpeciesInfo.Importance = ?,
            SpeciesInfo.GenomeSequence = ?,
            SpeciesInfo.GenomeDatabase = ?,
            SpeciesInfo.DatabaseURL = ?,
            WHERE SpeciesInfo.speciesID = ? ';
        
         my $sth3 = $dbh->prepare($query3);
         $sth3->execute($orderID_ed,$SpeciesName_ed,$CommonName_ed,$Importance_ed,$GenomeSequence_ed,$GenomeDatabase_ed,$DatabaseURL_ed,$speciesID);
        
         $message_to_page = 4;
       
    }
    
    if(defined $species_del){
        my $query3 = '
        DELETE FROM SpeciesInfo WHERE speciesID = ? ';
        
        my $sth3 = $dbh->prepare($query3);
        $sth3->execute($speciesID);
        
        $message_to_page = 2;
    }
    
    if(defined $species_new){
        my $query4 = 'INSERT INTO SpeciesInfo (speciesID,orderID,SpeciesName,CommonName,Importance,GenomeSequence,GenomeDatabase,DatabaseURL) VALUES (?,?,?,?,?,?,?,?)';
        my $sth4 = $dbh->prepare($query4);
        $sth4->execute($speciesID,$orderID,$SpeciesName,$CommonName,$Importance,$GenomeSequence,$GenomeDatabase, $DatabaseURL);
        
        $message_to_page = 1;
    }
    
    my $query = '
        SELECT DISTINCT SpeciesInfo.SpeciesName, OrderInfo.OrderName, SpeciesInfo.CommonName, 
        SpeciesInfo.Importance, SpeciesInfo.GenomeSequence, SpeciesInfo.GenomeDatabase, SpeciesInfo.DatabaseURL, SpeciesInfo.speciesID
        FROM SpeciesInfo, OrderInfo
        WHERE SpeciesInfo.orderID = OrderInfo.orderID
        ORDER BY SpeciesInfo.speciesID';
    
    my $sth = $dbh->prepare($query);
    $sth->execute();
    
    $self->stash(
    species_info => $sth->fetchall_arrayref,
    species_edit_array => $species_edit_array,
    message_to_page => $message_to_page
    );
    
    $self->render('/datamgmt/get_species');
}
1;