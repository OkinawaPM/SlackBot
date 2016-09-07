package Okinawa::SlackBot;

use DDP;
use Mojo::SlackRTM;
use Mojo::Base 'Mojo::SlackRTM';

use Okinawa::SlackBot::Plugin;
use Mojo::IOLoop::ReadWriteFork;

our $VERSION = "1.03";

has 'plugin' => sub { Okinawa::SlackBot::Plugin->new->load };

sub run {
    my ($self, %param) = @_;
    $self->log->info("Running...");

    $self->on(message => sub {
        my ($self, $event) = @_;
        my $channel_id = $event->{channel};
        my $user_id    = $event->{user};
        my $user_name  = $self->find_user_name($user_id);
        my $text       = $event->{text};

        my $args = [split /\n/, $text];
        my $command = shift @$args;
        my $method = (split /\s/, $command)[-1];
        $self->log->info("Method: $method");

        my $result = eval {
            $self->plugin->can($method) ? $self->plugin->$method($args) : "Command Not Found";
        };
        $self->send_message($channel_id => $@ || $result);

=pod
        if ($method =~ /run/) {
            $self->log->info("Running code: $user_name");

            $self->send_message($channel_id => $self->exec->eval(
                source => $args,
                emoji  => ":camel:",
                config => $param{config}
            ));

            $self->log->info("Post");
            
        } elsif ($method =~ /help/) {
            $self->send_message($channel_id => $self->usage);
        } elsif ($method =~ /echo/) {
            $self->send_message($channel_id => $args);
        }
        $self->log->info($text);
=cut
    });

    $self->start;
}




1;
__END__

=encoding utf-8

=head1 NAME

Okinawa::SlackBot - It's new $module

=head1 SYNOPSIS

    use Okinawa::SlackBot;

=head1 DESCRIPTION

Okinawa::SlackBot is ...

=head1 LICENSE

Copyright (C) Code-Hex.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Code-Hex E<lt>x00.x7f@gmail.comE<gt>

=cut

