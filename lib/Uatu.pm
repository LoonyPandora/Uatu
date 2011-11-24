package Uatu;
use Dancer ':syntax';

use Dancer::Plugin::Database;
use DateTime;

use common::sense;

our $VERSION = '0.1';

get '/' => sub {
    my $chan_sth = database->prepare(q{
        SELECT
            MONTHNAME(MAX(sent)) AS last_month, DAYNAME(MAX(sent)) AS last_day, DAYOFMONTH(MAX(sent)) AS last_date,
            MONTHNAME(MIN(sent)) AS first_month, DAYNAME(MIN(sent)) AS first_day, DAYOFMONTH(MIN(sent)) AS first_date,
            COUNT(*) AS total,
            channel
        FROM LOGS
        GROUP BY channel
        ORDER BY channel ASC
        LIMIT 99
    });

    $chan_sth->execute();
    my $all_channels = $chan_sth->fetchall_hashref('channel');

    for (values %$all_channels) {
        my $channel_path = $_->{channel};
        $channel_path =~ s/#//;

        $_->{chanpath} = $channel_path;
    }

    template 'index', {
        all_channels => $all_channels,
    };
};


# Searching is non functional atm
post '/search' => sub {
    my $search  = params->{search};
    my $channel = params->{channel};

    my $chanpath = $channel;
    $chanpath =~ s/#//;

    # it's a search, with + for spaces. Lets turn them back
    $search =~ s/\+/ /g;

    my $sth = database->prepare(q{
        SELECT id, TIME(sent) as time, DATE(sent) as date, sent, nick, message,
            CASE 
                WHEN emote IS NOT NULL THEN 'emote'
            END AS emote,
            CASE 
                WHEN presence IS NOT NULL THEN 'presence'
            END AS presence,
            CASE 
                WHEN topic IS NOT NULL THEN 'topic'
            END AS topic,
            CASE 
                WHEN kick IS NOT NULL THEN 'kick'
            END AS kick
        FROM logs
        WHERE channel = ?
        AND sent BETWEEN TIMESTAMP(?) AND TIMESTAMPADD(DAY, 1, ?)
        ORDER BY sent ASC
        LIMIT 9999
    });

    $sth->execute($channel, "%$search%");
    my $messages = $sth->fetchall_hashref('id');

    # Does the job of uniq
    my %nicks = map { $_->{'nick'} => 1 } values $messages;

    # We need another query to get all the channels
    # since the above query has a where clause limiting it to one
    my $chan_sth = database->prepare(q{
        SELECT MAX(sent) AS lastlog, MIN(sent) AS firstlog, COUNT(*) AS total, channel
        FROM LOGS
        GROUP BY channel
        ORDER BY channel ASC
        LIMIT 99
    });

    $chan_sth->execute();
    my $all_channels = $chan_sth->fetchall_hashref('channel');

    for (values %$all_channels) {
        my $channel_path = $_->{channel};
        $channel_path =~ s/#//;

        $_->{chanpath} = $channel_path;
    }

    template 'search', {
        all_channels     => $all_channels,
        current_channel  => $channel,
        current_chanpath => $chanpath,
        search       => $search,
        messages     => $messages,
        nicks        => [keys %nicks],
    };
};


get qr{ / (\w+) /? }x  => sub {
    my ($channel) = splat;

    redirect "$channel/".DateTime->now->ymd;
};


get qr{ / (\w+) / (\d{4}-\d{2}-\d{2}) /? }x  => sub {
    my ($channel, $date) = splat;

    my ($year, $month, $day) = split(/-/, $date); 
    my $selected_date = DateTime->new( year => $year, month => $month, day => $day );

    # hash is a meta char in urls so it's not used directly
    # add it back here because it does have semantic value
    my $chanpath = $channel;
    $channel = '#'.$chanpath;

    my $log_sth = database->prepare(q{
        SELECT id, TIME(sent) as time, DATE(sent) as date, sent, nick, message,
            CASE 
                WHEN emote IS NOT NULL THEN 'emote'
            END AS emote,
            CASE 
                WHEN presence IS NOT NULL THEN 'presence'
            END AS presence,
            CASE 
                WHEN topic IS NOT NULL THEN 'topic'
            END AS topic,
            CASE 
                WHEN kick IS NOT NULL THEN 'kick'
            END AS kick
        FROM logs
        WHERE channel = ?
        AND sent BETWEEN TIMESTAMP(?) AND TIMESTAMPADD(DAY, 1, ?)
        ORDER BY sent ASC
        LIMIT 9999
    });

    $log_sth->execute($channel, $date, $date);
    my $messages = $log_sth->fetchall_hashref('id');
    
    # Does the job of uniq
    my %nicks = map { $_->{nick} => 1 } values $messages;

    # We need another query to get all the channels
    # since the above query has a where clause limiting it to one
    my $chan_sth = database->prepare(q{
        SELECT DISTINCT channel
        FROM logs
        ORDER BY channel ASC
        LIMIT 99
    });

    $chan_sth->execute();
    my $all_channels = $chan_sth->fetchall_hashref('channel');

    for (values %$all_channels) {
        my $channel_path = $_->{channel};
        $channel_path =~ s/#//;

       $_->{chanpath} = $channel_path;
    }

    template 'log', {
        all_channels     => $all_channels,
        current_channel  => $channel,
        current_chanpath => $chanpath,
        date             => $date,
        day_name         => $selected_date->day_name,
        month_name       => $selected_date->month_name,
        cur_day          => $selected_date->day,
        ordinal          => _get_ordinal($selected_date->day),
        messages         => $messages,
        nicks            => [keys %nicks],
    };
};







sub _get_channel_list {
    my $sth = database->prepare(q{
        SELECT DISTINCT channel
        FROM logs
        ORDER BY channel ASC
        LIMIT 99
    });

    $sth->execute();
    return $sth;
}




sub _get_ordinal {
    $_[0] =~ /^(?:\d+|\d[,\d]+\d+)$/ or return $_[0];
    return "nd" if $_[0] =~ /(?<!1)2$/;
    return "rd" if $_[0] =~ /(?<!1)3$/;
    return "st" if $_[0] =~ /(?<!1)1$/;
    return "th";
}


true;
