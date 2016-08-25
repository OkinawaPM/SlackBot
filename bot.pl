#!/usr/bin/env perl

use FindBin;
BEGIN { push @INC, "$FindBin::Bin/lib" }
use Okinawa::SlackBot;

my $config = do 'config/config.pl';
my $bot = Okinawa::SlackBot->new(token => $config->{token}->{key});
$bot->run(config => "$FindBin::Bin/.replyrc");