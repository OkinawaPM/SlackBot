#!/usr/bin/env perl -M-ops=:dangerous,:others,system,glob,:base_thread
use strict;
use warnings;
use v5.10;

use utf8;
use lib "lib", "lib";
use Path::Tiny;

use Bot;
use Mojo::SlackRTM;

my $file = "../token";
die "You must prepare TOKEN file first.\n" unless -f $file;

my $emoji = ":camel:";
my ($token) = path($file)->lines({chomp => 1});

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

			$code .= $_;
	    }
	    $slack->log->info("Running code: $user_name");
	    my $result = $bot->getResult($code, $emoji);
	    $slack->log->info("Post");
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
