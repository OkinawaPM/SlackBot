package Okinawa::SlackBot::Help;

use Mojo::Base 'Okinawa::SlackBot';

sub usage {
    return "
        Usage: \@perl COMMAND\n
        -- run\n
            Run your code using reply :+1:\n
        -- help\n
           :robot_face: help\n
    ";
}

1;