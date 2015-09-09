# Controller
package Main::Controller::Funccat;
use Mojo::Base 'Mojolicious::Controller';

# Action
sub getfunccat {
    
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
    
    $self->render('/datamgmt/get_func_cat');
}
1;