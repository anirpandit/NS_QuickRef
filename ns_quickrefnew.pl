#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

use lib 'lib' ;

# Start command line interface for application
require Mojolicious::Commands;
Mojolicious::Commands->start_app('Main');
