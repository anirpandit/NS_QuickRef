package Subs;

use Data::Dumper;

require Exporter;
  my @ISA = qw(Exporter);
  my @EXPORT_OK = qw(alertMessage);  # symbols to export on request
     
sub alertMessage {

        my ($message_to_page) = @_ ;   print Dumper($message_to_page);     

         my $message_alert.=qq~<div class="container">~;

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
1;