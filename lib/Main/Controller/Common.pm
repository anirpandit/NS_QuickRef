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
    
    $self->render('/search/fasta');
    
}

sub imagesearch{
    my $self = shift;
    
    my $idID = $self->param('linktoimage');
    my $query = '
    SELECT DISTINCT NeuropeptideInfo.NeuropeptideName, SpeciesInfo.SpeciesName, ImageInfo.ImageTitle, ImageInfo.ImageLegend
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
    
    $self->render('/search/imagesearch');
}
1;