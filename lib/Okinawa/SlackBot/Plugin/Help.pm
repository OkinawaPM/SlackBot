package Okinawa::SlackBot::Plugin::Help;

use Okinawa::Base -base;

sub help {
    return <<"...";
Usage: \@perl COMMAND
-- exec
    Run your code using reply :+1:
-- help
    :robot_face: help
...
}

__PACKAGE__->meta->make_immutable();

1;