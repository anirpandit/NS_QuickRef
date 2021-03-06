# Controller
package Main::Controller::Func;
use Mojo::Base 'Mojolicious::Controller';
# Action
sub getfunc {
    
    my $self = shift;
   
    my $func_new = $self->param('new');
    my $func_del = $self->param('del');
    my $func_edit = $self->param('edit');
    my $func_update = $self->param('update');
    
    
    my $idID = $self->param('idID');
    my $speciesID = $self->param('speciesID');
    my $neuropeptideID = $self->param('neuropeptideID');
    my $isoID = $self->param('isoID');
    my $funcID = $self->param('funcID');
    my $FuncDescription = $self->param('FuncDescription');
    my $FuncURL = $self->param('FuncURL');

    my $speciesID_ed = $self->param('speciesID_ed');
    my $neuropeptideID_ed = $self->param('neuropeptideID_ed');
    my $isoID_ed = $self->param('isoID_ed');
    my $funcID_ed = $self->param('funcID_ed');
    my $FuncDescription_ed = $self->param('FuncDescription_ed');
    my $FuncURL_ed = $self->param('FuncURL_ed');

    my $message_to_page=0; my $sth2; my $func_edit_array;
    
    my $dbh = $self->app->dbh;
    
    if(defined $func_edit){
        my $query2 = '
        SELECT DISTINCT FuncInfo.idID, FuncInfo.speciesID, FuncInfo.neuropeptideID, FuncInfo.isoID, FuncInfo.funcID, FuncInfo.FuncDescription,FuncInfo.FuncURL
        FROM FuncInfo
        WHERE FuncInfo.idID = ? ';
        
        my $sth2 = $dbh->prepare($query2);
        $sth2->execute($idID);
        
        $func_edit_array = $sth2->fetchall_arrayref;
        
        $message_to_page = 3;

    }
    
     if(defined $func_update){
        my $query3 = '
            UPDATE FuncInfo SET
            FuncInfo.speciesID = ?,
            FuncInfo.neuropeptideID = ?,
            FuncInfo.isoID = ?,
            FuncInfo.funcID = ?,
            FuncInfo.FuncDescription = ?,
            FuncInfo.FuncURL = ?
            WHERE FuncInfo.idID = ? ';
        
         my $sth3 = $dbh->prepare($query3);
         $sth3->execute($speciesID_ed,$neuropeptideID_ed,$isoID_ed,$funcID_ed,$FuncDescription_ed,$FuncURL_ed,$idID);
        
         $message_to_page = 4;
       
    }
    
    if(defined $func_del){
        my $query3 = '
        DELETE FROM FuncInfo WHERE idID = ? ';
        
        my $sth3 = $dbh->prepare($query3);
        $sth3->execute($idID);
        
        $message_to_page = 2;
    }
    
    if(defined $func_new){
        my $query4 = 'INSERT INTO FuncInfo (speciesID,neuropeptideID,isoID,funcID,FuncDescription,FuncURL) VALUES (?,?,?,?,?,?)';
        my $sth4 = $dbh->prepare($query4);
        $sth4->execute($speciesID,$neuropeptideID,$isoID,$funcID,$FuncDescription,$FuncURL);
        
        $message_to_page = 1;
    }
    
    my $query = '
        SELECT DISTINCT SpeciesInfo.SpeciesName, NeuropeptideInfo.NeuropeptideName,NeuropeptideInfo.NeuropeptideDesc, NeuroPepIsoInfo.IsoformName,FuncCategories.FuncCategoryName, FuncInfo.FuncDescription, FuncInfo.FuncURL, FuncInfo.idID
        FROM NeuropeptideInfo, FuncCategories, FuncInfo , SpeciesInfo, NeuroPepIsoInfo
        WHERE FuncInfo.speciesID = SpeciesInfo.speciesID
        AND FuncInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
        AND FuncInfo.isoID = NeuroPepIsoInfo.isoID
        AND FuncInfo.funcID = FuncCategories.funcID
        ORDER BY NeuropeptideInfo.neuropeptideID, FuncCategories.FuncCategoryName';
    
    my $sth = $dbh->prepare($query);
    $sth->execute();
    
    $self->stash(
        func_info => $sth->fetchall_arrayref,
        func_edit_array => $func_edit_array,
        message_to_page => $message_to_page
    );
    
    $self->render('/datamgmt/get_func');
}
1;