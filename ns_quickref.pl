#!/usr/bin/env perl

use Mojolicious::Lite;
use DBI;
use DBD::mysql;

use Mojo::Parameters;


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



# Create a database connection as an application attribute
app->attr(dbh => sub {
    my $self = shift;
    
    my $dbh = DBI->connect(
    'DBI:mysql:NS_QuickRef:127.0.0.1:3306','root','spider'
    ) or die "Unable to connect: $DBI::errstr\n";
    
    return $dbh;
});

#Gene Search Form route#
get '/infosearch' => sub {
    my $self = shift;
    my $species = $self->param('species');
    my $neuropeptide = $self->param('neuropeptide');
    my $functionality = $self->param('functionality');
    
    #Info Search Form Queries#

    my ($cond1, $cond2, $cond3);

    $cond1 = "SpeciesInfo.speciesID = ? ";
    $cond2 = "NeuropeptideInfo.neuropeptideID = ? ";

    if($functionality ne "All"){
        $cond3 = "AND FuncCategories.funcID = ?";
    }
    
    my $query = '
            SELECT DISTINCT SpeciesInfo.SpeciesName, OrderInfo.OrderName, SpeciesInfo.CommonName, 
            SpeciesInfo.Importance, SpeciesInfo.GenomeSequence, SpeciesInfo.GenomeDatabase, SpeciesInfo.DatabaseURL, SpeciesInfo.SpeciesSource
            FROM SpeciesInfo, OrderInfo
            WHERE SpeciesInfo.orderID = OrderInfo.orderID
            AND ('.$cond1.')
            ORDER BY SpeciesInfo.speciesID';
   
    my $query2 = '
            SELECT DISTINCT SpeciesInfo.SpeciesName, NeuropeptideInfo.NeuropeptideName, FuncCategories.FuncCategoryName, FuncInfo.FuncDescription, FuncInfo.FuncURL
            FROM NeuropeptideInfo, FuncCategories, FuncInfo , SpeciesInfo
            WHERE FuncInfo.speciesID = SpeciesInfo.speciesID
            AND FuncInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
            AND FuncInfo.funcID = FuncCategories.funcID
            AND ( '.$cond1.'AND '.$cond2.$cond3.')ORDER BY NeuropeptideInfo.neuropeptideID, FuncCategories.FuncCategoryName';


    my $query3 = '
            SELECT DISTINCT SpeciesInfo.SpeciesName, NeuropeptideInfo.NeuropeptideName, NeuroPepGeneInfo.GenBankAscNum, NeuroPepGeneInfo.GenBankAscNumURL
            FROM NeuroPepGeneInfo, NeuropeptideInfo, SpeciesInfo
            WHERE NeuroPepGeneInfo.speciesID = SpeciesInfo.speciesID
            AND NeuroPepGeneInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
            AND ( '.$cond1.'AND NeuropeptideInfo.neuropeptideID = ?)ORDER BY NeuropeptideInfo.neuropeptideID';


    my $dbh = $self->app->dbh;

    my $sth = $dbh->prepare($query);    
    $sth->execute($species);

    my $sth2 = $dbh->prepare($query2);  
    if($functionality ne "All"){  
        $sth2->execute($species,$neuropeptide,$functionality);
    }
    else{
        $sth2->execute($species,$neuropeptide);
    }
    my $sth3 = $dbh->prepare($query3);    
    $sth3->execute($species,$neuropeptide);
    
    $self->stash(
        species => $species,
        results => $sth->fetchall_arrayref,
        FuncCategories => $sth2->fetchall_arrayref,
        GenBankInfo => $sth3->fetchall_arrayref
    );
    
    $self->render('infosearch');
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


    my $FuncCategoryName = $self->param('FuncCategoryName');

    if($FuncCategoryName){
        my $query = 'INSERT INTO FuncCategories (FuncCategoryName) VALUES (?)';

        my $sth = $dbh->prepare($query);    
        $sth->execute($FuncCategoryName);
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

    if($FuncDescription){

        my $query = 'INSERT INTO FuncInfo (speciesID,neuropeptideID,funcID,FuncDescription,FuncURL) VALUES (?,?,?,?,?)';

        my $sth = $dbh->prepare($query);    
        $sth->execute($speciesID,$neuropeptideID,$funcID,$FuncDescription,$FuncURL);
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

    $self->stash(
        submitteddetails => $subsuccess
    );

    $self->render('infosubmit');
};

app->start;

