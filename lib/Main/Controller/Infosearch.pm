# Controller
package Main::Controller::Infosearch;
use Mojo::Base 'Mojolicious::Controller';

# Action
sub infosearch {
     my $self = shift;
     $self->render('/search/infosearch');
}

sub infosearchw {

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
        SELECT DISTINCT NeuroPepIsoInfo.isoID, NeuroPepIsoInfo.IsoformName, NeuroPepIsoInfo.IsoformAASeq, NeuroPepIsoInfo.Isoform_p_end, NeuroPepIsoInfo.Isoform_a_end, NeuropeptideInfo.NeuropeptideName, SpeciesInfo.SpeciesName, NeuroPepIsoInfo.GenBankAscNum, NeuroPepIsoInfo.GenBankAscNumURL, NeuropeptideInfo.neuropeptideID, NeuropeptideInfo.NeuropeptideDesc
        FROM NeuroPepIsoInfo, NeuropeptideInfo, SpeciesInfo
        WHERE NeuroPepIsoInfo.speciesID = SpeciesInfo.speciesID
        AND NeuroPepIsoInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
        AND ( SpeciesInfo.speciesID IN (' . $species_cond. ') AND NeuropeptideInfo.neuropeptideID IN (' . $pep_cond . '))
        ORDER BY SpeciesInfo.speciesID';

    my $query3 = '
        SELECT DISTINCT SpeciesInfo.SpeciesName, NeuropeptideInfo.NeuropeptideName, FuncCategories.FuncCategoryName, FuncInfo.FuncDescription, FuncInfo.FuncURL, FuncInfo.idID
        FROM NeuropeptideInfo, FuncCategories, FuncInfo , SpeciesInfo
        WHERE FuncInfo.speciesID = SpeciesInfo.speciesID
        AND FuncInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
        AND FuncInfo.funcID = FuncCategories.funcID
        AND ( SpeciesInfo.speciesID IN (' . $species_cond . ') AND NeuropeptideInfo.neuropeptideID IN (' . $pep_cond . ') AND FuncCategories.funcID IN (' . $func_cond . '))
        ORDER BY NeuropeptideInfo.neuropeptideID, FuncCategories.FuncCategoryName';

    my $query4 = '
        SELECT DISTINCT SpeciesInfo.SpeciesName, NeuropeptideInfo.NeuropeptideName, FuncCategories.FuncCategoryName, ImageInfo.ImageTitle, ImageInfo.ImageLegend, ImageInfo.imageID
        FROM NeuropeptideInfo, FuncCategories, ImageInfo , SpeciesInfo
        WHERE ImageInfo.speciesID = SpeciesInfo.speciesID
        AND ImageInfo.neuropeptideID = NeuropeptideInfo.neuropeptideID
        AND ImageInfo.funcID = FuncCategories.funcID
        AND ( SpeciesInfo.speciesID IN (' . $species_cond . ') AND NeuropeptideInfo.neuropeptideID IN (' . $pep_cond . ') AND FuncCategories.funcID IN (' . $func_cond . '))';

    my $sth = $dbh->prepare($query);    
    $sth->execute(@species_array);

    my $sth2 = $dbh->prepare($query2);  
    $sth2->execute(@species_array,@pep_array);

    my $sth3 = $dbh->prepare($query3);    
    $sth3>execute(@species_array,@pep_array,@func_array,);

    my $sth4 = $dbh->prepare($query4);    
    $sth4->execute(@species_array,@pep_array,@func_array,);
    
    $self->stash(
        species => $species_array[0],
        neuropeptide => $pep_array[0],
        functionality => $func_array[0],
        results => $sth->fetchall_arrayref,
        IsoformInfo => $sth2->fetchall_arrayref,
        FuncCategories => $sth3->fetchall_arrayref,
        ImageResults => $sth4->fetchall_arrayref
    );
    
    $self->render('/search/infosearchw');

}

1;