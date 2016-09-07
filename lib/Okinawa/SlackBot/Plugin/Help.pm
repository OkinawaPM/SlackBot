package Okinawa::SlackBot::Plugin::Help;

use Okinawa::Base -base;

sub help {
    return "
        Usage: \@perl COMMAND\n
        -- exec\n
            Run your code using reply :+1:\n
        -- help\n
           :robot_face: help\n
    ";
}

__PACKAGE__->meta->make_immutable();

1;