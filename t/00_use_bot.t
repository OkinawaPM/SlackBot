use strict;
use Test::More;

use File::Spec;
use Cwd 'getcwd';
my $pwd = getcwd;
push @INC, File::Spec->catfile($pwd, "lib");

use_ok $_ for qw(
    Okinawa::Base
    Okinawa::SlackBot
    Okinawa::SlackBot::Plugin
);

done_testing;