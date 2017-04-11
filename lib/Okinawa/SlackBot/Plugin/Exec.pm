package Okinawa::SlackBot::Plugin::Exec;

use strict;
use warnings;
use utf8;
use feature ':5.22';

use Mouse;
use Okinawa::SlackBot::Plugin;

plugin exec => short 'Run your code using Safe->reval';

use Safe;
use POSIX;
use BSD::Resource;
use String::Random;
use Carp qw/croak confess/;

# module load in reval
use Encode;
use Data::Dumper;

use Scalar::Util qw(
    blessed refaddr reftype weaken unweaken isweak
    readonly set_prototype dualvar isdual isvstring
    looks_like_number openhandle tainted
);

has safe => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $safe = Safe->new;
        $safe->permit_only(qw/
            print say eof :base_core :base_loop
            :base_mem :base_orig :base_math
            sort sleep :load utime ftatime ftctime time tms
            read :filesys_read pack unpack
        /);
        $safe->share_from('main', [qw/
            Internals::SvREADONLY
            mro::method_changed_in
            mro::get_linear_isa
            mro::get_pkg_gen mro::set_mro
            mro::method_changed_in mro::get_mro
            mro::invalidate_all_method_caches
            mro::is_universal mro::get_isarev

            Dumper

            blessed refaddr reftype weaken unweaken isweak
            readonly set_prototype dualvar isdual isvstring
            looks_like_number openhandle tainted

            decode decode_utf8 encode encode_utf8 str2bytes bytes2str
            encodings find_encoding find_mime_encoding clone_encoding
        /]);

        return $safe;
    }
);

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
            print "Catching exception:\n```$error```";
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
    my $res = $self->safe->reval(qq{
        use strict;
        use warnings;
        use utf8;
        use feature ':5.22';

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
    my $limit = 1024 ** 2 * 15;
    setrlimit(RLIMIT_CPU, 25, 30)           or croak "Couldn't setrlimit: $!";
    setrlimit(RLIMIT_FSIZE, $limit, $limit) or croak "Couldn't setrlimit: $!";
}

1;