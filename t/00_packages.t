use strict;

use Test::More;

foreach (qw/Mojolicious Mojolicious::Plugin::Model::DB Mojo::Pg
	    Regexp::Common::time /) {
  require_ok($_);
}

done_testing();


