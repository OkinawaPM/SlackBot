#!perl

use File::Spec;
use Cwd 'getcwd';

BEGIN { unshift @INC, File::Spec->catfile(getcwd, "lib") }
require Okinawa::SlackBot;

my $pid = fork;
defined $pid or die 'Could not fork()';
if (!$pid) {
    Okinawa::SlackBot->new(name => $ENV{BOT_NAME}, token => $ENV{SLACK_TOKEN})->run;
    exit;
}

my $app = sub {
    [
        200,
        ['Content-Type' => 'text/plain'],
        ["https://turtle.gq/slack_form"]
    ]
};