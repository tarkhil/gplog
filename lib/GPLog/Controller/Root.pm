package GPLog::Controller::Root;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use YAML;

sub index($self) {
  if ( my $address = $self->param('address') ) {
    $self->stash( count => $self->app->db('log')->count_combined( $address ) );
    $self->stash( results => $self->app->db('log')->select_combined( $address ) );
    warn Dump $self->app->db('log')->select_combined( $address );
  } else {
    $self->stash( results => undef );
    $self->stash( count => 0 );
  }
}

1;
