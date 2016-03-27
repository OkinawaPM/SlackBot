package Bot;

use strict;
use warnings;

use Reply;
use BSD::Resource;

our $VERSION = "1.02";

my %opts;

sub new {
	my $class = shift;
	%opts = @_;
	my $self = bless {}, $class;
	return $self;
}

sub setlimit {
	my $limit = 1024 ** 2 * 4;
	setrlimit(RLIMIT_DATA,  $limit, $limit) &&
	setrlimit(RLIMIT_STACK, $limit, $limit) &&
	setrlimit(RLIMIT_NPROC, 1, 1)           &&
	setrlimit(RLIMIT_NOFILE, 10, 10)        &&
	setrlimit(RLIMIT_OFILE, 10, 10)         &&
	setrlimit(RLIMIT_OPEN_MAX, 10, 10)      &&
	#setrlimit(RLIMIT_LOCKS, 1, 1)           &&
	setrlimit(RLIMIT_AS,   $limit, $limit)  &&
	setrlimit(RLIMIT_VMEM, $limit, $limit)  &&
	setrlimit(RLIMIT_MEMLOCK, 100, 100)     &&
	setrlimit(RLIMIT_CPU, 10, 10) or die "setrlimit failed";
}

sub makePipe {
	my $self = shift;

    my ($read, $write);
    pipe $read, $write;

    $write->autoflush(1);

    return {read => $read, write => $write};
}

sub getResult {
	my $self = shift;
	my ($exec, $emoji) = @_;
	
	my $pipe = $self->makePipe;
	my $result_pipe = $self->makePipe;

	my $reply = Reply->new(%opts);
	my $timeout = 7;

	my $pid = fork;
	defined $pid or return 'fork failed';

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
	    local $SIG{ALRM} = sub {
	        print STDERR "Interrupting, taking more than $timeout seconds";
	        kill 9, $$;
	    };
	    $self->setlimit;
	    $reply->step($exec);
	    exit;
	}

	my $r = $result_pipe->{read};
	my $data = "";
	$data .= $_ while <$r>;

	$data =~ s/\[\d+m//g;

	$data =~ s/at reply input line (\d+)/at perl input line $1/g;
	$data =~ s/\$res\[\d+\] = (.*)/${emoji}return $1/g;

	return $data;
}


1;