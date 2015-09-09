# Controller
package Main::Controller::Order;
use Mojo::Base 'Mojolicious::Controller';

# Action
sub getorder {
    
    my $self = shift;
    
    my $order_new = $self->param('new');
    my $order_del = $self->param('del');
    my $order_edit = $self->param('edit');
    my $order_update = $self->param('update');
    
    
    my $orderID = $self->param('orderID');
    my $OrderName = $self->param('OrderName');
    
    my $message_to_page=0; my $sth2; my $order_edit_array;
    
    my $dbh = $self->app->dbh;
    
    if(defined $order_edit){
        my $query2 = '
        SELECT DISTINCT OrderInfo.orderID, OrderInfo.OrderName
        FROM OrderInfo
        WHERE OrderInfo.orderID = ? ';
        
        my $sth2 = $dbh->prepare($query2);
        $sth2->execute($orderID);
        
        $order_edit_array = $sth2->fetchall_arrayref;
        
        $message_to_page = 3;
        
    }
    
    if(defined $order_update){
        my $query3 = '
        UPDATE OrderInfo SET
        OrderInfo.OrderName = ?
        WHERE OrderInfo.orderID = ? ';
        
        my $sth3 = $dbh->prepare($query3);
        $sth3->execute($OrderName,$orderID);
        
        $message_to_page = 4;
        
    }
    
    if(defined $order_del){
        my $query3 = '
        DELETE FROM OrderInfo WHERE orderID = ? ';
        
        my $sth3 = $dbh->prepare($query3);
        $sth3->execute($orderID);
        
        $message_to_page = 2;
    }
    
    if(defined $order_new){
        my $query4 = 'INSERT INTO OrderInfo (OrderName) VALUES (?)';
        my $sth4 = $dbh->prepare($query4);
        $sth4->execute($OrderName);
        
        $message_to_page = 1;
    }
    
    my $query = '
    SELECT DISTINCT OrderInfo.orderID, OrderInfo.OrderName
    FROM OrderInfo' ;
    
    my $sth = $dbh->prepare($query);
    $sth->execute();
    
    $self->stash(
    order_info => $sth->fetchall_arrayref,
    order_edit_array => $order_edit_array,
    message_to_page => $message_to_page
    );
    
    $self->render('/datamgmt/get_order');
}
1;