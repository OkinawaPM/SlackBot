use Test::More;
use Test::MockObject::Extends;

use File::Spec;
use Cwd 'getcwd';
BEGIN {
    unshift @INC, File::Spec->catfile(getcwd, "lib");
    my $foo = <<"FOO";
package Okinawa::SlackBot::Plugin::Foo;
use Okinawa::SlackBot::Plugin;
plugin foo => short 'Foo description';
sub foo { 'Foo!!' }

1;
FOO

    my $bar = <<"BAR";
package Okinawa::SlackBot::Plugin::Bar;
use Okinawa::SlackBot::Plugin;
plugin bar => short 'Bar description';
sub bar { \$_[1] }

1;
BAR

    my $codehex = <<"HEX";
package Okinawa::SlackBot::Plugin::Hex;
use Okinawa::SlackBot::Plugin;
plugin codehex => short 'CodeHex description';
sub codehex { map { hex } \@_[1..\$#_] }

1;
HEX

    # Create packages
    my $pwd = getcwd;
    open my $fh, '>', File::Spec->catfile($pwd, 'lib/Okinawa/SlackBot/Plugin/Foo.pm');
    print $fh $foo;
    close $fh;

    open $fh, '>', File::Spec->catfile($pwd, 'lib/Okinawa/SlackBot/Plugin/Bar.pm');
    print $fh $bar;
    close $fh;

    open $fh, '>', File::Spec->catfile($pwd, 'lib/Okinawa/SlackBot/Plugin/Hex.pm');
    print $fh $codehex;
    close $fh;
}
# clean up
END {
    my $pwd = getcwd;
    unlink File::Spec->catfile($pwd, 'lib/Okinawa/SlackBot/Plugin/Foo.pm');
    unlink File::Spec->catfile($pwd, 'lib/Okinawa/SlackBot/Plugin/Bar.pm');
    unlink File::Spec->catfile($pwd, 'lib/Okinawa/SlackBot/Plugin/Hex.pm');
}

use Okinawa::SlackBot::Plugin;

my $botname = 'Perl';
my $plugin = Okinawa::SlackBot::Plugin->new(name => $botname)->load()
            or diag "Failed to load plugins: $!";

subtest 'Can load plugins?' => sub {
    can_ok $plugin => 'foo';
    can_ok $plugin => 'bar';
    can_ok $plugin => 'codehex';
};

subtest 'Can use plugins?' => sub {
    is $plugin->foo, 'Foo!!', 'Use Foo.pm';
    is $plugin->bar('Bar!!'), 'Bar!!', 'Use Bar.pm';
    is_deeply +[$plugin->codehex('a'..'z')], +[map { hex } 'a'..'z'], 'Use Hex.pm';
};

is $plugin->usage, <<"...", 'Whether correct usage is displayed';
Usage: \@$botname COMMAND
-- bar
    Bar description
-- exec
    Run your code using reply
-- foo
    Foo description
-- codehex
    CodeHex description
-- help
    :robot_face: help
...

done_testing;