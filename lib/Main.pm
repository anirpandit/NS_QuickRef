package Main;
use Mojo::Base 'Mojolicious';

use DBI;
use DBD::mysql;

sub startup {
	my $self = shift;

    (ref $self)->attr(
        dbh => sub {
            DBI->connect(
    		'DBI:mysql:nSP_QuickRef:127.0.0.1:3306','root','spider'
    		);
        }
    );

	#For Hypnotoad, config file call#
	my $config = $self->plugin('Config');

	#For Routes#
	my $r = $self->routes;


	#Routes to Controllers#

	#Home#
	$r -> get('/home') -> to(controller => 'home', action => 'gohome');	

	#Information Search#
	$r -> get('/infosearch') -> to(controller => 'infosearch', action => 'infosearch');	
	$r -> get('/infosearchw') -> to(controller => 'infosearch', action => 'infosearchw');	

	#Additional modules to Information Search#
	$r -> get('/fasta') -> to(controller => 'infosearch', action => 'fasta');	
	$r -> get('/imagesearch') -> to(controller => 'infosearch', action => 'imagesearch');	


	#Data Management Subsections#
    $r -> any([qw(GET POST)] => '/get_iso_info')->to(controller => 'isoinfo', action => 'getisoinfo');
    $r -> any([qw(GET POST)] => '/get_gbank')->to(controller => 'gbank', action => 'getgbank');
    $r -> any([qw(GET POST)] => '/get_npep')->to(controller => 'npep', action => 'getnpep');
    $r -> any([qw(GET POST)] => '/get_order')->to(controller => 'order', action => 'getorder');
	$r -> any([qw(GET POST)] => '/get_func_cat')->to(controller => 'funccat', action => 'getfunccat');
	




# #Info Submit Form route#
$r-> any ('/infosubmit' => sub {
     my $self = shift;
     my $dbh = $self->app->dbh;

     my $subsuccess = "";
    
     my $NeuropeptideName = $self->param('NeuropeptideName');
     my $NeuropeptideInfo = $self->param('NeuropeptideInfo');
    
     if($NeuropeptideName){
         my $query = 'INSERT INTO NeuropeptideInfo (NeuropeptideName,NeuropeptideInfo) VALUES (?,?)';

         my $sth = $dbh->prepare($query);    
         $sth->execute($NeuropeptideName,$NeuropeptideInfo);

         $subsuccess = "Success";
     }

     my $OrderName = $self->param('OrderName');

     if($OrderName){
             my $query = 'INSERT INTO OrderInfo (OrderName) VALUES (?)';

             my $sth = $dbh->prepare($query);    
             $sth->execute($OrderName);
             $subsuccess = "Success";
     }    


     my $SpeciesName = $self->param('SpeciesName');
     my $orderID = $self->param('orderID');
     my $CommonName = $self->param('CommonName');
     my $Importance = $self->param('Importance');
     my $GenomeSequence = $self->param('GenomeSequence');
     my $GenomeDatabase = $self->param('GenomeDatabase');
     my $DatabaseURL = $self->param('DatabaseURL');
     my $SpeciesSource = $self->param('SpeciesSource');

     if($SpeciesName){

         my $query = 'INSERT INTO SpeciesInfo (orderID,SpeciesName,CommonName,Importance,GenomeSequence,GenomeDatabase,DatabaseURL,SpeciesSource) VALUES (?,?,?,?,?,?,?,?)';

         my $sth = $dbh->prepare($query);    
         $sth->execute($orderID,$SpeciesName,$CommonName,$Importance,$GenomeSequence,$GenomeDatabase,$DatabaseURL,$SpeciesSource);
         $subsuccess = "Success";

     }

     my $speciesID = $self->param('speciesID');
     my $neuropeptideID = $self->param('neuropeptideID');
     my $funcID = $self->param('funcID');
     my $FuncDescription = $self->param('FuncDescription');
     my $FuncURL = $self->param('FuncURL');
     my $ImageTitle = $self->param('ImageTitle');
     my $ImageLegend = $self->param('ImageLegend');
     my $ImageUpload = $self->req->upload('ImageUpload');

     my $filename = '';
     if($ImageUpload){
         my $fileName = $ImageUpload->filename =~ s/[^\w\d\.]+/_/gr;    
         $ImageUpload->move_to("/Users/Blackbelly/Sites/NS_QuickRef/public/npimages/$fileName");
     }

    
     if($FuncDescription){

         my $query = 'INSERT INTO FuncInfo (speciesID,neuropeptideID,funcID,FuncDescription,FuncURL,ImageTitle,ImageLegend) VALUES (?,?,?,?,?,?,?)';

         my $sth = $dbh->prepare($query);    
         $sth->execute($speciesID,$neuropeptideID,$funcID,$FuncDescription,$FuncURL,$ImageTitle,$ImageLegend);
         $subsuccess = "Success";

     }

     my $speciesID_gb = $self->param('speciesID_gb');
     my $neuropeptideID_gb = $self->param('neuropeptideID_gb');
     my $GenBankAscNum = $self->param('GenBankAscNum');
     my $GenBankAscNumURL = $self->param('GenBankAscNumURL');
    
     if($GenBankAscNum){

         my $query = 'INSERT INTO NeuroPepGeneInfo (speciesID,neuropeptideID,GenBankAscNum,GenBankAscNumURL) VALUES (?,?,?,?)';

         my $sth = $dbh->prepare($query);    
         $sth->execute($speciesID_gb,$neuropeptideID_gb,$GenBankAscNum,$GenBankAscNumURL);
         $subsuccess = "Success";

     }

     my $speciesID_iso = $self->param('speciesID_iso');
     my $neuropeptideID_iso = $self->param('neuropeptideID_iso');
     my $IsoformName = $self->param('IsoformName');
     my $IsoformAASeq = $self->param('IsoformAASeq');
     my $Isoform_p_end = $self->param('Isoform_p_end');
     my $Isoform_a_end = $self->param('Isoform_a_end');
     my $GenBankAscNum_iso = $self->param('GenBankAscNum_iso');
     my $GenBankAscNumURL_iso = $self->param('GenBankAscNumURL_iso');
    
     if($IsoformName){

         my $query = 'INSERT INTO NeuroPepIsoInfo (speciesID,neuropeptideID,IsoformName,IsoformAASeq,Isoform_p_end,Isoform_a_end,GenBankAscNum,GenBankAscNumURL) VALUES (?,?,?,?,?,?,?,?)';

         my $sth = $dbh->prepare($query);    
         $sth->execute($speciesID_iso,$neuropeptideID_iso,$IsoformName,$IsoformAASeq,$Isoform_p_end,$Isoform_a_end,$GenBankAscNum_iso,$GenBankAscNumURL_iso);
         $subsuccess = "Success";

     }

     $self->stash(
         submitteddetails => $subsuccess
     );

     $self->render('infosubmit');
} => 'infosubmit');



}

1;