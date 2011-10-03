package Uatu;
use Dancer ':syntax';

use Dancer::Plugin::Database;
use DateTime;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};



get qr{ / (\w+) /? }x  => sub {
    my ($channel) = splat;

    template 'channel';
};




get qr{ / (\w+) / (\d{4}-\d{2}-\d{2}) /? }x  => sub {
    my ($channel, $date) = splat;

    # hash is a meta char in urls so it's not used directly
    # add it back here because it does have semantic value
    my $url_channel = $channel;
    $channel = '#'.$channel;

    # Work out the dates for today / tomorrow
    my ($year, $month, $day) = split(/-/, $date); 
    my $dt = DateTime->new( year => $year, month => $month, day => $day );
    my $tomorrow  = $dt->clone->add( days => 1 )->ymd;
    my $yesterday = $dt->clone->subtract( days => 1 )->ymd;


    my $sth = database->prepare(q{
        SELECT id, TIME(sent) as time, DATE(sent) as date, sent, nick, message,
            CASE 
                WHEN emote IS NOT NULL THEN 'emote'
            END AS emote
        FROM logs
        WHERE channel = ?
        AND sent BETWEEN TIMESTAMP(?) AND TIMESTAMPADD(DAY, 1, ?)
        ORDER BY sent DESC
        LIMIT 999
    });

    $sth->execute($channel, $date, $date);
    my $messages = $sth->fetchall_hashref('id');
    
    # Does the job of uniq
    my %nicks = map { $_->{'nick'} => 1 } values $messages;

    template 'log', {
        channel      => $channel,
        url_channel  => $url_channel,
        date         => $date,
        tomorrow     => $tomorrow,
        yesterday    => $yesterday,
        messages     => $messages,
        nicks        => [keys %nicks],
    };
};






# Searching is non functional atm
get qr{ / (\w+) / ([-+\w]+) /? }x  => sub {
    my ($channel, $search) = splat;

    # hash is a meta char in urls so it's not used directly
    # add it back here because it does have semantic value
    my $url_channel = $channel;
    $channel = '#'.$channel;

    # it's a search, with + for spaces. Lets turn them back
    $search =~ s/\+/ /g;

    my $sth = database->prepare(
        q{
            SELECT id, TIME(sent) as time, DATE(sent) as date, nick, message
            FROM logs
            WHERE channel = ?
            AND message LIKE ?
            ORDER BY sent DESC
            LIMIT 999
        }
    );

    $sth->execute($channel, "%$search%");
    my $messages = $sth->fetchall_hashref('id');
    my %nicks = map { $_->{'nick'} => 1 } values $messages;

    template 'search', {
        channel      => $channel,
        url_channel  => $url_channel,
        search       => $search,
        messages     => $messages,
        nicks        => [keys %nicks],
    };
};



true;
