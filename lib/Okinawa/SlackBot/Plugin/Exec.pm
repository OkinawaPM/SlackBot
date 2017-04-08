package Okinawa::SlackBot::Plugin::Exec;

use Okinawa::Base -base;
use Okinawa::SlackBot::Plugin;

plugin exec =>
    short 'Run your code using reply';

use Safe;
use POSIX;
use BSD::Resource;
use String::Random;
use Carp qw/croak confess/;

use DDP;

around 'exec' => sub {
    my ($orig, $self, $source_code) = @_;

    my $code = "";
    foreach my $line (@$source_code) {
    # HTML Escape strings
        $line =~ s/[“”]/\"/g;
        $line =~ s/[‘’]/\'/g;
        $line =~ s/&lt;/</g;
        $line =~ s/&gt;/>/g;
        $line =~ s/&quot;/\"/g;
        $line =~ s/&#39;/\'/g;
        $line =~ s/&amp;/&/g;
    # Escape sequences
        $line =~ s/\\n/\n/g;
        $line =~ s/\\t/\t/g;
        $line =~ s/(.*)\\r//g;
        $line =~ s/\\f/\f/g;
        $line =~ s/(.)\\b//g;
        $line =~ s/\\a/\a/g;
        $line =~ s/\\e/\e/g;
        $line =~ s/\\x/\x/g;
    #   $line =~ s/\\c/\c/g; # Not support?
        $line =~ s/\\l/\l/g;
        $line =~ s/\\u/\u/g;
    #   $line =~ s/\\L/\L/g; # Not support?
    #   $line =~ s/\\U/\U/g; # Not support?
    #   $line =~ s/\\E/\E/g; # Not support?

        $code .= $line;
    }

    $self->$orig($code);
};

# instance method
sub exec {
    my ($self, $source_code) = @_;

    pipe my ($read, $write);

    my $pid = fork;
    defined $pid or croak 'Could not fork()';

    my $timeout = 4;

    my ($result, $timed_out);
    if ($pid) {
        close $write;

        local $SIG{ALRM} = sub {
            $timed_out = 1;
            kill 15, -$pid;
            alarm 0;
        };

        alarm $timeout;
        
        wait;

        alarm 0;
    } else {
        POSIX::setpgid($$, $$);
        _setrlimit();
        close $read;

        open STDOUT, '>&', $write;
        open STDERR, '>&', STDOUT;

        my ($error, $res);
        {
            local $@;
            $res = $self->_execute_code($source_code) // 'undef';
            $error = $@;
        }
        
        if ($error) {
            chomp $error;
            print "Catching exception: `$error`";
        }
        print "\nresponse code: `$res`";
        exit;
    }

    if ($timed_out) {
        return "Timeout: `Interrupting, taking more than $timeout seconds`";
    }

    return do { local $/; <$read> };
}

sub _execute_code {
    my ($self, $code) = @_;
    my $rand = String::Random->new->randregex('[a-zA-Z]{16}');
    # set limit
    my $safe = Safe->new;
    $safe->permit_only(qw/
        print say eof :base_core :base_loop
        :base_mem :base_orig :base_math
        sort sleep :load
    /);
    my $res = $safe->reval(qq{
        use strict;
        use warnings;
        use v5.10;

        sub $rand {
            $code;
        }
        $rand();
    });
    return $res;
}

__PACKAGE__->meta->make_immutable();

no Mouse;

sub _setrlimit {
    my $limit = 1024 ** 2 * 4;
    setrlimit(RLIMIT_DATA,  $limit, $limit) or croak "Couldn't setrlimit: $!";
    setrlimit(RLIMIT_STACK, $limit, $limit) or croak "Couldn't setrlimit: $!";
    # setrlimit(RLIMIT_NPROC, 1, 1)          
    setrlimit(RLIMIT_NOFILE, 10, 10)        or croak "Couldn't setrlimit: $!";  
    setrlimit(RLIMIT_OFILE, 10, 10)         or croak "Couldn't setrlimit: $!";  
    setrlimit(RLIMIT_OPEN_MAX, 10, 10)      or croak "Couldn't setrlimit: $!"; 
    #setrlimit(RLIMIT_LOCKS, 1, 1)          
    setrlimit(RLIMIT_AS,   $limit, $limit)  or croak "Couldn't setrlimit: $!";
    setrlimit(RLIMIT_VMEM, $limit, $limit)  or croak "Couldn't setrlimit: $!";
    setrlimit(RLIMIT_MEMLOCK, 100, 100)     or croak "Couldn't setrlimit: $!";
    setrlimit(RLIMIT_CPU, 5, 10)            or croak "Couldn't setrlimit: $!";
    setrlimit(RLIMIT_FSIZE, $limit, $limit) or croak "Couldn't setrlimit: $!";
}

1;