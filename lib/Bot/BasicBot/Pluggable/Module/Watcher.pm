package Bot::BasicBot::Pluggable::Module::Watcher;

our $VERSION = '0.1';

use base qw(Bot::BasicBot::Pluggable::Module);

use common::sense;

use Dancer ':syntax';
use Dancer::Plugin::Database;

