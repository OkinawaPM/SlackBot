use Test::More;
use Test::MockObject::Extends;

use Okinawa::SlackBot;
my $bot = Okinawa::SlackBot->new(name => 'bot_name', token => 'token');
my $bot_mocked = Test::MockObject::Extends->new($bot);

$bot_mocked->set_always(find_user_id => 'B2HDQ7VV3');

is $bot_mocked->name, 'bot_name', 'right attribute value';
is $bot_mocked->token, 'token', 'right attribute value';
is $bot_mocked->id, 'B2HDQ7VV3', 'result of find_user_id';
is $bot_mocked->validation('<@B2HDQ7VV3> mention'), 1, 'check to mention (success)';
is $bot_mocked->validation('mention'), 0, 'check to mention (fail)';
isa_ok $bot_mocked->log, 'Mojo::Log', 'check the log object';
isa_ok $bot_mocked->ua, 'Mojo::UserAgent', 'check the ua object';

done_testing;