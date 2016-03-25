use strict;
use warnings;
use v5.10;

use utf8;
use lib "lib", "lib";

use Bot;
use Mojo::SlackRTM;

my $emoji = ":camel:";
my $token = ""; #slack token

my $bot = Bot->new(config => ".replyrc");

my $slack = Mojo::SlackRTM->new(token => $token);
$slack->on(message => sub {
    my ($slack, $event) = @_;
    my $channel_id = $event->{channel};
    my $user_id    = $event->{user};
    my $user_name  = $slack->find_user_name($user_id);
    my $text       = $event->{text};

    my @code_lines = split /\n/, $text;
    my $command = shift @code_lines;
    if ($command =~ /run/) {
    	my $code = "";
	    for (@code_lines) {

	    # HTML Escape strings
	    	s/[“”]/\"/g;
	    	s/[‘’]/\'/g;
	    	s/&lt;/</g;
            s/&gt;/>/g;
            s/&quot;/\"/g;
            s/&#39;/\'/g;
            s/&amp;/&/g;
        # Escape sequences
	    	s/\\n/\n/g;
	    	s/\\t/\t/g;
	    	s/(.*)\\r//g;
	    	s/\\f/\f/g;
	    	s/(.)\\b//g;
	    	s/\\a/\a/g;
	    	s/\\e/\e/g;
	    	s/\\x/\x/g;
	    #	s/\\c/\c/g; # Not support?
	    	s/\\l/\l/g;
	    	s/\\u/\u/g;
	    #	s/\\L/\L/g; # Not support?
	    #	s/\\U/\U/g; # Not support?
	    #	s/\\E/\E/g; # Not support?
	    #	Function current system
	    	s/`.*`;//g;
	    	s/system;//g;
	    	s/system\(.*\);//g;
	    	s/system\s+["'$@%\[{].*;//g;
	    	s/exec;//g;
	    	s/exec\(.*\);//g;
	    	s/exec\s+["'$@%\[{].*;//g;
	    	s/glob;//g;
	    	s/glob\(.*\);//g;
	    	s/glob\s+["'$@%\[{].*;//g;
	    	s/chdir;//g;
	    	s/chdir\(.*\);//g;
	    	s/chdir\s+["'$@%\[{].*;//g;
	    	s/unlink;//g;
	    	s/unlink\(.*\);//g;
	    	s/unlink\s+["'$@%\[{].*;//g;
	    	s/rename;//g;
	    	s/rename\(.*\);//g;
	    	s/rename\s+["'$@%\[{].*;//g;
	    	s/chmod\(.*\);//g;
	    	s/chmod\s+\d+(\s+)?,(\s+)?["'$@%\[{].*;//g;
	    	s/open\(.*\);//g;
	    	s/open\s+([$@%].*|[A-Z]+)(\s+)?,(\s+)?["'$@%\[{].*;//g;
	    	s/eval\(.*\);//g;
	    	s/eval\s+["'$@%\[{].*;//g;

	    # Module
	    	s/use\s+File::.*;//g;

	    # Variable
	    	s/[$%@]ENV;//g;

	    	$code .= $_;
	    }
	    # $slack->log->info($code);
	    my $result = $bot->getResult($code, $emoji);
	    $slack->send_message($channel_id => $result);
    } elsif ($command =~ /help/) {
	    $slack->send_message($channel_id => usage());
    }
    #$slack->log->info($text);
});

$slack->start;

sub usage {
	return "
		Usage: \@perl COMMAND\n
		-- run\n
		    Run your code using reply :+1:\n
		-- help\n
		   :robot_face: help\n
	";
}

=pod
$bot->postResult(
	token => $token,
	text => $result,
	channel => "#test"
);
=cut
