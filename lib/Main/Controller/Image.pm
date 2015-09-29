#Controller
package Main::Controller::Image;
use Mojo::Base 'Mojolicious::Controller';


# Action
sub getimage {
    
    use Subs qw(get_npimagepath);
    
    my $self = shift;
   
    my $image_new = $self->param('new');
    my $image_del = $self->param('del');
    my $image_edit = $self->param('edit');
    my $image_update = $self->param('update');
    
    
    my $imageID = $self->param('imageID');
    my $speciesID = $self->param('speciesID');
    my $neuropeptideID = $self->param('neuropeptideID');
    my $funcID = $self->param('funcID');
    my $ImageTitle = $self->param('ImageTitle');
    my $ImageLegend = $self->param('ImageLegend');
    my $ImageUpload = $self->req->upload('ImageUpload');

    my $speciesID_ed = $self->param('speciesID_ed');
    my $neuropeptideID_ed = $self->param('neuropeptideID_ed');
    my $funcID_ed = $self->param('funcID_ed');
    my $ImageTitle_ed = $self->param('ImageTitle_ed');
    my $ImageLegend_ed = $self->param('ImageLegend_ed');


    my $message_to_page=0; my $sth2; my $image_edit_array;

    my $npimagepath = Subs::get_npimagepath();
    
  
    my $dbh = $self->app->dbh;
    
    if(defined $image_edit){

        if($image_edit == 2){
            unlink($npimagepath.$ImageTitle);
        }

        my $query2 = '
        SELECT DISTINCT ImageInfo.imageID, ImageInfo.speciesID, ImageInfo.neuropeptideID, ImageInfo.funcID, ImageInfo.ImageTitle, ImageInfo.ImageLegend
        FROM ImageInfo
        WHERE ImageInfo.imageID = ? ';
    
        my $sth2 = $dbh->prepare($query2);
        $sth2->execute($imageID);
    
        $image_edit_array = $sth2->fetchall_arrayref;
    
        $message_to_page = 3;


    }
    
     if(defined $image_update){

        ($ImageUpload)?$ImageTitle_ed=imageupload($ImageUpload):$ImageTitle_ed;

        my $query3 = '
            UPDATE ImageInfo SET
            ImageInfo.speciesID = ?,
            ImageInfo.neuropeptideID = ?,
            ImageInfo.funcID = ?,
            ImageInfo.ImageTitle = ?,
            ImageInfo.ImageLegend = ?
            WHERE ImageInfo.imageID = ? ';
        
         my $sth3 = $dbh->prepare($query3);
         $sth3->execute($speciesID_ed,$neuropeptideID_ed,$funcID_ed,$ImageTitle_ed,$ImageLegend_ed,$imageID);

        
        
         $message_to_page = 4;
       
    }
    
    if(defined $image_del){
        my $query3 = '
        DELETE FROM ImageInfo WHERE imageID = ? ';
        
        my $sth3 = $dbh->prepare($query3);
        $sth3->execute($imageID);
        
        $message_to_page = 2;

         unlink($npimagepath.$ImageTitle);
    }
    
    if(defined $image_new){
        ($ImageUpload)?$ImageTitle=imageupload($ImageUpload):'';

        my $query4 = 'INSERT INTO ImageInfo (speciesID,neuropeptideID,funcID,ImageTitle,ImageLegend) VALUES (?,?,?,?,?)';
        my $sth4 = $dbh->prepare($query4);
        $sth4->execute($speciesID,$neuropeptideID,$funcID,$ImageTitle,$ImageLegend);

        $message_to_page = 1;
    }
    
    my $query = '
        SELECT DISTINCT SpeciesInfo.SpeciesName, NeuropeptideInfo.NeuropeptideName, NeuropeptideInfo.NeuropeptideDesc, FuncCategories.FuncCategoryName, ImageInfo.ImageTitle, ImageInfo.ImageLegend, ImageInfo.imageID
        FROM NeuropeptideInfo, FuncCategories, ImageInfo , SpeciesInfo
        WHERE ImageInfo.speciesID = SpeciesInfo.speciesID
        AND ImageInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
        AND ImageInfo.funcID = FuncCategories.funcID
        ORDER BY NeuropeptideInfo.neuropeptideID, FuncCategories.FuncCategoryName';
    
    my $sth = $dbh->prepare($query);
    $sth->execute();
    
    $self->stash(
    image_info => $sth->fetchall_arrayref,
    image_edit_array => $image_edit_array,
    message_to_page => $message_to_page
    );
    
    $self->render('/datamgmt/get_image');
}

sub imageupload{
    
    my ($ImageUpload) = @_;
    my $fileName = $ImageUpload->filename =~ s/[^\w\d\-.]+//gr; 

    my $npimagepath=Subs::get_npimagepath();
    $ImageUpload->move_to($npimagepath.$fileName);  

    return $fileName; 
}
1;