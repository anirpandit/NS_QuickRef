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
	$r -> get('/home') -> to(controller => 'sitepages', action => 'gohome');
   	$r -> get('/project/about') -> to(controller => 'sitepages', action => 'getabout');
    $r -> get('/project/board') -> to(controller => 'sitepages', action => 'getboard');
    $r -> get('/project/consortium') -> to(controller => 'sitepages', action => 'getconsortium');
    $r -> get('/contact') -> to(controller => 'sitepages', action => 'getcontact');

	#Information Search#
	$r -> get('/infosearch') -> to(controller => 'infosearch', action => 'infosearch');	
	$r -> get('/infosearchw') -> to(controller => 'infosearch', action => 'infosearchw');	

	#Additional modules to Information Search#
	$r -> get('/fasta') -> to(controller => 'common', action => 'fasta');
	$r -> get('/imagesearch') -> to(controller => 'common', action => 'imagesearch');


	#Data Management Subsections#
    $r -> any([qw(GET POST)] => '/get_species')->to(controller => 'species', action => 'getspecies');
    $r -> any([qw(GET POST)] => '/get_func')->to(controller => 'func', action => 'getfunc');
    $r -> any([qw(GET POST)] => '/get_image')->to(controller => 'image', action => 'getimage');
    $r -> any([qw(GET POST)] => '/get_iso_info')->to(controller => 'isoinfo', action => 'getisoinfo');
    $r -> any([qw(GET POST)] => '/get_gbank')->to(controller => 'gbank', action => 'getgbank');
    $r -> any([qw(GET POST)] => '/get_npep')->to(controller => 'npep', action => 'getnpep');
    $r -> any([qw(GET POST)] => '/get_order')->to(controller => 'order', action => 'getorder');
	$r -> any([qw(GET POST)] => '/get_func_cat')->to(controller => 'funccat', action => 'getfunccat');
	
}

1;