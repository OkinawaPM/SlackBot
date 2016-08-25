package Okinawa::SlackBot;

use Mojo::Base -base;

use DDP;
use Mojo::SlackRTM;
use parent 'Mojo::SlackRTM';

use Okinawa::SlackBot::Exec;
use Okinawa::SlackBot::Help;

our $VERSION = "1.03";

has 'exec'  => sub { Okinawa::SlackBot::Exec->new   };
has 'usage' => sub { Okinawa::SlackBot::Help->usage };

sub run {
    my ($self, %param) = @_;
    $self->log->info("Running...");
    $self->on(message => sub {
        my ($self, $event) = @_;
        my $channel_id = $event->{channel};
        my $user_id    = $event->{user};
        my $user_name  = $self->find_user_name($user_id);
        my $text       = $event->{text};

        my $code_lines = [split /\n/, $text];
        my $command = shift @$code_lines;
        if ($command =~ /run/) {
            $self->log->info("Running code: $user_name");
            my $result = $self->exec->eval(
                source => $code_lines,
                emoji  => ":camel:",
                config => $param{config}
            );
            $self->log->info("Post");
            $self->send_message($channel_id => $result);
        } elsif ($command =~ /help/) {
            $self->send_message($channel_id => $self->usage);
        }
        $self->log->info($text);
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

