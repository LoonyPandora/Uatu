package Bot::BasicBot::Pluggable::Module::UK2;

use strict;
no warnings;
use base 'Bot::BasicBot::Pluggable::Module';

=head1 NAME

Bot::BasicBot::Pluggable::Module::UK2 - The great new Bot::BasicBot::Pluggable::Module::UK2!

=head1 DESCRIPTION

This module acts as a base class which contains common elements for all modules
in the UK2:: suite.

=cut

sub conf { 
    my ($self, $configuration_file) = @_;

    if (   !$self->{conf} 
        && !$configuration_file )
    {
        die "No config exists. Please specify a config file in the init sub"; 
    }

    if ($configuration_file) {
        # TODO: Add some file fingerprint checking so changes to the config
        #       don't require a restart.
        if (   !-e $configuration_file
            || !-f $configuration_file )
        {
            die "Unable to find configuration file!";
        }
        $self->{conf} = do $configuration_file;
    }

    return $self->{conf};
}


=head1 AUTHOR

James Ronan, C<< <jim at dev.uk2.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-bot-basicbot-pluggable-module-uk2 at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Bot-BasicBot-Pluggable-Module-UK2>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Bot::BasicBot::Pluggable::Module::UK2


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Bot-BasicBot-Pluggable-Module-UK2>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Bot-BasicBot-Pluggable-Module-UK2>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Bot-BasicBot-Pluggable-Module-UK2>

=item * Search CPAN

L<http://search.cpan.org/dist/Bot-BasicBot-Pluggable-Module-UK2/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 James Ronan.

This program is released under the following license: GPL


=cut

1; 
