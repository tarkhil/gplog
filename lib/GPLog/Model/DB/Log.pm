package GPLog::Model::DB::Log;
use Mojo::Base 'MojoX::Model',-signatures;
use Mojo::Exception;
use Regexp::Common qw/time/;

use DateTime::Format::Pg;

sub tidy_hash($orig, $fields) {
  return { map { ( $_ => $orig->{$_} ) } @$fields };
}

sub store($self,$table,$tidy,$line) {
  my $l = tidy_hash( $line, $tidy );
  return $self->pg->db->insert( $table => $l );
}

sub store_log($self,$line) {
  return $self->store( log => [qw/created int_id str address/], $line);
}

sub store_message($self,$line) {
  if ( $line->{str} =~ /id=(\S+)/ ) {
    return $self->store( message => [qw/created int_id str id/], { %$line, id => $1 } );
  } else {
    # Мы эту строку все равно никогда не найдем, лучше ругнуться при работе
    Mojo::Exception->throw( "'".$line->{str}."' contains no id");
  }
}

sub parse($self,$line) {
  my $flags = '(<=|=>|\->|\*\*|==)';
  # Я не понял, как добыть минуты и секунды
  my $dt = $RE{time}{tf}{-pat => 'yyyy-mm-dd hh:'}.'[0-5]\d:[0-5]\d';
  # Формальных ограничений на внутренний ID не накладывается, так что просто двенадцать непробелов
  # Хотя скорее всего ([[:alnum:]]{6}\-[[:alnum:]]{6}\-[[:alnum:]]{2})
  # "Строка лога без временной метки" - это, формально говоря, все кроме метки
  # Если это на самом деле только то, что не разобрано, то нужно переделать выражение
  # ^($dt) (\S{16}) (($flags (\S+) )?(.*))
  # Соответственно "остальное" это $7, а наличие флага определится по $4
  if ( $line !~ /^($dt) ((\S{16}) ($flags (\S+) )?.*)/ ) {
    Mojo::Exception->throw("Line '$line' does not look like log");
  }
  my $record = { created => $1, int_id => $3, str => $2 };
  # Если у нас есть $5, то это адрес+сообщение
  if ( $5 ) {
    $record->{flag} = $5;
    $record->{address} = $6;
  }
  return $record;
}

1;
