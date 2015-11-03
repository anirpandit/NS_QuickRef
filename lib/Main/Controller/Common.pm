# Controller
package Main::Controller::Common;
use Mojo::Base 'Mojolicious::Controller';

# Action
sub fasta {
    
    my $self = shift;
    
    my $isoID = $self->param('isoID');
    my $neuropeptideID = $self->param('neuropeptideID');
    my ($useme,$query);
    
    if($isoID){
        $query = '
        SELECT DISTINCT NeuroPepIsoInfo.IsoformName, NeuroPepIsoInfo.IsoformAASeq
        FROM NeuroPepIsoInfo
        WHERE NeuroPepIsoInfo.isoID = ?';
        $useme = $isoID;
    }
    
    else{
        $query = '
        SELECT DISTINCT NeuroPepIsoInfo.IsoformName, NeuroPepIsoInfo.IsoformAASeq
        FROM NeuroPepIsoInfo
        WHERE NeuroPepIsoInfo.neuropeptideID = ?';
        $useme = $neuropeptideID;
    }
    
    
    my $dbh = $self->app->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($useme);
    
    $self->stash(
    seqinfo => $sth->fetchall_arrayref
    );
    
    $self->render('/nsp_quickref/fasta');
    
}

sub imagesearch{
    my $self = shift;
    
    my $idID = $self->param('linktoimage');
    my $query = '
    SELECT DISTINCT NeuropeptideInfo.NeuropeptideName, SpeciesInfo.SpeciesName, ImageInfo.ImageTitle, ImageInfo.ImageLegend, ImageInfo.ImageReference, ImageInfo.ImageReferenceURL
    FROM ImageInfo, NeuropeptideInfo, SpeciesInfo
    WHERE
    ImageInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
    AND ImageInfo.speciesID = SpeciesInfo.speciesID
    AND ImageInfo.imageID = ?';
    
    my $dbh = $self->app->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($idID);
    
    $self->stash(
    imginfo => $sth->fetchall_arrayref
    );
    
    $self->render('/nsp_quickref/imagesearch');
}

sub check{
    my $self = shift;
    
    my $dbh = $self->app->dbh;
    
    my $IsoformNamecheck = $self->param('IsoformName');
    
    my $query3 = "SELECT IsoformName FROM NeuroPepIsoInfo WHERE IsoformName = ? ";
    my $sth5 = $dbh->prepare($query3);
       $sth5->execute($IsoformNamecheck);
    
    $self->stash(
        data => $sth5->rows
    );
    
    $self->render('/datamgmt/check');
    
}
1;