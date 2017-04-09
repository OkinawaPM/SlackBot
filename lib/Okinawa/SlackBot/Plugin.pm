package Okinawa::SlackBot::Plugin;

use Mojo::Log;
use File::Spec;
use Carp 'croak';
use Clone 'clone';

my $plugins = +{};

sub short($);
sub plugin($$);

use Okinawa::Base -base;

has name => (
    is       => 'ro',
    required => 1
);

has log => (
    is      => 'ro',
    default => sub { Mojo::Log->new },
);

sub find_pm {
    my ($self, $path) = @_;
     # package list under the "Plugin" directory
    opendir my $fh, $path or croak "Could not opendir: $!";
    my @pmfiles = grep { $_ =~ /\A[A-Z][a-z]+\.pm\z/ } readdir $fh;
    closedir $fh;

    return @pmfiles;
}

sub load {
    my $self = shift;

    my $this = __PACKAGE__;
    my $path = classpath($this);
    my @pmfiles = $self->find_pm($path);

    my $obj = clone $self; # deep copy

    # load plugins
    for my $pm (@pmfiles) {
        eval {
            require File::Spec->catfile($path, $pm);
            my $pkg = $pm =~ s/\A([A-Z][a-z]+)\.pm\z/$this::$1/r;
            if ($plugins->{$pkg}) {
                my $method  = $plugins->{$pkg}{run};
                $self->log->info("Load plugin: $pkg->$method");
                # About "sub { bless($obj, $pkg)->$method(@_[1..$#_]) }"
                # @_ == ([0] => $class, [1..$#_] => $argument)
                # So remove first element "Okinawa::SlackBot::Plugin" class name
                $self->meta->add_method($method => sub {
                    my $new = bless $obj, $pkg;
                    $new->$method(@_[1..$#_]);
                });
            }
        };
        $self->log->warn("Failed to load method: ".$@) if $@;
    }

    return $self;
}

sub usage {
    my $self = shift;

    unless ($self->{usage}) {
        open my $buf, '>', \my $output;
        select $buf;

        say "Usage: \@".$self->name." COMMAND";
        for my $pkg (sort { $a cmp $b } keys %$plugins) {
            say "-- ".$plugins->{$pkg}{run};
            say "    ".$plugins->{$pkg}{short};
        }
        say "-- help\n    :robot_face: help";
        
        select *STDOUT;
        close $buf;

        $self->{usage} = $output;
    }
    
    return $self->{usage};
}

__PACKAGE__->meta->make_immutable();

no Mouse;

# for plugin dsl
sub import {
    my ($class, $caller) = (shift, caller);
    if ($caller =~ /$class/) {
        no strict 'refs';
        *{"$caller::$_"} = \&{"$class::$_"} for qw/plugin short/;
    }
}

sub short($) { shift }
sub plugin($$) {
    my ($run, $short) = @_;
    $plugins->{scalar caller} = +{
        run   => $run,
        short => $short,
    };
}

1;