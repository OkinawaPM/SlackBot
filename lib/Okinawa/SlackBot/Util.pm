package Okinawa::SlackBot::Util;

use Mojo::Base -strict;
use parent 'Exporter';

use Time::Moment;
use BSD::Resource;

our @EXPORT = qw/setlimit now make_pipe/;

# BSD::Resource
sub setlimit {
    my $limit = 1024 ** 2 * 4;
    setrlimit(RLIMIT_DATA,  $limit, $limit) &&
    setrlimit(RLIMIT_STACK, $limit, $limit) &&
    # setrlimit(RLIMIT_NPROC, 1, 1)           &&
    setrlimit(RLIMIT_NOFILE, 10, 10)        &&
    setrlimit(RLIMIT_OFILE, 10, 10)         &&
    setrlimit(RLIMIT_OPEN_MAX, 10, 10)      &&
    #setrlimit(RLIMIT_LOCKS, 1, 1)           &&
    setrlimit(RLIMIT_AS,   $limit, $limit)  &&
    setrlimit(RLIMIT_VMEM, $limit, $limit)  &&
    setrlimit(RLIMIT_MEMLOCK, 100, 100)     &&
    setrlimit(RLIMIT_CPU, 5, 5) or die "setrlimit failed";
}

# Time::Moment
sub now { Time::Moment->now }

# Perl
sub make_pipe {
    my $self = shift;

    my ($read, $write);
    pipe $read, $write;

    $write->autoflush(1);

    return +{
        read => $read,
        write => $write
    };
}



1;