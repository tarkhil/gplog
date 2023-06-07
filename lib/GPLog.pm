package GPLog;
use Mojo::Base 'Mojolicious', -signatures;

sub startup ($self) {
  push @{$self->plugins->namespaces},  __PACKAGE__.'::Plugin';
  push @{$self->commands->namespaces}, __PACKAGE__.'::Command';
  my $config = $self->plugin('NotYAMLConfig');
  $self->plugin('Model::DB',
		Pg =>  $self->config->{pg}
	       );
  
  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->any('/')->to('Root#index');
}

1;
