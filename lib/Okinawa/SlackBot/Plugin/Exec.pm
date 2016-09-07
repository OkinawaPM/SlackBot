package Okinawa::SlackBot::Plugin::Exec;

use Okinawa::Base -base;

use POSIX qw/SIGALRM/;
use Reply;
use DDP;
use Okinawa::SlackBot::Util;
use Safe;
# class method

# instance method
sub exec {
    my ($self, $source_code) = @_;

    my $emoji = ":camel:";

    say STDERR "Execution: $source_code";
    # %param == (config => '.replyrc') の想定
    #my $reply = Reply->new(%params);

    my $pipe = make_pipe();
    my $result_pipe = make_pipe();

    my $pid = fork;
    defined $pid or return 'execution failed';

    my $timeout = 4;

    if ($pid) {
        close $result_pipe->{write};
        close $pipe->{read};
        
        waitpid($pid, 0);
    } else {
        close $pipe->{write};
        close $result_pipe->{read};

        open STDIN, '<&', $pipe->{read};
        open STDOUT, '>&', $result_pipe->{write};
        open STDERR, '>&', $result_pipe->{write};

        my $result = timeout($timeout, $source_code);
        
        print STDERR $result unless $result =~ /^[01]$/;
        exit;
    }
    say STDERR "execution finish";

    my $r = $result_pipe->{read};

    my $data = do { local $/; <$r> };

    $data =~ s/\[\d+m//g;
    $data =~ s/at reply input line (\d+)/at perl input line $1/g;

    if ($data =~ s/\$res\[\d+\] = (.*)//g) {
        return "```\n$data```\n${emoji} return $1";
    }

    return $data;
}

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

sub timeout {
    my ($sec, $exec) = @_;

    local $SIG{__DIE__} = 'DEFAULT';
    local $SIG{ALRM} = 'DEFAULT';

    my $safe = Safe->new;
    $safe->permit_only(qw/print :base_core :base_loop :base_mem :base_orig :base_math sort sleep alarm :load/);

    my $error;
    {
        local $@;

        $safe->reval(qq{
            local \$SIG{ALRM} = sub { die "__TIMEOUT__\n" };
            alarm $sec;
            $exec
            alarm 0;
        });
            
        $error = $@;
    }

    if ($error) {
        if ($error eq "__TIMEOUT__\n") {
            print STDERR "Interrupting, taking more than $sec seconds";
            return 1;
        }
        return $error;
    }
    return 0;
}

__PACKAGE__->meta->make_immutable();

1;