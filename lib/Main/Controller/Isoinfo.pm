# Controller
package Main::Controller::Isoinfo;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
# Action
sub getisoinfo {
    
    my $self = shift;
   
    my $iso_info_new = $self->param('new');
    my $iso_info_del = $self->param('del');
    my $iso_info_edit = $self->param('edit');
    my $iso_info_update = $self->param('update');
    
    
    my $isoID = $self->param('isoID');
    my $speciesID = $self->param('speciesID');
    my $neuropeptideID = $self->param('neuropeptideID');
    my $IsoformName = $self->param('IsoformName');
    my $IsoformAASeq = $self->param('IsoformAASeq');
    my $Isoform_p_end = $self->param('Isoform_p_end');
    my $Isoform_a_end = $self->param('Isoform_a_end');
    my $GenBankAscNum = $self->param('GenBankAscNum');
    my $GenBankAscNumURL = $self->param('GenBankAscNumURL');

    my $speciesID_ed = $self->param('speciesID_ed');
    my $neuropeptideID_ed = $self->param('neuropeptideID_ed');
    my $IsoformName_ed = $self->param('IsoformName_ed');
    my $IsoformAASeq_ed = $self->param('IsoformAASeq_ed');
    my $Isoform_p_end_ed = $self->param('Isoform_p_end_ed');
    my $Isoform_a_end_ed= $self->param('Isoform_a_end_ed');
    my $GenBankAscNum_ed = $self->param('GenBankAscNum_ed');
    my $GenBankAscNumURL_ed = $self->param('GenBankAscNumURL_ed');


    my $message_to_page=0; my $sth2; my $iso_info_edit_array;
    
    my $dbh = $self->app->dbh;
    
    if(defined $iso_info_edit){
        my $query2 = '
        SELECT DISTINCT NeuroPepIsoInfo.isoID, NeuroPepIsoInfo.speciesID, NeuroPepIsoInfo.neuropeptideID, NeuroPepIsoInfo.IsoformName, NeuroPepIsoInfo.IsoformAASeq,NeuroPepIsoInfo.Isoform_p_end,NeuroPepIsoInfo.Isoform_a_end, NeuroPepIsoInfo.GenBankAscNum, NeuroPepIsoInfo.GenBankAscNumURL
        FROM NeuroPepIsoInfo
        WHERE NeuroPepIsoInfo.isoID = ? ';
        
        my $sth2 = $dbh->prepare($query2);
        $sth2->execute($isoID);
        
        $iso_info_edit_array = $sth2->fetchall_arrayref;
        
        $message_to_page = 3;

    }
    
     if(defined $iso_info_update){
        my $query3 = '
            UPDATE NeuroPepIsoInfo SET
            NeuroPepIsoInfo.speciesID = ?,
            NeuroPepIsoInfo.neuropeptideID = ?,
            NeuroPepIsoInfo.IsoformName = ?,
            NeuroPepIsoInfo.IsoformAASeq = ?,
            NeuroPepIsoInfo.Isoform_p_end = ?,
            NeuroPepIsoInfo.Isoform_a_end = ?,
            NeuroPepIsoInfo.GenBankAscNum = ?,
            NeuroPepIsoInfo.GenBankAscNumURL = ?
            WHERE NeuroPepIsoInfo.isoID = ? ';
        
         my $sth3 = $dbh->prepare($query3);
         $sth3->execute($speciesID_ed,$neuropeptideID_ed,$IsoformName_ed,$IsoformAASeq_ed,$Isoform_p_end_ed,$Isoform_a_end_ed,$GenBankAscNum_ed,$GenBankAscNumURL_ed,$isoID);
        
         $message_to_page = 4;
       
    }
    
    if(defined $iso_info_del){
        my $query3 = '
        DELETE FROM NeuroPepIsoInfo WHERE isoID = ? ';
        
        my $sth3 = $dbh->prepare($query3);
        $sth3->execute($isoID);
        
        $message_to_page = 2;
    }
    
    if(defined $iso_info_new){
        my $query4 = 'INSERT INTO NeuroPepIsoInfo (speciesID,neuropeptideID,IsoformName,IsoformAASeq,Isoform_p_end,Isoform_a_end,GenBankAscNum,GenBankAscNumURL) VALUES (?,?,?,?,?,?,?,?)';
        my $sth4 = $dbh->prepare($query4);
        $sth4->execute($speciesID,$neuropeptideID,$IsoformName,$IsoformAASeq,$Isoform_p_end,$Isoform_a_end,$GenBankAscNum,$GenBankAscNumURL);
        
        $message_to_page = 1;
    }
    
    my $query = '
        SELECT DISTINCT NeuroPepIsoInfo.isoID, NeuroPepIsoInfo.IsoformName, NeuroPepIsoInfo.IsoformAASeq, NeuroPepIsoInfo.Isoform_p_end, NeuroPepIsoInfo.Isoform_a_end, NeuropeptideInfo.NeuropeptideName, NeuropeptideInfo.NeuropeptideDesc, SpeciesInfo.SpeciesName, NeuroPepIsoInfo.GenBankAscNum, NeuroPepIsoInfo.GenBankAscNumURL, NeuropeptideInfo.neuropeptideID
        FROM NeuroPepIsoInfo, NeuropeptideInfo, SpeciesInfo
        WHERE NeuroPepIsoInfo.speciesID = SpeciesInfo.speciesID
        AND NeuroPepIsoInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
        ORDER BY SpeciesInfo.speciesID';
    
    my $sth = $dbh->prepare($query);
    $sth->execute();
    
    $self->stash(
    iso_info_info => $sth->fetchall_arrayref,
    iso_info_edit_array => $iso_info_edit_array,
    message_to_page => $message_to_page
    );
    
    $self->render('/datamgmt/get_iso_info');
}
1;