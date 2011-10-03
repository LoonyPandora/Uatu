package Bot::BasicBot::Pluggable::Module::UK2::Watcher;

use common::sense;
use base 'Bot::BasicBot::Pluggable::Module::UK2';

=head1 NAME

Bot::BasicBot::Pluggable::Module::UK2::Quote - Misquotage FTW!

=head1 DESCRIPTION

Allows users to add, delete and score quotes from an IRC channel.

TODO: Needs moar POD

=cut

my $config_file = 'watcher.conf';

sub help {
    return qq{Uatu is watching...};
}

sub dbh {
    my ($self) = @_;

    # If we have an existsing DB handle, check that it is responsive.
    if ($self->{dbh}) {
        my $sth = $self->{dbh}->prepare('SELECT 1');
        if (   !$sth
            || !$sth->execute) {
            delete $self->{dbh};
        }
    }

    return $self->{dbh} //= $self->_new_dbh;
}

sub init {
    my ($self) = @_;
    $self->conf($config_file);
}


sub emoted {
    my ($self, $response, $priority) = @_;

    return unless $priority == 2;

    $self->_log($response->{channel}, $response->{who}, $response->{body}, 1);
}


# lowest priority bot, logs things after any other bots respond
sub fallback {
    my ($self, $response) = @_;

    $self->_log($response->{channel}, $response->{who}, $response->{body});
}


sub _log {
    my ($self, $channel, $nick, $message, $emote) = @_;

    my $sth = $self->dbh->prepare(q{
        INSERT INTO logs (sent, nick, message, channel, emote)
        VALUES (NOW(), ?, ?, ?, ?)
    });
    
    if (!$sth->execute($nick, $message, $channel, $emote)) {
        return "Unable to log: " . $!;
    }
}


# The DB config is stored in a perl hash ref in a separate file... so grab that
# and create a DBH
sub _new_dbh {
    my ($self) = @_;

    my $dbconf = $self->conf->{db};

    return DBI->connect("dbi:mysql:$dbconf->{db}:$dbconf->{host}",
        $dbconf->{user}, $dbconf->{password} )
      or die "Unable to obtain a DB connection.";
}




