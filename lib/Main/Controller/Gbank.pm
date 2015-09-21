# Controller
package Main::Controller::Gbank;
use Mojo::Base 'Mojolicious::Controller';

# Action
sub getgbank {
    
    my $self = shift;
    
    my $gbank_new = $self->param('new');
    my $gbank_del = $self->param('del');
    my $gbankit = $self->param('edit');
    my $gbank_update = $self->param('update');
    
    
    my $geneID = $self->param('geneID');
    my $speciesID = $self->param('speciesID');
    my $neuropeptideID = $self->param('neuropeptideID');
    my $GenBankAscNum = $self->param('GenBankAscNum');
    my $GenBankAscNumURL = $self->param('GenBankAscNumURL');

    
    my $speciesID_ed = $self->param('speciesID_ed');
    my $neuropeptideID_ed = $self->param('neuropeptideID_ed');
    my $GenBankAscNum_ed = $self->param('GenBankAscNum_ed');
    my $GenBankAscNumURL_ed = $self->param('GenBankAscNumURL_ed');

    my $message_to_page=0; my $sth2; my $gbankit_array;
    
    my $dbh = $self->app->dbh;
    
    if(defined $gbankit){
        my $query2 = '
        SELECT DISTINCT NeuroPepGeneInfo.geneID, NeuroPepGeneInfo.speciesID, NeuroPepGeneInfo.neuropeptideID, NeuroPepGeneInfo.GenBankAscNum, NeuroPepGeneInfo.GenBankAscNumURL
        FROM NeuroPepGeneInfo
        WHERE NeuroPepGeneInfo.geneID = ? ';
        
        my $sth2 = $dbh->prepare($query2);
        $sth2->execute($geneID);
        
        $gbankit_array = $sth2->fetchall_arrayref;
        
        $message_to_page = 3;
        
    }
    
     if(defined $gbank_update){
        my $query3 = '
            UPDATE NeuroPepGeneInfo SET
            NeuroPepGeneInfo.speciesID = ?,
            NeuroPepGeneInfo.neuropeptideID = ?,
            NeuroPepGeneInfo.GenBankAscNum = ?,
            NeuroPepGeneInfo.GenBankAscNumURL = ?
            WHERE NeuroPepGeneInfo.geneID = ? ';
        
         my $sth3 = $dbh->prepare($query3);
         $sth3->execute($speciesID_ed,$neuropeptideID_ed,$GenBankAscNum_ed,$GenBankAscNumURL_ed,$geneID);
        
         $message_to_page = 4;
       
    }
    
    if(defined $gbank_del){
        my $query3 = '
        DELETE FROM NeuroPepGeneInfo WHERE geneID = ? ';
        
        my $sth3 = $dbh->prepare($query3);
        $sth3->execute($geneID);
        
        $message_to_page = 2;
    }
    
    if(defined $gbank_new){
        my $query4 = 'INSERT INTO NeuroPepGeneInfo (speciesID,neuropeptideID,GenBankAscNum,GenBankAscNumURL) VALUES (?,?,?,?)';
        my $sth4 = $dbh->prepare($query4);
        $sth4->execute($speciesID,$neuropeptideID,$GenBankAscNum,$GenBankAscNumURL);
        
        $message_to_page = 1;
    }
    
    my $query = '
    
        SELECT DISTINCT NeuroPepGeneInfo.geneID, SpeciesInfo.SpeciesName, NeuropeptideInfo.NeuropeptideName, NeuroPepGeneInfo.GenBankAscNum, NeuroPepGeneInfo.GenBankAscNumURL
            FROM NeuroPepGeneInfo, NeuropeptideInfo, SpeciesInfo
            WHERE NeuroPepGeneInfo.speciesID = SpeciesInfo.speciesID
            AND NeuroPepGeneInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
            ORDER BY SpeciesInfo.speciesID';
    
    my $sth = $dbh->prepare($query);
    $sth->execute();
    
    $self->stash(
    gbank_info => $sth->fetchall_arrayref,
    gbankit_array => $gbankit_array,
    message_to_page => $message_to_page
    );
    
    $self->render('/datamgmt/get_gbank');
}
1;