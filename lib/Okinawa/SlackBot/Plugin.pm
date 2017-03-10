package Okinawa::SlackBot::Plugin;

use Okinawa::Base -base;
use Data::Dumper;

has log => (
    is => 'ro',
    default => sub { Mojo::Log->new }
);

sub load {
    my $self = shift;
    
    my $path = classpath(__PACKAGE__);

    # package list under "Plugin" directory
    opendir my $fh, $path or die "Could not opendir: $!";
    my @pm = grep { $_ !~ /\A\.+\z/ } readdir $fh;
    closedir $fh;

    # load plugins
    for my $plugin (@pm) {
        eval {
            require File::Spec->catfile($path, $plugin);
            $plugin =~ s/\.pm\z//;
            my $method = lc $plugin;
            my $package = __PACKAGE__."::$plugin";
            $self->log->info("Load method: $package->$method");

            # About "sub { $package->$method(pop @_) }"
            # @_ == ([0] => $class, [1] => $argument)
            # So remove first element "Okinawa::SlackBot::Plugin" class
            $self->meta->add_method($method => sub { $package->$method(@_[1..$#_]) });  
        };
        $self->log->warn($@) if $@;
    }

    # Remove main class
    delete $self->meta->{methods}->{$_} for qw/new meta DESTROY/;

    return $self;
}

__PACKAGE__->meta->make_immutable();

1;