#!/usr/bin/env perl

use Mojolicious::Lite;
use DBI;
use DBD::mysql;


#First instance#
get '/' => sub {
    my $self = shift;
    $self->render('home');
};

#All other instances when clicking "FlyAtlas"#
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
    my @functionality = $self->param('functionality');

   
    #Info Search Form Queries#

    # my $cond1 = "SpeciesInfo.speciesID = ? ";
            
    # my $query = '
    #         SELECT DISTINCT SpeciesInfo.SpeciesName, OrderInfo.OrderName, SpeciesInfo.CommonName, 
    #         SpeciesInfo.Importance, SpeciesInfo.GenomeSequence, SpeciesInfo.GenomeDatabase, SpeciesInfo.DatabaseURL, SpeciesInfo.SpeciesSource
    #         FROM SpeciesInfo, OrderInfo
    #         WHERE SpeciesInfo.orderID = OrderInfo.orderID
    #         AND ('.$cond1.')
    #         ORDER BY SpeciesInfo.speciesID';
   
    # my $query2 = '
    #         SELECT DISTINCT SpeciesInfo.SpeciesName, NeuropeptideInfo.NeuropeptideName, FuncCategories.FuncCategoryName, FuncInfo.FuncDescription, FuncInfo.FuncURL
    #         FROM NeuropeptideInfo, FuncCategories, FuncInfo , SpeciesInfo
    #         WHERE FuncInfo.speciesID = SpeciesInfo.speciesID
    #         AND FuncInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
    #         AND FuncInfo.funcID = FuncCategories.funcID
    #         AND ( '.$cond1.'AND NeuropeptideInfo.neuropeptideID = ?)ORDER BY NeuropeptideInfo.neuropeptideID, FuncCategories.FuncCategoryName';


    # my $query3 = '
    #         SELECT DISTINCT SpeciesInfo.SpeciesName, NeuropeptideInfo.NeuropeptideName, NeuroPepGeneInfo.GenBankAscNum, NeuroPepGeneInfo.GenBankAscNumURL
    #         FROM NeuroPepGeneInfo, NeuropeptideInfo, SpeciesInfo
    #         WHERE NeuroPepGeneInfo.speciesID = SpeciesInfo.speciesID
    #         AND NeuroPepGeneInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
    #         AND ( '.$cond1.'AND NeuropeptideInfo.neuropeptideID = ?)ORDER BY NeuropeptideInfo.neuropeptideID';



my $query = '
    SELECT DISTINCT 
    SpeciesInfo.SpeciesName, OrderInfo.OrderName, SpeciesInfo.CommonName, SpeciesInfo.Importance, SpeciesInfo.GenomeSequence, SpeciesInfo.GenomeDatabase, SpeciesInfo.DatabaseURL, SpeciesInfo.SpeciesSource,
    NeuropeptideInfo.NeuropeptideName, 
    NeuroPepGeneInfo.GenBankAscNum, NeuroPepGeneInfo.GenBankAscNumURL
    FuncCategories.FuncCategoryName, 
    FuncInfo.FuncDescription, FuncInfo.FuncURL
    FROM SpeciesInfo, OrderInfo, NeuropeptideInfo, FuncCategories, FuncInfo, NeuroPepGeneInfo
    WHERE SpeciesInfo.orderID = OrderInfo.orderID
    AND FuncInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
    AND FuncInfo.funcID = FuncCategories.funcID
    AND NeuroPepGeneInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
    AND (SpeciesInfo.speciesID = ? AND NeuropeptideInfo.neuropeptideID = ? AND FuncCategories.funcID IN (?))

';
    my $dbh = $self->app->dbh;

    my $sth = $dbh->prepare($query);    
    $sth->execute($species);

    #my $sth2 = $dbh->prepare($query2);    
    #$sth2->execute($species,$neuropeptide);

    #my $sth3 = $dbh->prepare($query3);    
    #$sth3->execute($species,$neuropeptide);
    
    $self->stash(
        #species => $species,
        results => $sth->fetchall_arrayref,
        #FuncCategories => $sth2->fetchall_arrayref,
        #GenBankInfo => $sth3->fetchall_arrayref
    );
    
    $self->render('infosearch');
};



app->start;

