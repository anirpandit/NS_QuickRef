use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'ns_quickrefnew.pl',
  VERSION      => '1.0',
  AUTHOR       => 'Magnus Holm <judofyr@gmail.com>',
  EXE_FILES    => ['ns_quickrefnew.pl'],
  PREREQ_PM    => {'Mojolicious' => '2.0'},
  test         => {TESTS => 't/*.t'}
);
