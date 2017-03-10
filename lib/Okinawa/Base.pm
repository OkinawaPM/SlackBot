package Okinawa::Base;

use strict;
use warnings;
use utf8;
use feature ();
use Cwd 'getcwd';

use Module::Load 'autoload_remote';

our @IMPORT = qw/Mouse/;
our @EXPORT = qw/classpath/;

# THIS CODE IS BASED Mojo::Base.
# SEE ALSO https://metacpan.org/source/SRI/Mojolicious-7.03/lib/Mojo/Base.pm

# Protect subclasses using AUTOLOAD
sub DESTROY { }

sub import {
    my $class = shift;
    return unless my $flag = shift;

    if ($flag eq '-base') {
        $flag = $class;
    } elsif ($flag eq '-default') {
        $flag = undef;
    }

    my $caller = caller;

    # Import other modules
    if ($flag) {
        autoload_remote $caller, $_ for @IMPORT;
    }

    # Exporter
    {
        no strict 'refs';
        *{"$caller::$_"} = \&{"$class::$_"} for @EXPORT;
    }

    $_->import for qw/strict warnings utf8/;
    feature->import(':5.10');
}

=pod
around 
    run   => sub { ... },
    error => sub { ... },
    shout => sub { ... };
=cut

# subroutine
sub classpath {
    my $package = shift;
    my @class_path = split /::/, $package;
    return File::Spec->catfile(getcwd, 'lib', @class_path);
}

1;