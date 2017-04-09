package Okinawa::SlackBot;

use Carp 'croak';
use Okinawa::Base -base;
extends 'Mojo::SlackRTM';

use Okinawa::SlackBot::Plugin;
use version; our $VERSION = version->declare('v0.1.3');

has name => (
    is       => 'ro',
    required => 1
);

has plugin => (
    is       => 'ro',
    lazy     => 1,
    default  => sub { Okinawa::SlackBot::Plugin->new(name => shift->{name}) }
);

has id => (
    is       => 'ro',
    required => 1,
    lazy     => 1,
    default  => sub {
        my $self = shift;
        $self->find_user_id($self->{name});
    }
);

sub validation {
    my ($self, $text) = @_;
    return $text =~ /\A<@([0-9A-Z]+)> / ? $1 eq $self->id : 0;
}

sub run {
    my $self = shift;
    $self->log->info("Running...");
 
    $self->plugin->load or croak "Failed to load plugins: $!\n";

    $self->on(message => sub {
        my ($self, $event) = @_;

        # First, find the bot id. because it use on the validation.
        my $text = $event->{text};
        return unless $self->validation($text);

        my $channel_id = $event->{channel};
        my $user_id    = $event->{user};
        my $user_name  = $self->find_user_name($user_id);
        my $args       = [split /\n/, $text];
        my $command    = shift @$args;
        my $method     = (split /\s/, $command)[-1];
        $self->log->info("Method: $method");

        my $result = eval {
            $self->plugin->can($method) ? $self->plugin->$method($args)
                                        : $self->plugin->usage;
        };
        $self->send_message($channel_id => $@ || $result);
    });

    $self->start;
}

1;