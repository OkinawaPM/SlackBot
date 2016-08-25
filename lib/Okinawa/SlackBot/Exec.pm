package Okinawa::SlackBot::Exec;

use utf8;
use Safe;
use Mouse;

use Mojo::Base 'Okinawa::SlackBot';

use Reply;
use Data::Printer;
use Okinawa::SlackBot::Util;

has 'safe' => sub { Safe->new };

sub eval {
    my ($self, %params) = @_;

    my $exec = delete $params{source};
    my $emoji = delete $params{emoji};

    # %param == (config => '.replyrc') の想定
    my $reply = Reply->new(%params);

    my $pipe = make_pipe();
    my $result_pipe = make_pipe();

    my $pid = fork;
    defined $pid or return 'fork failed';

    my $timeout = 4;

    if ($pid) {
        close $result_pipe->{write};
        close $pipe->{read};
        waitpid($pid, 0);
    } else {
        local $SIG{ALRM} = sub {
            print STDERR "Interrupting, taking more than $timeout seconds";
            kill 9, $$;
        };
        close $pipe->{write};
        close $result_pipe->{read};

        open STDIN, '<&', $pipe->{read};
        open STDOUT, '>&', $result_pipe->{write};
        open STDERR, '>&', $result_pipe->{write};
        setlimit();
        alarm($timeout);
        $self->safe->reval(qq{$reply->step($exec)});
        alarm(0);
        exit;
    }

    my $r = $result_pipe->{read};

    my $data = do { local $/; <$r> };

    $data =~ s/\[\d+m//g;
    $data =~ s/at reply input line (\d+)/at perl input line $1/g;

    if ($data =~ s/\$res\[\d+\] = (.*)//g) {
        return "```\n$data```\n${emoji} return $1";
    }

    return $data;
}

around 'eval' => sub {
    my ($orig, $self, %param) = @_;

    my $code = "";
    foreach my $line (@{$param{source}}) {
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

    $param{source} = $code;

    $self->$orig(%param);
};

1;