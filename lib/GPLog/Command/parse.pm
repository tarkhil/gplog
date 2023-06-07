package GPLog::Command::parse;
use Mojo::Base 'Mojolicious::Command', -signatures;
use Mojo::Util qw/getopt/;
# Short description
has description => 'My first Mojo command';

# Usage message from SYNOPSIS
has usage => sub ($self) { $self->extract_usage };

sub run ($self, @args) {
  getopt \@args,
    's|strict' => \my $strict,
    'p|parseonly' => \my $parseonly
    ;
  my $logfile = shift @args;
  if ( @args || !$logfile) {
    print STDERR $self->usage();
    exit(64);
  }
  open LOGFILE, $logfile or die "Cannot open $logfile: $!";
  my $logs = $self->app->db('log');
  my $tx = $logs->pg->db->begin;
  while (<LOGFILE>) {
    chomp;
    eval { 
      my $res = $logs->parse( $_ );
      if ( !$parseonly ) {
	if ( ($res->{flag}//'') eq '<=' ) {
	  $logs->store_message( $res );
	} else {
	  $logs->store_log( $res );
	}
      }
    };
    if ( $@ ) {
      if ( $strict ) {
	die "Error: $@\n";
      } else {
	warn "Error: $@\n";
      }
    }
  }
  $tx->commit;
  close LOGFILE;
}

=head1 SYNOPSIS

  Usage: APPLICATION parse LOGFILE [-s] [-p]

    -s - strict mode, die on error
    -p - only parse (do not check for ALL possible errors yet)

=cut

1;
