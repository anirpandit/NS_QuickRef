package Subs;

require Exporter;
  my @ISA = qw(Exporter);
  my @EXPORT_OK = qw(alertMessage);  # symbols to export on request
     
sub alertMessage {

    my ($message_to_page) = @_ ;   

    if($message_to_page == 3){
       $message_alert.=qq~<div class="alert alert-warning alert-fixed">~;
    }
    else{
        $message_alert.=qq~<div class="alert alert-success alert-fixed">~;
    }

    if($message_to_page == 1){
        $message_alert.=qq~<strong>Success!</strong> The record has been successfully created.~;
    }
    elsif($message_to_page == 2){
        $message_alert.=qq~<strong>Success!</strong> The record has been successfully deleted.~;
    }
    elsif($message_to_page == 3){
        $message_alert.=qq~<strong>Alert ! </strong> Please edit the record in the highlighted Edit Section.~;
    }
    elsif($message_to_page == 4){
        $message_alert.=qq~<strong>Success ! </strong> The record has been successfully updated.~;
    }

    $message_alert.=qq~<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>~.
                    qq~</div>~;

    return ($message_alert);
}

sub modaldelete{

    $modaldelete=qq~
        <div class="modal fade" id="confirm-delete" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
            
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title" id="myModalLabel">Confirm Deletion of Record</h4>
                </div>
            
                <div class="modal-body">
                    <p>You are about to delete one record, this process is irreversible.</p>
                    <p>Do you want to proceed?</p>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-default round" data-dismiss="modal">Cancel</button>
                    <a class="btn btn-danger btn-ok round">Delete</a>
                </div>
            </div>
        </div>
    </div>
    ~;

    return ($modaldelete);
}

sub get_npimagepath{
    use Config::Tiny;
    my $Config = Config::Tiny->new;
    
    $Config = Config::Tiny->read( 'config.ini' );
    
    my $npimagepath = $Config->{dev}->{NPIMAGE_PATH};
    
    return $npimagepath;
}
1;