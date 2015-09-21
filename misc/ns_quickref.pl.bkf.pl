#!/usr/bin/env perl

use Mojolicious::Lite;
use DBI;
use DBD::mysql;

use Data::Dumper;

use Mojo::Parameters;

app->config(hypnotoad => {listen => ['http://*:8080']});

# Create a database connection as an application attribute
app->attr(dbh => sub {
    my $self = shift;
    
    my $dbh = DBI->connect(
    'DBI:mysql:nSP_QuickRef:127.0.0.1:3306','root','spider'
    ) or die "Unable to connect: $DBI::errstr\n";
    
    return $dbh;
});

app->defaults(param=>undef);

#First instance#
get '/' => sub {
    my $self = shift;
    $self->render('home');
};

#All other instances when clicking
get '/home' => sub {
    my $self = shift;
    $self->render('home');
};

any '/fasta' => sub {
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

    $self->render('fasta');
};

any '/imagesearch' => sub {
    my $self = shift;

    my $idID = $self->param('linktoimage');
    my $query = '
            SELECT DISTINCT NeuropeptideInfo.NeuropeptideName, SpeciesInfo.SpeciesName, FuncInfo.ImageTitle, FuncInfo.ImageLegend
            FROM FuncInfo, NeuropeptideInfo, SpeciesInfo
            WHERE
            FuncInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
            AND FuncInfo.speciesID = SpeciesInfo.speciesID  
            AND FuncInfo.idID = ?';

    my $dbh = $self->app->dbh;
    my $sth = $dbh->prepare($query);    
    $sth->execute($idID);

    $self->stash(
        imginfo => $sth->fetchall_arrayref
    );

    $self->render('imagesearch');
};


get '/infosearch' => sub {
    my $self = shift;
    $self->render('infosearch');
};

#Gene Search Form route#
get '/infosearchw' => sub {
    my $self = shift;

    my $species = $self->every_param('species');
    my $neuropeptide = $self->every_param('neuropeptide');
    my $functionality = $self->every_param('functionality');

    my (@species_array,@pep_array,@func_array);

    foreach my $a(@{$species}){
        push @species_array, $a;
    }

    my $species_list = join(',',@species_array);

    foreach my $b(@{$neuropeptide}){
        push @pep_array, $b;
    }
    
    my $neuropeptidelist = join(',',@pep_array);

        foreach my $c(@{$functionality}){
        push @func_array, $c;
    }

    my $functionality_list = join(',',@func_array);

    my $dbh = $self->app->dbh;
    
    #Info Search Form Queries#
    my $species_cond = "SELECT DISTINCT SpeciesInfo.speciesID FROM SpeciesInfo";
    
    if($species_array[0]){
        $species_cond = join( ',', map { '?' } @species_array );    
    }
    
    my $pep_cond = "SELECT neuropeptideID FROM NeuropeptideInfo";
    
    if($pep_array[0]){
        $pep_cond = join( ',', map { '?' } @pep_array );
        my $pep_string = join(',', @pep_array);
        if(!$species_array[0]){
            $species_cond = 'SELECT DISTINCT NeuroPepIsoInfo.speciesID FROM NeuroPepIsoInfo WHERE NeuroPepIsoInfo.neuropeptideID IN ('.$pep_string.')';
        }    
    }


    my $func_cond = "SELECT funcID FROM FuncCategories";   
    
    if($func_array[0]){
        $func_cond = join( ',', map { '?' } @func_array ); 
        my $func_string = join(',',@func_array);
        if(!$pep_array[0]){
            $pep_cond = 'SELECT DISTINCT FuncInfo.neuropeptideID FROM FuncInfo WHERE FuncInfo.funcID IN ('.$func_string.')';
        }  
        if(!$species_array[0]){
            $species_cond = 'SELECT DISTINCT FuncInfo.speciesID FROM FuncInfo WHERE FuncInfo.funcID IN ('.$func_string.')';
        }
    }

    my $query = '
        SELECT DISTINCT SpeciesInfo.SpeciesName, OrderInfo.OrderName, SpeciesInfo.CommonName, 
        SpeciesInfo.Importance, SpeciesInfo.GenomeSequence, SpeciesInfo.GenomeDatabase, SpeciesInfo.DatabaseURL, SpeciesInfo.SpeciesSource
        FROM SpeciesInfo, OrderInfo
        WHERE SpeciesInfo.orderID = OrderInfo.orderID
        AND (SpeciesInfo.speciesID IN (' . $species_cond. '))
        ORDER BY SpeciesInfo.speciesID';

    my $query2 = '
            SELECT DISTINCT NeuroPepIsoInfo.isoID, NeuroPepIsoInfo.IsoformName, NeuroPepIsoInfo.IsoformAASeq, NeuroPepIsoInfo.Isoform_p_end, NeuroPepIsoInfo.Isoform_a_end, NeuropeptideInfo.NeuropeptideName, SpeciesInfo.SpeciesName, NeuroPepIsoInfo.GenBankAscNum, NeuroPepIsoInfo.GenBankAscNumURL, NeuropeptideInfo.neuropeptideID
            FROM NeuroPepIsoInfo, NeuropeptideInfo, SpeciesInfo
            WHERE NeuroPepIsoInfo.speciesID = SpeciesInfo.speciesID
            AND NeuroPepIsoInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
            AND ( SpeciesInfo.speciesID IN (' . $species_cond. ') AND NeuropeptideInfo.neuropeptideID IN (' . $pep_cond . '))
            ORDER BY SpeciesInfo.speciesID';

    my $query3 = '
            SELECT DISTINCT SpeciesInfo.SpeciesName, NeuropeptideInfo.NeuropeptideName, NeuroPepGeneInfo.GenBankAscNum, NeuroPepGeneInfo.GenBankAscNumURL
            FROM NeuroPepGeneInfo, NeuropeptideInfo, SpeciesInfo
            WHERE NeuroPepGeneInfo.speciesID = SpeciesInfo.speciesID
            AND NeuroPepGeneInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
            AND ( SpeciesInfo.speciesID IN (' . $species_cond . ') AND NeuropeptideInfo.neuropeptideID IN (' . $pep_cond . '))
            ORDER BY SpeciesInfo.speciesID';

    my $query4 = '
            SELECT DISTINCT SpeciesInfo.SpeciesName, NeuropeptideInfo.NeuropeptideName, FuncCategories.FuncCategoryName, FuncInfo.FuncDescription, FuncInfo.FuncURL, FuncInfo.idID
            FROM NeuropeptideInfo, FuncCategories, FuncInfo , SpeciesInfo
            WHERE FuncInfo.speciesID = SpeciesInfo.speciesID
            AND FuncInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
            AND FuncInfo.funcID = FuncCategories.funcID
            AND ( SpeciesInfo.speciesID IN (' . $species_cond . ') AND NeuropeptideInfo.neuropeptideID IN (' . $pep_cond . ') AND FuncCategories.funcID IN (' . $func_cond . '))
            ORDER BY NeuropeptideInfo.neuropeptideID, FuncCategories.FuncCategoryName';



    my $sth = $dbh->prepare($query);    
    $sth->execute(@species_array);

    my $sth2 = $dbh->prepare($query2);  
    $sth2->execute(@species_array,@pep_array);

    my $sth3 = $dbh->prepare($query3);  
    $sth3->execute(@species_array,@pep_array);
    
    my $sth4 = $dbh->prepare($query4);    
    $sth4->execute(@species_array,@pep_array,@func_array,);
    
    $self->stash(
        species => $species_array[0],
        neuropeptide => $pep_array[0],
        functionality => $func_array[0],
        results => $sth->fetchall_arrayref,
        IsoformInfo => $sth2->fetchall_arrayref,
        GenBankInfo => $sth3->fetchall_arrayref,
        FuncCategories => $sth4->fetchall_arrayref
    );
    
    $self->render('infosearchw');
};


#Info Submit Form route#
any '/infosubmit' => sub {
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
};


any '/get_func_cat' => sub {

    my $self = shift;

    my $func_cat_new = $self->param('new');
    my $func_cat_del = $self->param('del');
    my $func_cat_edit = $self->param('edit');
    my $func_cat_update = $self->param('update');


    my $funcID = $self->param('funcID');
    my $FuncCategoryName = $self->param('FuncCategoryName');

    my $message_to_page=0; my $sth2; my $func_cat_edit_array;

    my $dbh = $self->app->dbh;

    if(defined $func_cat_edit){
        my $query2 = '
            SELECT DISTINCT FuncCategories.funcID, FuncCategories.FuncCategoryName
            FROM FuncCategories
            WHERE FuncCategories.funcID = ? ';

        my $sth2 = $dbh->prepare($query2);    
        $sth2->execute($funcID);
            
        $func_cat_edit_array = $sth2->fetchall_arrayref;

        $message_to_page = 3;

    }

    if(defined $func_cat_update){
        my $query3 = '
           UPDATE FuncCategories SET 
           FuncCategories.FuncCategoryName = ?
           WHERE FuncCategories.funcID = ? ';

        my $sth3 = $dbh->prepare($query3);    
        $sth3->execute($FuncCategoryName,$funcID);
            
        $message_to_page = 4;

    }

    if(defined $func_cat_del){
        my $query3 = '
            DELETE FROM FuncCategories WHERE funcID = ? ';

        
        my $sth3 = $dbh->prepare($query3);    
        $sth3->execute($funcID);

        $message_to_page = 2;
    }

    if(defined $func_cat_new){
        my $query4 = 'INSERT INTO FuncCategories (FuncCategoryName) VALUES (?)';

        my $sth4 = $dbh->prepare($query4);    
        $sth4->execute($FuncCategoryName);

        $message_to_page = 1;
    }

    my $query = '
        SELECT DISTINCT FuncCategories.funcID, FuncCategories.FuncCategoryName
        FROM FuncCategories' ;

    my $sth = $dbh->prepare($query);    
    $sth->execute();


    $self->stash(
        func_cat_info => $sth->fetchall_arrayref,
        func_cat_edit_array => $func_cat_edit_array,
        message_to_page => $message_to_page
    );

    $self->render('get_func_cat');
};

app->start;

