package Uatu;
use Dancer ':syntax';

use Dancer::Plugin::Database;
use DateTime;

use common::sense;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get qr{ / (\w+) /? }x  => sub {
    my ($channel) = splat;

    redirect "$channel/".DateTime->now->ymd;
};


get qr{ / (\w+) / (\d{4}-\d{2}-\d{2}) /? }x  => sub {
    my ($channel, $date) = splat;

    # Work out the dates for today / tomorrow links
    my ($year, $month, $day) = split(/-/, $date); 
    my $selected_date = DateTime->new( year => $year, month => $month, day => $day );
    my $today         = DateTime->today;
    my $tomorrow      = $selected_date->clone->add( days => 1 );
    my $yesterday     = $selected_date->clone->subtract( days => 1 );

    # If the "next day" link would be tomorrow (i.e. no logs for that day) - don't create a link
    my $yesterday_link = $yesterday->ymd;
    my $tomorrow_link;

    # If it's a date in the future, just punt us to today
    # Don't show next day link if that would be a day we have no logs for
    given ( DateTime->compare($selected_date, $today) ) {
        when ('1') { redirect "$channel/".$today->ymd when '1'; }
        when ('0') { $tomorrow_link = undef;                    }
        default    { $tomorrow_link = $tomorrow->ymd;           }
    }

    # hash is a meta char in urls so it's not used directly
    # add it back here because it does have semantic value
    my $url_channel = $channel;
    $channel = '#'.$channel;

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
        day_name     => $selected_date->day_name,
        month_name   => $selected_date->month_name,
        cur_day      => $selected_date->day,
        ordinal      => _get_ordinal($selected_date->day),
        tomorrow     => $tomorrow_link,
        yesterday    => $yesterday_link,
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




sub _get_ordinal {
    $_[0] =~ /^(?:\d+|\d[,\d]+\d+)$/ or return $_[0];
    return "nd" if $_[0] =~ /(?<!1)2$/;
    return "rd" if $_[0] =~ /(?<!1)3$/;
    return "st" if $_[0] =~ /(?<!1)1$/;
    return "th";
}


true;
