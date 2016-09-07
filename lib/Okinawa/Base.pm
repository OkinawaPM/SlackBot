package Okinawa::Base;

use strict;
use warnings;
use utf8;
use feature ();
use FindBin;

use Module::Load qw/autoload_remote/;

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

    my $caller = caller(0);

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


# subroutine
sub classpath {
    my $package = shift;
    my $class_path = join '/', split /::/, $package;
    return "$FindBin::Bin/lib/$class_path";
}

1;