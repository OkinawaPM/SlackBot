package Bot;

use strict;
use warnings;

use Reply;

our $VERSION = "1.00";

my %opts;

sub new {
	my $class = shift;
	%opts = @_;
	my $self = bless {}, $class;
	return $self;
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

	if (fork) {
		close $result_pipe->{write};
	    close $pipe->{read};
	    wait;
	} else {
	    close $pipe->{write};
	    close $result_pipe->{read};

	    open STDIN, '<&', $pipe->{read};
	    open STDOUT, '>&', $result_pipe->{write};
	    open STDERR, '>&', $result_pipe->{write};

	    $reply->step($exec);
	    exit;
	}

	my $r = $result_pipe->{read};
	my $data = "";
	while(<$r>) { $data .= $_; }

	$data =~ s/\[\d+m//g;

	$data =~ s/at reply input line (\d+)/at perl input line $1/g;
	$data =~ s/\$res\[\d+\] = (.*)/${emoji}return $1/g;

	return $data;
}


1;